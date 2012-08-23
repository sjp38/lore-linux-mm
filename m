Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id D10C16B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 21:10:11 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so357243pbb.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 18:10:11 -0700 (PDT)
Date: Thu, 23 Aug 2012 09:10:03 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch]readahead: fault retry breaks mmap file read random
 detection
Message-ID: <20120823011003.GA8944@kernel.org>
References: <20120822034012.GA24099@kernel.org>
 <5034FD71.3000406@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5034FD71.3000406@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, akpm@linux-foundation.org

On Wed, Aug 22, 2012 at 11:40:33AM -0400, Rik van Riel wrote:
> On 08/21/2012 11:40 PM, Shaohua Li wrote:
> >.fault now can retry. The retry can break state machine of .fault. In
> >filemap_fault, if page is miss, ra->mmap_miss is increased. In the second try,
> >since the page is in page cache now, ra->mmap_miss is decreased. And these are
> >done in one fault, so we can't detect random mmap file access.
> >
> >Add a new flag to indicate .fault is tried once. In the second try, skip
> >ra->mmap_miss decreasing. The filemap_fault state machine is ok with it.
> 
> >Index: linux/arch/avr32/mm/fault.c
> >===================================================================
> >--- linux.orig/arch/avr32/mm/fault.c	2012-08-22 09:51:23.035526683 +0800
> >+++ linux/arch/avr32/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
> >@@ -152,6 +152,7 @@ good_area:
> >  			tsk->min_flt++;
> >  		if (fault & VM_FAULT_RETRY) {
> >  			flags &= ~FAULT_FLAG_ALLOW_RETRY;
> >+			flags |= FAULT_FLAG_TRIED;
> 
> Is there any place where you set FAULT_FLAG_TRIED
> where FAULT_FLAG_ALLOW_RETRY is not cleared?
> 
> In other words, could we use the absence of the
> FAULT_FLAG_ALLOW_RETRY as the test, avoiding the
> need for a new bit flag?

There are still several archs (~7) don't enable fault retry yet. For such
archs, FAULT_FLAG_ALLOW_RETRY isn't set in the first try. If all archs support
fault retry, the new flag is unnecessary.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
