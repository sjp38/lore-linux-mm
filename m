Date: Wed, 13 Feb 2008 15:38:29 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 9941] New: Zone "Normal" missing in /proc/zoneinfo
Message-ID: <20080213153829.GB1328@csn.ul.ie>
References: <bug-9941-27@http.bugzilla.kernel.org/> <20080212100623.4fd6cf85.akpm@linux-foundation.org> <e2e108260802122339j3b861e74vf7b72a34747dcade@mail.gmail.com> <20080212234522.24bed8c1.akpm@linux-foundation.org> <20080213115225.GB4007@csn.ul.ie> <20080213152302.GA32416@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080213152302.GA32416@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bart Van Assche <bart.vanassche@gmail.com>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (13/02/08 15:23), Andy Whitcroft didst pronounce:
> On Wed, Feb 13, 2008 at 11:52:25AM +0000, Mel Gorman wrote:
> 
> > > > > > $ grep zone /proc/zoneinfo
> > > > > >
> > > > > > Output with 2.6.24:
> > > > > > Node 0, zone      DMA
> > > > > > Node 0, zone    DMA32
> > > > > > Node 0, zone   Normal
> > > > > >
> > > > > > Output with 2.6.24.2:
> > > > > > Node 0, zone      DMA
> > > > > > Node 0, zone    DMA32
> > > > > >
> > 
> > The greater surprise to me is that "Normal" ever appeared. The zone is empty,
> > why is information appearing about it? I checked the dmesg for an x86_64
> > machine with 1GB of RAM that was running 2.6.24 here and there is no sign
> > of Normal.
> > 
> > mel@arnold:/tmp$ grep zone zoneinfo.before 
> > Node 0, zone      DMA
> > Node 0, zone    DMA32
> > 
> > The loop looks like
> > 
> >         for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
> >                 if (!populated_zone(zone))
> >                         continue;
> > 
> > It makes no sense for it to show up *unless* 2.6.24 was compiled as a 32
> > bit kernel by accident. Could this be the case?
> 
> Interestingly I would not expect to see DMA32 at all if the kernel was
> compiled 32 bit as CONFIG_DMA32 defaults to X86_64.
> 

D'oh, of course. This couldn't have been a 32 bit kernel.

> Could we simply have less ram detected/present in this boot.  That would
> make the zone dissappear if it became empty.
> 
> The e820 output as reported by the old and new kernels would confirm the
> memory size is detected the same.  Also some idea of how much memory is
> supposed be in the machine might shed some light.  If the overall is near
> to 4GB it may be remapping for the AGP apature or something similar which
> is shifting memory up above the boundary.
> 


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
