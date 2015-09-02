Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E8A2C6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 23:19:47 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so16965044pac.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 20:19:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kv12si33196975pab.144.2015.09.01.20.19.46
        for <linux-mm@kvack.org>;
        Tue, 01 Sep 2015 20:19:47 -0700 (PDT)
Date: Tue, 1 Sep 2015 21:19:45 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] dax, pmem: add support for msync
Message-ID: <20150902031945.GA8916@linux.intel.com>
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
 <20150831233803.GO3902@dastard>
 <20150901070608.GA5482@lst.de>
 <20150901222120.GQ3902@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150901222120.GQ3902@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@osdl.org>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

On Wed, Sep 02, 2015 at 08:21:20AM +1000, Dave Chinner wrote:
> Which means applications that should "just work" without
> modification on DAX are now subtly broken and don't actually
> guarantee data is safe after a crash. That's a pretty nasty
> landmine, and goes against *everything* we've claimed about using
> DAX with existing applications.
> 
> That's wrong, and needs fixing.

I agree that we need to fix fsync as well, and that the fsync solution could
be used to implement msync if we choose to go that route.  I think we might
want to consider keeping the msync and fsync implementations separate, though,
for two reasons.

1) The current msync implementation is much more efficient than what will be
needed for fsync.  Fsync will need to call into the filesystem, traverse all
the blocks, get kernel virtual addresses from those and then call
wb_cache_pmem() on those kernel addresses.  I think this is a necessary evil
for fsync since you don't have a VMA, but for msync we do and we can just
flush using the user addresses without any fs lookups.

2) I believe that the near-term fsync code will rely on struct pages for
PMEM, which I believe are possible but optional as of Dan's last patch set:

https://lkml.org/lkml/2015/8/25/841

I believe that this means that if we don't have struct pages for PMEM (becuase
ZONE_DEVICE et al. are turned off) fsync won't work.  I'd be nice not to lose
msync as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
