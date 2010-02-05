Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A3C836B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 06:20:20 -0500 (EST)
Date: Fri, 5 Feb 2010 11:20:00 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 15214] New: Oops at __rmqueue+0x51/0x2b3
Message-ID: <20100205112000.GD20412@csn.ul.ie>
References: <bug-15214-10286@http.bugzilla.kernel.org/> <20100203143921.f2c96e8c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100203143921.f2c96e8c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, ajlill@ajlc.waterloo.on.ca
List-ID: <linux-mm.kvack.org>

On Wed, Feb 03, 2010 at 02:39:21PM -0800, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed, 3 Feb 2010 02:30:22 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=15214
> > 
> >            Summary: Oops at __rmqueue+0x51/0x2b3
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.32.7
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Page Allocator
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: ajlill@ajlc.waterloo.on.ca
> >         Regression: Yes
> > 
> > 
> > Created an attachment (id=24887)
> >  --> (http://bugzilla.kernel.org/attachment.cgi?id=24887)
> > .config file
> > 
> > I get an Oops when doing a lot of filesystem reads. The process, cfagent, is
> > running through the filesystem checksumming files when it dies. It doesn't
> > happen every time cfagent runs, but there's a pretty good chance it will.
> > This problem happens on 2.6.31.* as well, 3.6.30.10 appears to be stable. It
> > happens on two different computers, so it's unlikely to be hardware. Also, in
> > 2.6.32.*, I get an Oops at
> > 
> >     BUG_ON(page_zone(start_page) != page_zone(end_page));
> > 
> > in move_freepages when I do sysctl -w vm.min_free_kbytes=16384
> > 
> > but I can only reliably reproduce it when I do the sysctl from the boot
> > scripts, and I'm having trouble getting netconsole started beforehand to
> > capture the full output.
> > 

This point on sysctl is truely bizarre. It implies that the struct pages
have been corrupted in some fashion. Just before this check is made, we
do

        /* Do not cross zone boundaries */
        if (start_pfn < zone->zone_start_pfn)
                start_page = page;
        if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages)
                return 0;

        return move_freepages(zone, start_page, end_page, migratetype);

So, for that bug to be triggered, two pages between 
zone->zone_start_pfn and
zone->zone_start_pfn + zone->spanned_pages
have to have different results for page_zone(). That would be outright
wrong.

Ordinarily at this point, I would assume that your memory is bad with
small errors occuring. The early-in-boot problem might indicate that
there is a specific region of memory that is bust rather than something
like a power problem.

You said that the checksumming problem happens on two separate machines,
but can you confirm that this problem also happens on both please?

> > gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
> > 

This is a bit of a reach, but how confident are you that this version of
gcc is building kernels correctly?

There are a few disconnected reports of kernel problems with this
particular version of gcc although none that I can connect with this
problem or on x86 for that matter. One example is

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=536354

which reported problems building kernels on the s390 with that compiler.
Moving to 4.2 helped them and it *should* have been fixed according to
this bug

http://bugzilla.kernel.org/show_bug.cgi?id=13012

It might be a red herring, but just to be sure, would you mind trying
gcc 4.2 or 4.3 just to be sure please?

> > Full text of Oops:
> > 
> > BUG: unable to handle kernel paging request at 6eae67fc
> > IP: [<c0192a38>] __rmqueue+0x51/0x2b3
> > *pdpt = 00000000351be001 *pde = 0000000000000000 
> > Oops: 0002 [#1] SMP 
> > last sysfs file: /sys/class/firmware/0000:00:0b.0/loading
> > Modules linked in: netconsole af_packet autofs4 nfsd nfs lockd fscache nfs_acl
> > auth_rpcgss sunrpc ipv6 nls_iso8859_1 nls_cp437 vfat fat xfs exportfs fuse
> > configfs dm_snapshot dm_mirror dm_region_hash dm_log dm_mod eeprom w83781d
> > hwmon_vid hwmon r128 drm tuner_simple tuner_types tuner msp3400 saa7115 button
> > processor ivtv i2c_algo_bit cx2341x v4l2_common videodev psmouse parport_pc
> > v4l1_compat rtc_cmos parport tveeprom i2c_piix4 rtc_core intel_agp serio_raw
> > rtc_lib agpgart i2c_core shpchp pci_hotplug pcspkr evdev ext3 jbd mbcache raid1
> > sg sr_mod sd_mod cdrom crc_t10dif ata_generic pata_acpi pata_pdc202xx_old
> > ata_piix floppy e1000 uhci_hcd libata thermal fan unix [last unloaded:
> > scsi_wait_scan]
> > 
> > Pid: 6629, comm: cfagent Not tainted (2.6.32.7 #1) System Name
> > EIP: 0060:[<c0192a38>] EFLAGS: 00210002 CPU: 0
> > EIP is at __rmqueue+0x51/0x2b3

What line does addr2line say c0192a38 corresponds to?

> > EAX: c146a018 EBX: 0000000a ECX: 6eae67f8 EDX: c050b654
> > ESI: c050b644 EDI: 00200246 EBP: f51c9d1c ESP: f51c9cec
> >  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> > Process cfagent (pid: 6629, ti=f51c8000 task=f51b40b0 task.ti=f51c8000)
> > Stack:
> >  00000002 00000000 c050b260 00000001 f6ba8280 00200002 c0193c92 c019404e
> > <0> c146a000 c1479ff8 c050b260 00200246 f51c9d78 c0193cd5 f51c9d7c 00000002
> > <0> 00000000 00000000 000201da c050c16c 00000000 c050b280 00000001 0000001f
> > Call Trace:
> >  [<c0193c92>] ? get_page_from_freelist+0xdf/0x3a8
> >  [<c019404e>] ? __alloc_pages_nodemask+0xdd/0x481
> >  [<c0193cd5>] ? get_page_from_freelist+0x122/0x3a8
> >  [<c019404e>] ? __alloc_pages_nodemask+0xdd/0x481
> >  [<c01caa57>] ? _d_rehash+0x3c/0x40
> >  [<c01961e3>] ? __do_page_cache_readahead+0x80/0x15b
> >  [<c01cb95f>] ? __d_lookup+0xa1/0xd5
> >  [<c01962d5>] ? ra_submit+0x17/0x1c
> >  [<c01964e4>] ? ondemand_readahead+0x150/0x15c
> >  [<c0196569>] ? page_cache_sync_readahead+0x16/0x1b
> >  [<c0190def>] ? generic_file_aio_read+0x212/0x507
> >  [<c01bd512>] ? do_sync_read+0xab/0xe9
> >  [<c01a86f5>] ? mmap_region+0x25b/0x334
> >  [<c014823f>] ? autoremove_wake_function+0x0/0x33
> >  [<c020edd8>] ? security_file_permission+0xf/0x11
> >  [<c01bd467>] ? do_sync_read+0x0/0xe9
> >  [<c01bdc1d>] ? vfs_read+0x8a/0x13f
> >  [<c01be026>] ? sys_read+0x3b/0x60
> >  [<c010296f>] ? sysenter_do_call+0x12/0x27
> > Code: 2c c1 e1 03 8d 94 30 20 02 00 00 e9 8a 00 00 00 8d 72 0c 8d 04 0e 39 00
> > 74 7c 8b 55 d0 8b 04 d6 8d 48 e8 89 4d f0 8b 08 8b 50 04 <89> 51 04 89 0a c7 40
> > 04 00 02 20 00 c7 00 00 01 10 00 0f ba 70 
> > EIP: [<c0192a38>] __rmqueue+0x51/0x2b3 SS:ESP 0068:f51c9cec
> > CR2: 000000006eae67fc
> > ---[ end trace db0096b2091950d0 ]---
> > 
> 
> Strange regression.  I'd be suspecting that we've mucked up the initial
> mem_map, perhaps because of a wart in the e820 or acpi tables.
> 
> Or perhaps it's something else.
> 

Lets see what the early boot looked like.

Tony, would you mind booting with "mminit_loglevel=4 loglevel=9" and send
the full dmesg please?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
