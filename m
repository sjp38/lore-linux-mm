Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id BB3616B0088
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 15:53:25 -0400 (EDT)
Message-ID: <1350676398.1169.6.camel@MikesLinux.fc.hp.com>
Subject: Re: [PATCH] mm: memmap_init_zone() performance improvement
From: Mike Yoknis <mike.yoknis@hp.com>
Reply-To: mike.yoknis@hp.com
Date: Fri, 19 Oct 2012 13:53:18 -0600
In-Reply-To: <1349794597.29752.10.camel@MikesLinux.fc.hp.com>
References: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com>
	 <20121008151656.GM29125@suse.de>
	 <1349794597.29752.10.camel@MikesLinux.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: mingo@redhat.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, mmarek@suse.cz, tglx@linutronix.de, hpa@zytor.com, arnd@arndb.de, sam@ravnborg.org, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2012-10-09 at 08:56 -0600, Mike Yoknis wrote:
> On Mon, 2012-10-08 at 16:16 +0100, Mel Gorman wrote:
> > On Wed, Oct 03, 2012 at 08:56:14AM -0600, Mike Yoknis wrote:
> > > memmap_init_zone() loops through every Page Frame Number (pfn),
> > > including pfn values that are within the gaps between existing
> > > memory sections.  The unneeded looping will become a boot
> > > performance issue when machines configure larger memory ranges
> > > that will contain larger and more numerous gaps.
> > > 
> > > The code will skip across invalid sections to reduce the
> > > number of loops executed.
> > > 
> > > Signed-off-by: Mike Yoknis <mike.yoknis@hp.com>
> > 
> > I do not see the need for
> > the additional complexity unless you can show it makes a big difference
> > to boot times.
> > 
> 
> Mel,
> 
> Let me pass along the numbers I have.  We have what we call an
> "architectural simulator".  It is a computer program that pretends that
> it is a computer system.  We use it to test the firmware before real
> hardware is available.  We have booted Linux on our simulator.  As you
> would expect it takes longer to boot on the simulator than it does on
> real hardware.
> 
> With my patch - boot time 41 minutes
> Without patch - boot time 94 minutes
> 
> These numbers do not scale linearly to real hardware.  But indicate to
> me a place where Linux can be improved.
> 
> Mike Yoknis
> 
Mel,
I finally got access to prototype hardware.  
It is a relatively small machine with only 64GB of RAM.
 
I put in a time measurement by reading the TSC register.
I booted both with and without my patch -
 
Without patch -
[    0.000000]   Normal zone: 13400064 pages, LIFO batch:31
[    0.000000] memmap_init_zone() enter 1404184834218
[    0.000000] memmap_init_zone() exit  1411174884438  diff = 6990050220
 
With patch -
[    0.000000]   Normal zone: 13400064 pages, LIFO batch:31
[    0.000000] memmap_init_zone() enter 1555530050778
[    0.000000] memmap_init_zone() exit  1559379204643  diff = 3849153865
 
This shows that without the patch the routine spends 45% 
of its time spinning unnecessarily.
 
Mike Yoknis


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
