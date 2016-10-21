Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFE146B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 22:01:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so40390144pfa.5
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 19:01:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id rb4si222941pab.116.2016.10.20.19.01.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 19:01:23 -0700 (PDT)
Date: Thu, 20 Oct 2016 19:01:16 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161021020116.GD1075@tassilo.jf.intel.com>
References: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
 <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
 <20161017141245.GC27459@dhcp22.suse.cz>
 <20161017145539.GA26930@node.shutemov.name>
 <20161018142007.GL12092@dhcp22.suse.cz>
 <20161018143207.GA5833@node.shutemov.name>
 <20161018183023.GC27792@dhcp22.suse.cz>
 <alpine.LSU.2.11.1610191101250.10318@eggly.anvils>
 <20161020103946.GA3881@node.shutemov.name>
 <20161020224630.GO23194@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020224630.GO23194@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Ugh, no, please don't use mount options for file specific behaviours
> in filesystems like ext4 and XFS. This is exactly the sort of
> behaviour that should either just work automatically (i.e. be
> completely controlled by the filesystem) or only be applied to files

Can you explain what you mean? How would the file system control it?

> specifically configured with persistent hints to reliably allocate
> extents in a way that can be easily mapped to huge pages.

> e.g. on XFS you will need to apply extent size hints to get large
> page sized/aligned extent allocation to occur, and so this

It sounds like you're confusing alignment in memory with alignment
on disk here? I don't see why on disk alignment would be needed
at all, unless we're talking about DAX here (which is out of 
scope currently) Kirill's changes are all about making the memory
access for cached data more efficient, it's not about disk layout
optimizations.

> persistent extent size hint should trigger the filesystem to use
> large pages if supported, the hint is correctly sized and aligned,
> and there are large pages available for allocation.

That would be ioctls and similar?

That would imply that every application wanting to use large pages
would need to be especially enabled. That would seem awfully limiting
to me and needlessly deny benefits to most existing code.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
