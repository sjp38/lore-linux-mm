Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F339A8E00F9
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 01:28:02 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id p79so46688239qki.15
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 22:28:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l13si4437649qtq.121.2019.01.05.22.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 22:28:01 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x066OBN3144388
	for <linux-mm@kvack.org>; Sun, 6 Jan 2019 01:28:01 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2puaqdb0h2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 06 Jan 2019 01:28:00 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 6 Jan 2019 06:27:46 -0000
Date: Sun, 6 Jan 2019 08:27:34 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCHv3 1/2] mm/memblock: extend the limit inferior of
 bottom-up after parsing hotplug attr
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-2-git-send-email-kernelfans@gmail.com>
 <20181231084018.GA28478@rapoport-lnx>
 <CAFgQCTvQnj7zReFvH_gmfVJdPXE325o+z4Xx76fupvsLR_7H2A@mail.gmail.com>
 <20190102092749.GA22664@rapoport-lnx>
 <20190102101804.GD1990@MiWiFi-R3L-srv>
 <20190102170537.GA3591@rapoport-lnx>
 <20190103184706.GU2509588@devbig004.ftw2.facebook.com>
 <20190104150929.GA32252@rapoport-lnx>
 <20190105034450.GE30750@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190105034450.GE30750@MiWiFi-R3L-srv>
Message-Id: <20190106062733.GA3728@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Pingfan Liu <kernelfans@gmail.com>, linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

On Sat, Jan 05, 2019 at 11:44:50AM +0800, Baoquan He wrote:
> On 01/04/19 at 05:09pm, Mike Rapoport wrote:
> > On Thu, Jan 03, 2019 at 10:47:06AM -0800, Tejun Heo wrote:
> > > Hello,
> > > 
> > > On Wed, Jan 02, 2019 at 07:05:38PM +0200, Mike Rapoport wrote:
> > > > I agree that currently the bottom-up allocation after the kernel text has
> > > > issues with KASLR. But this issues are not necessarily related to the
> > > > memory hotplug. Even with a single memory node, a bottom-up allocation will
> > > > fail if KASLR would put the kernel near the end of node0.
> > > > 
> > > > What I am trying to understand is whether there is a fundamental reason to
> > > > prevent allocations from [0, kernel_start)?
> > > > 
> > > > Maybe Tejun can recall why he suggested to start bottom-up allocations from
> > > > kernel_end.
> > > 
> > > That's from 79442ed189ac ("mm/memblock.c: introduce bottom-up
> > > allocation mode").  I wasn't involved in that patch, so no idea why
> > > the restrictions were added, but FWIW it doesn't seem necessary to me.
> > 
> > I should have added the reference [1] at the first place :)
> > Thanks!
> > 
> > [1] https://lore.kernel.org/lkml/20130904192215.GG26609@mtj.dyndns.org/
> 
> With my understanding, we may not be able to discard the bottom-up
> method for the current kernel. It's related to hotplug feature when
> 'movable_node' kernel parameter is specified. With 'movable_node',
> system relies on reading hotplug information from firmware, on x86 it's
> acpi SRAT table. In the current system, we allocate memblock region
> top-down by default. However, before that hotplug information retrieving,
> there are several places of memblock allocating, top-down memblock
> allocation must break hotplug feature since it will allocate kernel data
> in movable zone which is usually at the end node on bare metal system.

I do not suggest to discard the bottom-up method, I merely suggest to allow
it to use [0, kernel_start).
 
> This bottom-up way is taken on many ARCHes, it works well on system if
> KASLR is not enabled. Below is the searching result in the current linux
> kernel, we can see that all ARCHes have this mechanism, except of
> arm/arm64. But now only arm64/mips/x86 have KASLR.
> 
> W/o KASLR, allocating memblock region above kernle end when hotplug info
> is not parsed, looks very reasonable. Since kernel is usually put at
> lower address, e.g on x86, it's 16M. My thought is that we need do
> memblock allocation around kernel before hotplug info parsed. That is
> for system w/o KASLR, we will keep the current bottom-up way; for system
> with KASLR, we should allocate memblock region top-down just below
> kernel start.

I completely agree. I was thinking about making
memblock_find_in_range_node() to do something like

if (memblock_bottom_up()) {
	bottom_up_start = max(start, kernel_end);

	ret = __memblock_find_range_bottom_up(bottom_up_start, end,
					      size, align, nid, flags);
	if (ret)
		return ret;

	bottom_up_start = max(start, 0);
	end = kernel_start;

	ret = __memblock_find_range_top_down(bottom_up_start, end,
					     size, align, nid, flags);
	if (ret)
		return ret;
}

 
> This issue must break hotplug, just because currently bare metal system
> need add 'nokaslr' to disable KASLR since another bug fix is under
> discussion as below, so this issue is covered up.
> 
>  [PATCH v14 0/5] x86/boot/KASLR: Parse ACPI table and limit KASLR to choosing immovable memory
> lkml.kernel.org/r/20181214093013.13370-1-fanc.fnst@cn.fujitsu.com
> 
> [~ ]$ git grep memblock_set_bottom_up
> arch/alpha/kernel/setup.c:      memblock_set_bottom_up(true);
> arch/m68k/mm/motorola.c:        memblock_set_bottom_up(true);
> arch/mips/kernel/setup.c:       memblock_set_bottom_up(true);
> arch/mips/kernel/traps.c:       memblock_set_bottom_up(false);
> arch/nds32/kernel/setup.c:      memblock_set_bottom_up(true);
> arch/powerpc/kernel/paca.c:             memblock_set_bottom_up(true);
> arch/powerpc/kernel/paca.c:             memblock_set_bottom_up(false);
> arch/s390/kernel/setup.c:       memblock_set_bottom_up(true);
> arch/s390/kernel/setup.c:       memblock_set_bottom_up(false);
> arch/sparc/mm/init_32.c:        memblock_set_bottom_up(true);
> arch/x86/kernel/setup.c:                memblock_set_bottom_up(true);
> arch/x86/mm/numa.c:     memblock_set_bottom_up(false);
> include/linux/memblock.h:static inline void __init memblock_set_bottom_up(bool enable)
> 

-- 
Sincerely yours,
Mike.
