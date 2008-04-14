Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3EL58RQ006479
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:05:08 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3EL58DW253034
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:05:08 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3EL58SX023783
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 17:05:08 -0400
Date: Mon, 14 Apr 2008 14:05:06 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080414210506.GA6350@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080413034136.GA22686@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.04.2008 [20:41:36 -0700], Greg KH wrote:
> On Sat, Apr 12, 2008 at 11:41:18AM +0200, Nick Piggin wrote:
> > On Fri, Apr 11, 2008 at 04:56:48PM -0700, Greg KH wrote:
> > > On Fri, Apr 11, 2008 at 04:49:13PM -0700, Nishanth Aravamudan wrote:
> > > > /sys/devices/system/node represents the current NUMA configuration of
> > > > the machine, but is undocumented in the ABI files. Add bare-bones
> > > > documentation for these files.
> > > > 
> > > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > > > 
> > > > ---
> > > > Greg, is something like this what you'd want?
> > > 
> > > Yes it is, thanks for doing it.
> > 
> > Can you comment on the aspect of configuring various kernel hugetlb 
> > configuration parameters? Especifically, what directory it should go in?
> > IMO it should be /sys/kernel/*
> 
> I don't really know.
> 
> > /sys/devices/system/etc should be fine eg. for showing how many pages are
> > available in a given node, or what kinds of TLBs the CPU has, but I would
> > have thought that configuring the kernel's hugetlb settings should be
> > in /sys/kernel.
> 
> /sys/devices/system are for "sysdev" devices, a breed of device
> structures that are problimatic to use, and are on my TODO list to
> rework.  If you need a hugetlb paramter to be tied to a cpu or other
> system device, then it should go under here.
> 
> Otherwise, if it is just a "system wide" parameter, then put it in
> /sys/kernel/

We have both, and that's kind of where things are being discussed right
now.

Currently, we have:

/proc/sys/vm/nr_hugepages
/proc/sys/vm/nr_overcommit_hugepages

which are global sysctls.

My patchset would add:

/sys/devices/system/node/nodeX/nr_hugepages

to allow for finer-grained control of the hugetlb pool allocation.

Nick/Andi's patchset would modify /proc/sys/vm/nr_hugepages to allow
specifying the pool sizes for multiple hugepage sizes.

To make my patchset and Nick's work well together, I think we'd need a
per-node, per-hugepage-size interface in sysfs. I pointed out to Nick
that it might be better to make the extended interface (supporting
multiple hugepage sizes) be in sysfs altogether, and leave
/proc/sys/vm/nr_hugepages alone (as only controlling the default
hugepage size).

That would leave us with [1]:

/sys/kernel/nr_hugepages --> nr_hugepages_2M
/sys/kernel/nr_hugepages_2M
/sys/kernel/nr_hugepages_1G
/sys/kernel/nr_overcommit_hugepages --> nr_overcommit_hugepages_2M
/sys/kernel/nr_overcommit_hugepages_2M
/sys/kernel/nr_overcommit_hugepages_1G

and [2]

/sys/devices/system/node/nodeX/nr_hugepages --> nr_hugepages_2M
/sys/devices/system/node/nodeX/nr_hugepages_2M
/sys/devices/system/node/nodeX/nr_hugepages_1G

The questions I see are (with my answers):

Is this separation correct?

	- I believe this puts the globals in one place and the per-nodes
	  in another (both of which are correct) keeping things
	  accurate. The per-node interface would be the first writable
	  attribute in /sys/devices/system/node, though.

Is this separation confusing to an administrator?

	- Similar to the previous question, I think the separation
	  corresponds well to the system's layout.

Is there a better way of presenting these attributes?

	- Nick's alternative was to (I think, please CMIIW) have:

	/sys/kernel/hugetlb/2M/nr_hugepages
	/sys/kernel/hugetlb/2M/nr_overcommit_hugepages
	/sys/kernel/hugetlb/2M/nodeX/nr_hugepages
	/sys/kernel/hugetlb/2M/nodeX/nr_overcommit_hugepages

	with perhaps symlinks in /sys/kernel/ or /sys/kernel/hugetlb
	directly to the default pools. And similar diretories/files for
	1G pages. This seems like a lot of duplication of the NUMA
	layout, but I can see it also being better in that all of the
	hugetlb-related interface is in one place. [3]

Do you see a particular more-sysfs-way here, Greg?

Thanks for reading this particularly long e-mail,
Nish

[1] Nick suggested using directories in /sys/kernel per-hugepage-size,
but I'm not sure how they should be named, so I went with the simpler
filename-style, to make the point clearer.

[2] I have a patch to allow for per-node dynamic pool control, but it's
pretty gross. Right now, we let the memory policy enforce where we get
hugepages from, presuming we can allocate there. If we had per-node
control, we'd need some way to specify a restriction on how many
hugepages can be allocated on a particular node down to alloc_pages, or
use a round-robin style, which would probably break mempolicies. For
now, I've let the patch alone while I try to find a better way.

[3] Is there an in-between, perhaps, that we could have the real files
in /sys/devices/system/node, but have symlinks, like
/sys/kernel/hugetlb/nodeX/nr_hugepages_2M -->
/sys/devices/system/node/nodeX/nr_hugepages_2M ? That seems like
overkill...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
