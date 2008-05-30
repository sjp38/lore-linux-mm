Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4U7iqS1000373
	for <linux-mm@kvack.org>; Fri, 30 May 2008 03:44:52 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4U7iqHa131094
	for <linux-mm@kvack.org>; Fri, 30 May 2008 01:44:52 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4U7ipE5009499
	for <linux-mm@kvack.org>; Fri, 30 May 2008 01:44:52 -0600
Date: Fri, 30 May 2008 00:44:49 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 1/2] hugetlb: present information in sysfs
Message-ID: <20080530074449.GE5021@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net> <20080529063915.GC11357@us.ibm.com> <20080530025846.GC6007@kroah.com> <20080530033748.GA25792@wotan.suse.de> <20080530042107.GA7946@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080530042107.GA7946@kroah.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On 29.05.2008 [21:21:07 -0700], Greg KH wrote:
> On Fri, May 30, 2008 at 05:37:49AM +0200, Nick Piggin wrote:
> > On Thu, May 29, 2008 at 07:58:46PM -0700, Greg KH wrote:
> > > On Wed, May 28, 2008 at 11:39:15PM -0700, Nishanth Aravamudan wrote:
> > > > While the procfs presentation of the hstate counters has tried to be as
> > > > backwards compatible as possible, I do not believe trying to maintain
> > > > all of the information in the same files is a good long-term plan. This
> > > > particularly matters for architectures that can support many hugepage
> > > > sizes (sparc64 might be one). Even with the three potential pagesizes on
> > > > power (64k, 16m and 16g), I found the proc interface to be a little
> > > > awkward.
> > > > 
> > > > Instead, migrate the information to sysfs in a new directory,
> > > > /sys/kernel/hugepages. Underneath that directory there will be a
> > > > directory per-supported hugepage size, e.g.:
> > > > 
> > > > /sys/kernel/hugepages/hugepages-64
> > > > /sys/kernel/hugepages/hugepages-16384
> > > > /sys/kernel/hugepages/hugepages-16777216
> > > > 
> > > > corresponding to 64k, 16m and 16g respectively. Within each
> > > > hugepages-size directory there are a number of files, corresponding to
> > > > the tracked counters in the hstate, e.g.:
> > > > 
> > > > /sys/kernel/hugepages/hugepages-64/nr_hugepages
> > > > /sys/kernel/hugepages/hugepages-64/nr_overcommit_hugepages
> > > > /sys/kernel/hugepages/hugepages-64/free_hugepages
> > > > /sys/kernel/hugepages/hugepages-64/resv_hugepages
> > > > /sys/kernel/hugepages/hugepages-64/surplus_hugepages
> > > > 
> > > > Of these files, the first two are read-write and the latter three are
> > > > read-only. The size of the hugepage being manipulated is trivially
> > > > deducible from the enclosing directory and is always expressed in kB (to
> > > > match meminfo).
> > > > 
> > > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > > > 
> > > > ---
> > > > Nick, I tested this patch and the following one at this point the
> > > > series, that is between patches 7 and 8. This does require a few compile
> > > > fixes/patch modifications in the later parts of the series. If we decide
> > > > that 2/2 is undesirable, there will be fewer of those and 1/2 could also
> > > > apply at the end, with less work. I can send you that diff, if you'd
> > > > prefer.
> > > > 
> > > > Greg, I didn't hear back from you on the last posting of this patch. Not
> > > > intended as a complaint, just an indication of why I didn't make any
> > > > changes relative to that version. Does this seem like a reasonable
> > > > patch as far as using the sysfs API? I realize a follow-on patch will be
> > > > needed to updated Documentation/ABI.
> > > 
> > > I'm sorry, it got lost in the bowels of my inbox, my appologies.
> > > 
> > > This looks fine to me, nice job.  And yes, i do want to see the ABI
> > > addition as well :)
> > > 
> > > If you add that, feel free to add an:
> > > 	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> > > to the patch.
> > 
> > Thanks Greg. Nish will be away for a few weeks but I'm picking up his patch
> > and so I can add the Documentation/ABI change.
> > 
> > I agree the interface looks nice, so thanks to everyone for the input and
> > discussion. A minor nit: is there any point specifying units in the
> > hugepages directory names? hugepages-64K hugepages-16M hugepages-16G?
> > 
> > Or perhaps for easier parsing, they could be the same unit but still
> > specificied? hugepages-64K hugepages-16384K etc?
> 
> I don't care, nothing is going to parse the directory names, they are
> pretty much fixed, right?  Just pick a unit and stick with it :)

Well, sort of. libhuge will either parse sysfs or meminfo to see what
the supported hugepage sizes are. Really, it doesn't matter too much,
though, if meminfo contains the same information.

And they are only fixed per-arch, and only until someone needs the next
ginormous huge page size :)

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
