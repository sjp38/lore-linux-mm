Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 830FEC5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 04:40:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52BC32084F
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 04:40:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52BC32084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDAF66B0003; Thu, 12 Sep 2019 00:40:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D647E6B0005; Thu, 12 Sep 2019 00:40:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2B236B0006; Thu, 12 Sep 2019 00:40:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7B16B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:40:14 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 26C73180AD804
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 04:40:14 +0000 (UTC)
X-FDA: 75925016748.01.grade86_1f1b29471fc39
X-HE-Tag: grade86_1f1b29471fc39
X-Filterd-Recvd-Size: 3969
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 04:40:13 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 84889AB6D;
	Thu, 12 Sep 2019 04:40:11 +0000 (UTC)
Date: Wed, 11 Sep 2019 21:40:02 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Waiman Long <longman@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
Message-ID: <20190912044002.xp3c7jbpbmq4dbz6@linux-p48b>
Mail-Followup-To: Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Waiman Long <longman@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <ae7edcb8-74e5-037c-17e7-01b3cf9320af@oracle.com>
 <20190912034143.GJ29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190912034143.GJ29434@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Sep 2019, Matthew Wilcox wrote:

>On Wed, Sep 11, 2019 at 08:26:52PM -0700, Mike Kravetz wrote:
>> All this got me wondering if we really need to take i_mmap_rwsem in write
>> mode here.  We are not changing the tree, only traversing it looking for
>> a suitable vma.
>>
>> Unless I am missing something, the hugetlb code only ever takes the semaphore
>> in write mode; never read.  Could this have been the result of changing the
>> tree semaphore to read/write?  Instead of analyzing all the code, the easiest
>> and safest thing would have been to take all accesses in write mode.
>
>I was wondering the same thing.  It was changed here:
>
>commit 83cde9e8ba95d180eaefefe834958fbf7008cf39
>Author: Davidlohr Bueso <dave@stgolabs.net>
>Date:   Fri Dec 12 16:54:21 2014 -0800
>
>    mm: use new helper functions around the i_mmap_mutex
>
>    Convert all open coded mutex_lock/unlock calls to the
>    i_mmap_[lock/unlock]_write() helpers.
>
>and a subsequent patch said:
>
>    This conversion is straightforward.  For now, all users take the write
>    lock.
>
>There were subsequent patches which changed a few places
>c8475d144abb1e62958cc5ec281d2a9e161c1946
>1acf2e040721564d579297646862b8ea3dd4511b
>d28eb9c861f41aa2af4cfcc5eeeddff42b13d31e
>874bfcaf79e39135cd31e1cfc9265cf5222d1ec3
>3dec0ba0be6a532cac949e02b853021bf6d57dad
>
>but I don't know why this one wasn't changed.

I cannot recall why huge_pmd_share() was not changed along with the other
callers that don't modify the interval tree. By looking at the function,
I agree that this could be shared, in fact this lock is much less involved
than it's anon_vma counterpart, last I checked (perhaps with the exception
of take_rmap_locks().

>
>(I was also wondering about caching a potentially sharable page table
>in the address_space to avoid having to walk the VMA tree at all if that
>one happened to be sharable).

I also think that the right solution is within the mm instead of adding
a new api to rwsem and the extra complexity/overhead to osq _just_ for this
case. We've managed to not need timeout extensions in our locking primitives
thus far, which is a good thing imo.

Thanks,
Davidlohr

