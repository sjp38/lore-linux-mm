Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id BA6B06B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 05:51:42 -0400 (EDT)
Date: Thu, 25 Oct 2012 10:44:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: memmap_init_zone() performance improvement
Message-ID: <20121025094410.GA2558@suse.de>
References: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com>
 <20121008151656.GM29125@suse.de>
 <1349794597.29752.10.camel@MikesLinux.fc.hp.com>
 <1350676398.1169.6.camel@MikesLinux.fc.hp.com>
 <20121020082858.GA2698@suse.de>
 <1351093667.1205.11.camel@MikesLinux.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1351093667.1205.11.camel@MikesLinux.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Yoknis <mike.yoknis@hp.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, mmarek@suse.cz, tglx@linutronix.de, hpa@zytor.com, arnd@arndb.de, sam@ravnborg.org, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 24, 2012 at 09:47:47AM -0600, Mike Yoknis wrote:
> On Sat, 2012-10-20 at 09:29 +0100, Mel Gorman wrote:
> > On Fri, Oct 19, 2012 at 01:53:18PM -0600, Mike Yoknis wrote:
> > > On Tue, 2012-10-09 at 08:56 -0600, Mike Yoknis wrote:
> > > > On Mon, 2012-10-08 at 16:16 +0100, Mel Gorman wrote:
> > > > > On Wed, Oct 03, 2012 at 08:56:14AM -0600, Mike Yoknis wrote:
> > > > > > memmap_init_zone() loops through every Page Frame Number (pfn),
> > > > > > including pfn values that are within the gaps between existing
> > > > > > memory sections.  The unneeded looping will become a boot
> > > > > > performance issue when machines configure larger memory ranges
> > > > > > that will contain larger and more numerous gaps.
> > > > > > 
> > > > > > The code will skip across invalid sections to reduce the
> > > > > > number of loops executed.
> > > > > > 
> > > > > > Signed-off-by: Mike Yoknis <mike.yoknis@hp.com>
> > > > > 
> > > > > I do not see the need for
> > > > > the additional complexity unless you can show it makes a big difference
> > > > > to boot times.
> > > > > 
> > > > 
> > > > Mel,
> > > > 
> > > > Let me pass along the numbers I have.  We have what we call an
> > > > "architectural simulator".  It is a computer program that pretends that
> > > > it is a computer system.  We use it to test the firmware before real
> > > > hardware is available.  We have booted Linux on our simulator.  As you
> > > > would expect it takes longer to boot on the simulator than it does on
> > > > real hardware.
> > > > 
> > > > With my patch - boot time 41 minutes
> > > > Without patch - boot time 94 minutes
> > > > 
> > > > These numbers do not scale linearly to real hardware.  But indicate to
> > > > me a place where Linux can be improved.
> > > > 
> > > > Mike Yoknis
> > > > 
> > > Mel,
> > > I finally got access to prototype hardware.  
> > > It is a relatively small machine with only 64GB of RAM.
> > >  
> > > I put in a time measurement by reading the TSC register.
> > > I booted both with and without my patch -
> > >  
> > > Without patch -
> > > [    0.000000]   Normal zone: 13400064 pages, LIFO batch:31
> > > [    0.000000] memmap_init_zone() enter 1404184834218
> > > [    0.000000] memmap_init_zone() exit  1411174884438  diff = 6990050220
> > >  
> > > With patch -
> > > [    0.000000]   Normal zone: 13400064 pages, LIFO batch:31
> > > [    0.000000] memmap_init_zone() enter 1555530050778
> > > [    0.000000] memmap_init_zone() exit  1559379204643  diff = 3849153865
> > >  
> > > This shows that without the patch the routine spends 45% 
> > > of its time spinning unnecessarily.
> > >  
> > 
> > I'm travelling at the moment so apologies that I have not followed up on
> > this. My problem is still the same with the patch - it changes more
> > headers than is necessary and it is sparsemem specific. At minimum, try
> > the suggestion of 
> > 
> > if (!early_pfn_valid(pfn)) {
> >       pfn = ALIGN(pfn + MAX_ORDER_NR_PAGES, MAX_ORDER_NR_PAGES) - 1;
> >       continue;
> > }
> > 
> > and see how much it gains you as it should work on all memory models. If
> > it turns out that you really need to skip whole sections then the strice
> > could MAX_ORDER_NR_PAGES on all memory models except sparsemem where the
> > stride would be PAGES_PER_SECTION
> > 
> Mel,
> I tried your suggestion.  I re-ran all 3 methods on our latest firmware.
> 
> The following are TSC difference numbers (*10^6) to execute
> memmap_init_zone() -
> 
> No patch   - 7010
> Mel's patch- 3918
> My patch   - 3847
> 
> The incremental improvement of my method is not significant vs. yours.
> 
> If you believe your suggested change is worthwhile I will create a v2
> patch.

I think it is a reasonable change and I prefer my suggestion because it
should work for all memory models. Please do a V2 of the patch. I'm still
travelling at the moment (writing this from an airport) but I'll be back
online next Tuesday and will review it when I can.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
