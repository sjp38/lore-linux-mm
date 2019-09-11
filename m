Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0A3CECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 20:51:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 364AF2085B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 20:51:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 364AF2085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96CB66B0279; Wed, 11 Sep 2019 16:51:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91DAA6B027A; Wed, 11 Sep 2019 16:51:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 832006B027B; Wed, 11 Sep 2019 16:51:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9096B0279
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 16:51:07 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id F06B7181AC9C9
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:51:06 +0000 (UTC)
X-FDA: 75923834532.17.stick75_990e60769b07
X-HE-Tag: stick75_990e60769b07
X-Filterd-Recvd-Size: 2599
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:51:05 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6274930821BF;
	Wed, 11 Sep 2019 20:51:04 +0000 (UTC)
Received: from llong.remote.csb (ovpn-121-77.rdu2.redhat.com [10.10.121.77])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D11845D6A5;
	Wed, 11 Sep 2019 20:51:01 +0000 (UTC)
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
To: Matthew Wilcox <willy@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 Will Deacon <will.deacon@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>, linux-kernel@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 Davidlohr Bueso <dave@stgolabs.net>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <20190911195745.GI29434@bombadil.infradead.org>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <11361434-ca3d-78ae-e825-8521ee3bfbe6@redhat.com>
Date: Wed, 11 Sep 2019 21:51:00 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190911195745.GI29434@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Wed, 11 Sep 2019 20:51:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/11/19 8:57 PM, Matthew Wilcox wrote:
> On Wed, Sep 11, 2019 at 04:05:37PM +0100, Waiman Long wrote:
>> To remove the unacceptable delays, we have to limit the amount of wait
>> time on the mmap_sem. So the new down_write_timedlock() function is
>> used to acquire the write lock on the mmap_sem with a timeout value of
>> 10ms which should not cause a perceivable delay. If timeout happens,
>> the task will abandon its effort to share the PMD and allocate its own
>> copy instead.
> If you do a v2, this is *NOT* the mmap_sem.  It's the i_mmap_rwsem
> which protects a very different data structure from the mmap_sem.
>
Thanks for reminder. I should have read the code more carefully.

Cheers,
Longman


