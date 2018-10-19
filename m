Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6486B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 21:47:30 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 43-v6so24783198ple.19
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 18:47:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k20-v6si23717333pgh.168.2018.10.18.18.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 18:47:28 -0700 (PDT)
Date: Thu, 18 Oct 2018 18:47:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: dirty pages as they are added to pagecache
Message-Id: <20181018184726.fb8da5c733da5e0c6a235101@linux-foundation.org>
In-Reply-To: <20181019004621.GA30067@redhat.com>
References: <20181018041022.4529-1-mike.kravetz@oracle.com>
	<20181018160827.0cb656d594ffb2f0f069326c@linux-foundation.org>
	<6d6e4733-39aa-a958-c0a2-c5a47cdcc7d0@oracle.com>
	<20181019004621.GA30067@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Alexander Viro <viro@zeniv.linux.org.uk>, stable@vger.kernel.org

On Thu, 18 Oct 2018 20:46:21 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Thu, Oct 18, 2018 at 04:16:40PM -0700, Mike Kravetz wrote:
> > I was not sure about this, and expected someone could come up with
> > something better.  It just seems there are filesystems like huegtlbfs,
> > where it makes no sense wasting cycles traversing the filesystem.  So,
> > let's not even try.
> > 
> > Hoping someone can come up with a better method than hard coding as
> > I have done above.
> 
> It's not strictly required after marking the pages dirty though. The
> real fix is the other one? Could we just drop the hardcoding and let
> it run after the real fix is applied?
> 
> The performance of drop_caches doesn't seem critical, especially with
> gigapages. tmpfs doesn't seem to be optimized away from drop_caches
> and the gain would be bigger for tmpfs if THP is not enabled in the
> mount, so I'm not sure if we should worry about hugetlbfs first.

I guess so.  I can't immediately see a clean way of expressing this so
perhaps it would need a new BDI_CAP_NO_BACKING_STORE.  Such a
thing hardly seems worthwhile for drop_caches.

And drop_caches really shouldn't be there anyway.  It's a standing
workaround for ongoing suckage in pagecache and metadata reclaim
behaviour :(
