Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9824AECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 17:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64D392081B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 17:15:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64D392081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF0376B0007; Wed, 11 Sep 2019 13:15:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA1D06B0008; Wed, 11 Sep 2019 13:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB8206B000A; Wed, 11 Sep 2019 13:15:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0252.hostedemail.com [216.40.44.252])
	by kanga.kvack.org (Postfix) with ESMTP id BAAE56B0007
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 13:15:32 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2683C1F872
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:15:32 +0000 (UTC)
X-FDA: 75923291304.27.back53_13275568efc1e
X-HE-Tag: back53_13275568efc1e
X-Filterd-Recvd-Size: 4315
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:15:31 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 783A81DB0;
	Wed, 11 Sep 2019 17:15:30 +0000 (UTC)
Received: from llong.remote.csb (ovpn-123-234.rdu2.redhat.com [10.10.123.234])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CEEB060872;
	Wed, 11 Sep 2019 17:15:27 +0000 (UTC)
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
To: Mike Kravetz <mike.kravetz@oracle.com>,
 Matthew Wilcox <willy@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 Will Deacon <will.deacon@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <20190911151451.GH29434@bombadil.infradead.org>
 <19d9ea18-bd20-e02f-c1de-70e7322f5f22@redhat.com>
 <40a511a4-5771-f9a9-40b6-64e39478bbcb@oracle.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <5229662c-d709-7aca-be4c-53dea1a49fda@redhat.com>
Date: Wed, 11 Sep 2019 18:15:26 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <40a511a4-5771-f9a9-40b6-64e39478bbcb@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.71]); Wed, 11 Sep 2019 17:15:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/11/19 6:03 PM, Mike Kravetz wrote:
> On 9/11/19 8:44 AM, Waiman Long wrote:
>> On 9/11/19 4:14 PM, Matthew Wilcox wrote:
>>> On Wed, Sep 11, 2019 at 04:05:37PM +0100, Waiman Long wrote:
>>>> When allocating a large amount of static hugepages (~500-1500GB) on a
>>>> system with large number of CPUs (4, 8 or even 16 sockets), performance
>>>> degradation (random multi-second delays) was observed when thousands
>>>> of processes are trying to fault in the data into the huge pages. The
>>>> likelihood of the delay increases with the number of sockets and hence
>>>> the CPUs a system has.  This only happens in the initial setup phase
>>>> and will be gone after all the necessary data are faulted in.
>>> Can;t the application just specify MAP_POPULATE?
>> Originally, I thought that this happened in the startup phase when the
>> pages were faulted in. The problem persists after steady state had been
>> reached though. Every time you have a new user process created, it will
>> have its own page table.
> This is still at fault time.  Although, for the particular application it
> may be after the 'startup phase'.
>
>>                          It is the sharing of the of huge page shared
>> memory that is causing problem. Of course, it depends on how the
>> application is written.
> It may be the case that some applications would find the delays acceptable
> for the benefit of shared pmds once they reach steady state.  As you say, of
> course this depends on how the application is written.
>
> I know that Oracle DB would not like it if PMD sharing is disabled for them.
> Based on what I know of their model, all processes which share PMDs perform
> faults (write or read) during the startup phase.  This is in environments as
> big or bigger than you describe above.  I have never looked at/for delays in
> these environments around pmd sharing (page faults), but that does not mean
> they do not exist.  I will try to get the DB group to give me access to one
> of their large environments for analysis.
>
> We may want to consider making the timeout value and disable threshold user
> configurable.

Making it configurable is certainly doable. They can be sysctl
parameters so that the users can reenable PMD sharing by making those
parameters larger.

Cheers,
Longman


