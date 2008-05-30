Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4UDeYgN027210
	for <linux-mm@kvack.org>; Fri, 30 May 2008 09:40:34 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4UDeMO1049178
	for <linux-mm@kvack.org>; Fri, 30 May 2008 07:40:22 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4UDeLoX020418
	for <linux-mm@kvack.org>; Fri, 30 May 2008 07:40:22 -0600
Subject: Re: [RFC][PATCH 1/2] hugetlb: present information in sysfs
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080530033748.GA25792@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143452.841211000@nick.local0.net>
	 <20080529063915.GC11357@us.ibm.com> <20080530025846.GC6007@kroah.com>
	 <20080530033748.GA25792@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 30 May 2008 08:40:19 -0500
Message-Id: <1212154819.13234.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Greg KH <greg@kroah.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-05-30 at 05:37 +0200, Nick Piggin wrote:
> On Thu, May 29, 2008 at 07:58:46PM -0700, Greg KH wrote:
> > On Wed, May 28, 2008 at 11:39:15PM -0700, Nishanth Aravamudan wrote:
> > > While the procfs presentation of the hstate counters has tried to be as
> > > backwards compatible as possible, I do not believe trying to maintain
> > > all of the information in the same files is a good long-term plan. This
> > > particularly matters for architectures that can support many hugepage
> > > sizes (sparc64 might be one). Even with the three potential pagesizes on
> > > power (64k, 16m and 16g), I found the proc interface to be a little
> > > awkward.
> > > 
> > > Instead, migrate the information to sysfs in a new directory,
> > > /sys/kernel/hugepages. Underneath that directory there will be a
> > > directory per-supported hugepage size, e.g.:
> > > 
> > > /sys/kernel/hugepages/hugepages-64
> > > /sys/kernel/hugepages/hugepages-16384
> > > /sys/kernel/hugepages/hugepages-16777216
> > > 
> > > corresponding to 64k, 16m and 16g respectively. Within each
> > > hugepages-size directory there are a number of files, corresponding to
> > > the tracked counters in the hstate, e.g.:
> > > 
> > > /sys/kernel/hugepages/hugepages-64/nr_hugepages
> > > /sys/kernel/hugepages/hugepages-64/nr_overcommit_hugepages
> > > /sys/kernel/hugepages/hugepages-64/free_hugepages
> > > /sys/kernel/hugepages/hugepages-64/resv_hugepages
> > > /sys/kernel/hugepages/hugepages-64/surplus_hugepages
> > > 
> > > Of these files, the first two are read-write and the latter three are
> > > read-only. The size of the hugepage being manipulated is trivially
> > > deducible from the enclosing directory and is always expressed in kB (to
> > > match meminfo).
> > > 
> > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > > 
> > > ---
> > > Nick, I tested this patch and the following one at this point the
> > > series, that is between patches 7 and 8. This does require a few compile
> > > fixes/patch modifications in the later parts of the series. If we decide
> > > that 2/2 is undesirable, there will be fewer of those and 1/2 could also
> > > apply at the end, with less work. I can send you that diff, if you'd
> > > prefer.
> > > 
> > > Greg, I didn't hear back from you on the last posting of this patch. Not
> > > intended as a complaint, just an indication of why I didn't make any
> > > changes relative to that version. Does this seem like a reasonable
> > > patch as far as using the sysfs API? I realize a follow-on patch will be
> > > needed to updated Documentation/ABI.
> > 
> > I'm sorry, it got lost in the bowels of my inbox, my appologies.
> > 
> > This looks fine to me, nice job.  And yes, i do want to see the ABI
> > addition as well :)
> > 
> > If you add that, feel free to add an:
> > 	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> > to the patch.
> 
> Thanks Greg. Nish will be away for a few weeks but I'm picking up his patch
> and so I can add the Documentation/ABI change.
> 
> I agree the interface looks nice, so thanks to everyone for the input and
> discussion. A minor nit: is there any point specifying units in the
> hugepages directory names? hugepages-64K hugepages-16M hugepages-16G?
> 
> Or perhaps for easier parsing, they could be the same unit but still
> specificied? hugepages-64K hugepages-16384K etc?

Just my two cents, but I would prefer to either leave them as-is, or to
append the K suffix to all values.  I don't think mixing the K/M/G units
buys enough user-friendliness to justify the extra complexity on the
kernel side and in programs that will work with these directories.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
