Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C9C6C49ED6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 03:41:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B71A214AF
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 03:41:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Fnr+FH0I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B71A214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EA1E6B0003; Wed, 11 Sep 2019 23:41:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 999D36B0005; Wed, 11 Sep 2019 23:41:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ADC36B0006; Wed, 11 Sep 2019 23:41:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0201.hostedemail.com [216.40.44.201])
	by kanga.kvack.org (Postfix) with ESMTP id 63E1D6B0003
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 23:41:55 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C52C6688F
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:41:54 +0000 (UTC)
X-FDA: 75924869748.16.peace01_67c9e5bafd356
X-HE-Tag: peace01_67c9e5bafd356
X-Filterd-Recvd-Size: 3663
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:41:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7EwQtG2hwlINClUDNZab/A4gQX9VeexXatbSrvMQs9I=; b=Fnr+FH0Iq5wsSebY0xIvcvz3a
	ARsc+bxbp6X4Wqlhor8mTnGmujrqXxtXRHIZ14oZo77yUethMpwVRQi9ulUznP7ifhisPFAWNfhU6
	hzezfQxpYC1iIJHL3c0LAHn644O20BB0hxpJOQ0acyTjBM0ix6/zhnCHRGKH12WLpeIQQMnFaYSar
	ZaDp293HOeh3fUq01D9vYyp1fr1pcDMt5A02u4FPasLEsD7Mf30jcvwR+M3cyarD08JgU7LqVqR4K
	q+vvN827RZdUkJ8BrqdcgENp3zgvAY8FpMpyAkf0nj51CsJn7gCJVX6WOjIerx1fRtAGvXbKE321s
	7CufzKEVQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1i8FzL-0002e3-4X; Thu, 12 Sep 2019 03:41:43 +0000
Date: Wed, 11 Sep 2019 20:41:43 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
Message-ID: <20190912034143.GJ29434@bombadil.infradead.org>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <ae7edcb8-74e5-037c-17e7-01b3cf9320af@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ae7edcb8-74e5-037c-17e7-01b3cf9320af@oracle.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 08:26:52PM -0700, Mike Kravetz wrote:
> All this got me wondering if we really need to take i_mmap_rwsem in write
> mode here.  We are not changing the tree, only traversing it looking for
> a suitable vma.
> 
> Unless I am missing something, the hugetlb code only ever takes the semaphore
> in write mode; never read.  Could this have been the result of changing the
> tree semaphore to read/write?  Instead of analyzing all the code, the easiest
> and safest thing would have been to take all accesses in write mode.

I was wondering the same thing.  It was changed here:

commit 83cde9e8ba95d180eaefefe834958fbf7008cf39
Author: Davidlohr Bueso <dave@stgolabs.net>
Date:   Fri Dec 12 16:54:21 2014 -0800

    mm: use new helper functions around the i_mmap_mutex
    
    Convert all open coded mutex_lock/unlock calls to the
    i_mmap_[lock/unlock]_write() helpers.

and a subsequent patch said:

    This conversion is straightforward.  For now, all users take the write
    lock.

There were subsequent patches which changed a few places
c8475d144abb1e62958cc5ec281d2a9e161c1946
1acf2e040721564d579297646862b8ea3dd4511b
d28eb9c861f41aa2af4cfcc5eeeddff42b13d31e
874bfcaf79e39135cd31e1cfc9265cf5222d1ec3
3dec0ba0be6a532cac949e02b853021bf6d57dad

but I don't know why this one wasn't changed.

(I was also wondering about caching a potentially sharable page table
in the address_space to avoid having to walk the VMA tree at all if that
one happened to be sharable).

