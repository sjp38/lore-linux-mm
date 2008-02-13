Date: Wed, 13 Feb 2008 11:52:25 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 9941] New: Zone "Normal" missing in /proc/zoneinfo
Message-ID: <20080213115225.GB4007@csn.ul.ie>
References: <bug-9941-27@http.bugzilla.kernel.org/> <20080212100623.4fd6cf85.akpm@linux-foundation.org> <e2e108260802122339j3b861e74vf7b72a34747dcade@mail.gmail.com> <20080212234522.24bed8c1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080212234522.24bed8c1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bart Van Assche <bart.vanassche@gmail.com>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (12/02/08 23:45), Andrew Morton didst pronounce:
> On Wed, 13 Feb 2008 08:39:30 +0100 "Bart Van Assche" <bart.vanassche@gmail.com> wrote:
> 
> > On Feb 12, 2008 7:06 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > On Tue, 12 Feb 2008 02:39:40 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> > >
> > > > http://bugzilla.kernel.org/show_bug.cgi?id=9941
> > > >
> > > >            Summary: Zone "Normal" missing in /proc/zoneinfo
> > > >            Product: Memory Management
> > > >            Version: 2.5
> > > >      KernelVersion: 2.6.24.2
> > > >           Platform: All
> > > >         OS/Version: Linux
> > > >               Tree: Mainline
> > > >             Status: NEW
> > > >           Severity: normal
> > > >           Priority: P1
> > > >          Component: Other
> > > >         AssignedTo: akpm@osdl.org
> > > >         ReportedBy: bart.vanassche@gmail.com
> > > >
> > > >
> > > > Latest working kernel version: 2.6.24
> > > > Earliest failing kernel version: 2.6.24.2
> > > > Distribution: Ubuntu 7.10 server
> > > > Hardware Environment: Intel S5000PAL
> > > > Software Environment:
> > > > Problem Description:
> > > >
> > > > There is only information about the zones "DMA" and "DMA32" in /proc/zoneinfo,
> > > > not about zone "Normal".
> > > >
> > > > Steps to reproduce:
> > > >
> > > > Run the following command in a shell:
> > > > $ grep zone /proc/zoneinfo
> > > >
> > > > Output with 2.6.24:
> > > > Node 0, zone      DMA
> > > > Node 0, zone    DMA32
> > > > Node 0, zone   Normal
> > > >
> > > > Output with 2.6.24.2:
> > > > Node 0, zone      DMA
> > > > Node 0, zone    DMA32
> > > >

The greater surprise to me is that "Normal" ever appeared. The zone is empty,
why is information appearing about it? I checked the dmesg for an x86_64
machine with 1GB of RAM that was running 2.6.24 here and there is no sign
of Normal.

mel@arnold:/tmp$ grep zone zoneinfo.before 
Node 0, zone      DMA
Node 0, zone    DMA32

The loop looks like

        for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
                if (!populated_zone(zone))
                        continue;

It makes no sense for it to show up *unless* 2.6.24 was compiled as a 32
bit kernel by accident. Could this be the case?

> > <SNIP>
> > Zone PFN ranges:
> >   DMA             0 ->     4096
> >   DMA32        4096 ->  1048576
> >   Normal    1048576 ->  1048576
> > Movable zone start PFN for each node
> > early_node_map[6] active PFN ranges
> >     0:        0 ->      159
> >     0:      256 ->   516825
> >     0:   517019 ->   522802
> >     0:   522906 ->   522956
> >     0:   523034 ->   523046
> >     0:   523066 ->   523264
> > On node 0 totalpages: 522771
> >   DMA zone: 96 pages used for memmap
> >   DMA zone: 2170 pages reserved
> >   DMA zone: 1733 pages, LIFO batch:0
> >   DMA32 zone: 12168 pages used for memmap
> >   DMA32 zone: 506604 pages, LIFO batch:31
> >   Normal zone: 0 pages used for memmap
> >   Movable zone: 0 pages used for memmap
> 
> OK, that machine really has no ZONE_NORMAL.  I didn't know we do that.
> 

On x86_64 (which is what it is according to the config), machines with less
than 4GB of RAM will have no ZONE_NORMAL. This machine appears to have 2GB. I
don't see the problem as such because it's like PPC64 only having ZONE_DMA
(ZONE_NORMAL exists but it is always empty).

> Mel, is this, uh, normal?
> 

On x86_64, it is.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
