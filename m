Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B711C4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 13:53:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA4F3214AF
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 13:53:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA4F3214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 656E46B0005; Mon, 16 Sep 2019 09:53:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62E156B0006; Mon, 16 Sep 2019 09:53:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5441F6B0007; Mon, 16 Sep 2019 09:53:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0033.hostedemail.com [216.40.44.33])
	by kanga.kvack.org (Postfix) with ESMTP id 31AD86B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:53:47 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BE6805010
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 13:53:46 +0000 (UTC)
X-FDA: 75940926852.27.brass54_3cdeca568156
X-HE-Tag: brass54_3cdeca568156
X-Filterd-Recvd-Size: 2557
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 13:53:45 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B486318C4276;
	Mon, 16 Sep 2019 13:53:44 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A5DA617F85;
	Mon, 16 Sep 2019 13:53:43 +0000 (UTC)
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
To: Matthew Wilcox <willy@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>, Peter Zijlstra
 <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 Will Deacon <will.deacon@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <ae7edcb8-74e5-037c-17e7-01b3cf9320af@oracle.com>
 <20190912034143.GJ29434@bombadil.infradead.org>
 <20190912044002.xp3c7jbpbmq4dbz6@linux-p48b>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <f22d641f-d36e-e61e-70aa-3e54632485fe@redhat.com>
Date: Mon, 16 Sep 2019 09:53:43 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190912044002.xp3c7jbpbmq4dbz6@linux-p48b>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.62]); Mon, 16 Sep 2019 13:53:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/12/19 12:40 AM, Davidlohr Bueso wrote:
>
> I also think that the right solution is within the mm instead of adding
> a new api to rwsem and the extra complexity/overhead to osq _just_ for
> this
> case. We've managed to not need timeout extensions in our locking
> primitives
> thus far, which is a good thing imo. 

Adding a variant with timeout can be useful in resolving some potential
deadlock issues found by lockdep. Anyway, there were talk about merging
rt-mutex and regular mutex in the LPC last week. So we will need to have
mutex_lock() variant with timeout for that to happen.

Cheers,
Longman


