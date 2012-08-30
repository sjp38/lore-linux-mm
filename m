Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id F2DB26B0069
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 13:21:29 -0400 (EDT)
Received: by dadi14 with SMTP id i14so1480188dad.14
        for <linux-mm@kvack.org>; Thu, 30 Aug 2012 10:21:29 -0700 (PDT)
Date: Fri, 31 Aug 2012 02:21:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch]readahead: fault retry breaks mmap file read random
 detection
Message-ID: <20120830172123.GA2141@barrios>
References: <20120822034012.GA24099@kernel.org>
 <5034FD71.3000406@redhat.com>
 <20120823011003.GA8944@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120823011003.GA8944@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, fengguang.wu@intel.com, akpm@linux-foundation.org

On Thu, Aug 23, 2012 at 09:10:03AM +0800, Shaohua Li wrote:
> On Wed, Aug 22, 2012 at 11:40:33AM -0400, Rik van Riel wrote:
> > On 08/21/2012 11:40 PM, Shaohua Li wrote:
> > >.fault now can retry. The retry can break state machine of .fault. In
> > >filemap_fault, if page is miss, ra->mmap_miss is increased. In the second try,
> > >since the page is in page cache now, ra->mmap_miss is decreased. And these are
> > >done in one fault, so we can't detect random mmap file access.
> > >
> > >Add a new flag to indicate .fault is tried once. In the second try, skip
> > >ra->mmap_miss decreasing. The filemap_fault state machine is ok with it.
> > 
> > >Index: linux/arch/avr32/mm/fault.c
> > >===================================================================
> > >--- linux.orig/arch/avr32/mm/fault.c	2012-08-22 09:51:23.035526683 +0800
> > >+++ linux/arch/avr32/mm/fault.c	2012-08-22 09:52:22.822775020 +0800
> > >@@ -152,6 +152,7 @@ good_area:
> > >  			tsk->min_flt++;
> > >  		if (fault & VM_FAULT_RETRY) {
> > >  			flags &= ~FAULT_FLAG_ALLOW_RETRY;
> > >+			flags |= FAULT_FLAG_TRIED;
> > 
> > Is there any place where you set FAULT_FLAG_TRIED
> > where FAULT_FLAG_ALLOW_RETRY is not cleared?
> > 
> > In other words, could we use the absence of the
> > FAULT_FLAG_ALLOW_RETRY as the test, avoiding the
> > need for a new bit flag?
> 
> There are still several archs (~7) don't enable fault retry yet. For such
> archs, FAULT_FLAG_ALLOW_RETRY isn't set in the first try. If all archs support
> fault retry, the new flag is unnecessary.

I'm not sure it's a good idea because archs support FAULT_FLAG_ALLOW_RETRY
use FAULT_FLAG_ALLOW_RETRY to avoid miscount major/minor fault accouting.
It's a similar to your goal so if you introduce new flag, major/minor fault
accounting should use your flag for the consistency, too. Otherwise,
you could be better to use FAULT_FLAG_ALLOW_RETRY but the problem is
all arch don't support it now as you mentioned. So ideal solution is that
firstly you can make all archs support FAULT_FLAG_ALLOW_RETRY(I'm not sure
it's easy or not), then use that bit flag instead of introducing new flag.
If you don't like it, I'm not strongly against with you but at least,
please write down TODO for tidy up in future.

TODO :
If all arch support FAULT_FLAG_ALLOW_RETRY in future, we can remove
FAULT_FLAG_TRIED and use FAULT_FLAG_ALLOW_RETRY to prevent misaccounting
major/minor fault and readahead mmap_miss.

> 
> Thanks,
> Shaohua
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
