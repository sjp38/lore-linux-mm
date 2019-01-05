Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB9048E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 22:45:03 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b16so45948749qtc.22
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 19:45:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r30si763900qtd.209.2019.01.04.19.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 19:45:02 -0800 (PST)
Date: Sat, 5 Jan 2019 11:44:50 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCHv3 1/2] mm/memblock: extend the limit inferior of
 bottom-up after parsing hotplug attr
Message-ID: <20190105034450.GE30750@MiWiFi-R3L-srv>
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-2-git-send-email-kernelfans@gmail.com>
 <20181231084018.GA28478@rapoport-lnx>
 <CAFgQCTvQnj7zReFvH_gmfVJdPXE325o+z4Xx76fupvsLR_7H2A@mail.gmail.com>
 <20190102092749.GA22664@rapoport-lnx>
 <20190102101804.GD1990@MiWiFi-R3L-srv>
 <20190102170537.GA3591@rapoport-lnx>
 <20190103184706.GU2509588@devbig004.ftw2.facebook.com>
 <20190104150929.GA32252@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190104150929.GA32252@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Tejun Heo <tj@kernel.org>, Pingfan Liu <kernelfans@gmail.com>, linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

On 01/04/19 at 05:09pm, Mike Rapoport wrote:
> On Thu, Jan 03, 2019 at 10:47:06AM -0800, Tejun Heo wrote:
> > Hello,
> > 
> > On Wed, Jan 02, 2019 at 07:05:38PM +0200, Mike Rapoport wrote:
> > > I agree that currently the bottom-up allocation after the kernel text has
> > > issues with KASLR. But this issues are not necessarily related to the
> > > memory hotplug. Even with a single memory node, a bottom-up allocation will
> > > fail if KASLR would put the kernel near the end of node0.
> > > 
> > > What I am trying to understand is whether there is a fundamental reason to
> > > prevent allocations from [0, kernel_start)?
> > > 
> > > Maybe Tejun can recall why he suggested to start bottom-up allocations from
> > > kernel_end.
> > 
> > That's from 79442ed189ac ("mm/memblock.c: introduce bottom-up
> > allocation mode").  I wasn't involved in that patch, so no idea why
> > the restrictions were added, but FWIW it doesn't seem necessary to me.
> 
> I should have added the reference [1] at the first place :)
> Thanks!
> 
> [1] https://lore.kernel.org/lkml/20130904192215.GG26609@mtj.dyndns.org/

With my understanding, we may not be able to discard the bottom-up
method for the current kernel. It's related to hotplug feature when
'movable_node' kernel parameter is specified. With 'movable_node',
system relies on reading hotplug information from firmware, on x86 it's
acpi SRAT table. In the current system, we allocate memblock region
top-down by default. However, before that hotplug information retrieving,
there are several places of memblock allocating, top-down memblock
allocation must break hotplug feature since it will allocate kernel data
in movable zone which is usually at the end node on bare metal system.

This bottom-up way is taken on many ARCHes, it works well on system if
KASLR is not enabled. Below is the searching result in the current linux
kernel, we can see that all ARCHes have this mechanism, except of
arm/arm64. But now only arm64/mips/x86 have KASLR.

W/o KASLR, allocating memblock region above kernle end when hotplug info
is not parsed, looks very reasonable. Since kernel is usually put at
lower address, e.g on x86, it's 16M. My thought is that we need do
memblock allocation around kernel before hotplug info parsed. That is
for system w/o KASLR, we will keep the current bottom-up way; for system
with KASLR, we should allocate memblock region top-down just below
kernel start.

This issue must break hotplug, just because currently bare metal system
need add 'nokaslr' to disable KASLR since another bug fix is under
discussion as below, so this issue is covered up.

 [PATCH v14 0/5] x86/boot/KASLR: Parse ACPI table and limit KASLR to choosing immovable memory
lkml.kernel.org/r/20181214093013.13370-1-fanc.fnst@cn.fujitsu.com

[~ ]$ git grep memblock_set_bottom_up
arch/alpha/kernel/setup.c:      memblock_set_bottom_up(true);
arch/m68k/mm/motorola.c:        memblock_set_bottom_up(true);
arch/mips/kernel/setup.c:       memblock_set_bottom_up(true);
arch/mips/kernel/traps.c:       memblock_set_bottom_up(false);
arch/nds32/kernel/setup.c:      memblock_set_bottom_up(true);
arch/powerpc/kernel/paca.c:             memblock_set_bottom_up(true);
arch/powerpc/kernel/paca.c:             memblock_set_bottom_up(false);
arch/s390/kernel/setup.c:       memblock_set_bottom_up(true);
arch/s390/kernel/setup.c:       memblock_set_bottom_up(false);
arch/sparc/mm/init_32.c:        memblock_set_bottom_up(true);
arch/x86/kernel/setup.c:                memblock_set_bottom_up(true);
arch/x86/mm/numa.c:     memblock_set_bottom_up(false);
include/linux/memblock.h:static inline void __init memblock_set_bottom_up(bool enable)
