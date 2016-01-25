Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E65D2828DF
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:52:13 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 65so84609276pff.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:52:13 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hq1si34680166pac.56.2016.01.25.08.52.13
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 08:52:13 -0800 (PST)
Date: Mon, 25 Jan 2016 11:52:09 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 10/20] dax: Replace XIP documentation with DAX
 documentation
Message-ID: <20160125165209.GH2948@linux.intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <1414185652-28663-11-git-send-email-matthew.r.wilcox@intel.com>
 <CA+ZsKJ7LgOjuZ091d-ikhuoA+ZrCny4xBGVupv0oai8yB5OqFQ@mail.gmail.com>
 <100D68C7BA14664A8938383216E40DE0421657C5@fmsmsx111.amr.corp.intel.com>
 <CA+ZsKJ4EMKRgdFQzUjRJOE48=tTJzHf66-60PnVRj7pxvmNgVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+ZsKJ4EMKRgdFQzUjRJOE48=tTJzHf66-60PnVRj7pxvmNgVg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Chris Brandt <Chris.Brandt@renesas.com>

On Sun, Jan 24, 2016 at 01:03:49AM -0800, Jared Hulbert wrote:
> I our defense we didn't know we were sinning at the time.

Fair enough.  Cache flushing is Hard.

> Can you walk me through the cache flushing hole?  How is it okay on
> X86 but not VIVT archs?  I'm missing something obvious here.
> 
> I thought earlier that vm_insert_mixed() handled the necessary
> flushing.  Is that even the part you are worried about?

No, that part should be fine.  My concern is about write() calls to files
which are also mmaped.  See Documentation/cachetlb.txt around line 229,
starting with "There exists another whole class of cpu cache issues" ...

> What flushing functions would you call if you did have a cache page.

Well, that's the problem; they don't currently exist.

> There are all kinds of cache flushing functions that work without a
> struct page. If nothing else the specialized ASM instructions that do
> the various flushes don't use struct page as a parameter.  This isn't
> the first I've run into the lack of a sane cache API.  Grep for
> inval_cache in the mtd drivers, should have been much easier.  Isn't
> the proper solution to fix update_mmu_cache() or build out a pageless
> cache flushing API?
> 
> I don't get the explicit mapping solution.  What are you mapping
> where?  What addresses would be SHMLBA?  Phys, kernel, userspace?

The problem comes in dax_io() where the kernel stores to an alias of the
user address (or reads from an alias of the user address).  Theoretically,
we should flush user addresses before we read from the kernel's alias,
and flush the kernel's alias after we store to it.

But if we create a new address for the kernel to use which lands on the
same cache line as the user's address (and this is what SHMLBA is used
to indicate), there is no incoherency between the kernel's view and the
user's view.  And no new cache flushing API is needed.

Is that clearer?  I'm not always good at explaining these things in a
way which makes sense to other people :-(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
