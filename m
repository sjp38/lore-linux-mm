Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 062E16B00AC
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:24:24 -0400 (EDT)
Received: from [172.16.12.116] by digidescorp.com (Cipher SSLv3:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001454742.msg
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:24:21 -0500
Subject: Re: [PATCH V2] nommu: add anonymous page memcg accounting
From: "Steven J. Magnani" <steve@digidescorp.com>
Reply-To: steve@digidescorp.com
In-Reply-To: <20101019154819.GC15844@balbir.in.ibm.com>
References: <1287491654-4005-1-git-send-email-steve@digidescorp.com>
	 <20101019154819.GC15844@balbir.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Oct 2010 13:24:17 -0500
Message-ID: <1287512657.2500.31.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, dhowells@redhat.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 2010-10-19 at 21:18 +0530, Balbir Singh wrote:
> * Steven J. Magnani <steve@digidescorp.com> [2010-10-19 07:34:14]:
> 
> > Add the necessary calls to track VM anonymous page usage (only).
> > 
> > V2 changes:
> > * Added update of memory cgroup documentation
> > * Clarify use of 'file' to distinguish anonymous mappings
> > 
> > Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
> > ---
> > diff -uprN a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > --- a/Documentation/cgroups/memory.txt	2010-10-05 09:14:36.000000000 -0500
> > +++ b/Documentation/cgroups/memory.txt	2010-10-19 07:28:04.000000000 -0500
> > @@ -34,6 +34,7 @@ Current Status: linux-2.6.34-mmotm(devel
> > 
> >  Features:
> >   - accounting anonymous pages, file caches, swap caches usage and limiting them.
> > +   NOTE: On NOMMU systems, only anonymous pages are accounted.
> >   - private LRU and reclaim routine. (system's global LRU and private LRU
> >     work independently from each other)
> >   - optionally, memory+swap usage can be accounted and limited.
> > @@ -640,7 +641,30 @@ At reading, current status of OOM is sho
> >  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
> >  				 be stopped.)
> > 
> > -11. TODO
> > +11. NOMMU Support
<snip>
> > +
> > +At the present time, only anonymous pages are included in NOMMU memory cgroup
> > +accounting.
> 
> What is the reason for tracking just anonymous memory?

Tracking more than that is beyond my current scope, and perhaps of
limited benefit under an assumption that NOMMU systems don't usually
work with large files. The limitations of the implementation are
documented, so hopefully anyone who needs more functionality will know
that they need to implement it.

> > diff -uprN a/mm/nommu.c b/mm/nommu.c
> > --- a/mm/nommu.c	2010-10-13 08:20:38.000000000 -0500
> > +++ b/mm/nommu.c	2010-10-13 08:24:06.000000000 -0500
<snip>
> > @@ -1117,9 +1125,27 @@ static int do_mmap_private(struct vm_are
> >  		set_page_refcounted(&pages[point]);
> > 
> >  	base = page_address(pages);
> > -	region->vm_flags = vma->vm_flags |= VM_MAPPED_COPY;
> > +
> >  	region->vm_start = (unsigned long) base;
> >  	region->vm_end   = region->vm_start + rlen;
> > +
> > +	/* Only anonymous pages are charged, currently */
> > +	if (!vma->vm_file) {
> > +		for (point = 0; point < total; point++) {
> > +			int charge_failed =
> > +				mem_cgroup_newpage_charge(&pages[point],
> > +							  current->mm,
> 
> Is current->mm same as vma->vm_mm? I think vma->vm_mm is cleaner.

I agree, but at the time this code runs, vma->vm_mm is NULL except for
an executable file mapping - which is not the case for the anonymous
pages we are trying to track. I will look into modifying do_mmap_pgoff()
to set vm_mm before invoking do_mmap_private(); if that can be done
without side effects, I'll change the code here as you suggest.

Thanks for the quick review.
------------------------------------------------------------------------
 Steven J. Magnani               "I claim this network for MARS!
 www.digidescorp.com              Earthling, return my space modulator!"

 #include <standard.disclaimer>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
