Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id EF4026B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 10:56:54 -0400 (EDT)
Message-ID: <1349794597.29752.10.camel@MikesLinux.fc.hp.com>
Subject: Re: [PATCH] mm: memmap_init_zone() performance improvement
From: Mike Yoknis <mike.yoknis@hp.com>
Reply-To: mike.yoknis@hp.com
Date: Tue, 09 Oct 2012 08:56:37 -0600
In-Reply-To: <20121008151656.GM29125@suse.de>
References: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com>
	 <20121008151656.GM29125@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: mingo@redhat.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, mmarek@suse.cz, tglx@linutronix.de, hpa@zytor.com, arnd@arndb.de, sam@ravnborg.org, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-10-08 at 16:16 +0100, Mel Gorman wrote:
> On Wed, Oct 03, 2012 at 08:56:14AM -0600, Mike Yoknis wrote:
> > memmap_init_zone() loops through every Page Frame Number (pfn),
> > including pfn values that are within the gaps between existing
> > memory sections.  The unneeded looping will become a boot
> > performance issue when machines configure larger memory ranges
> > that will contain larger and more numerous gaps.
> > 
> > The code will skip across invalid sections to reduce the
> > number of loops executed.
> > 
> > Signed-off-by: Mike Yoknis <mike.yoknis@hp.com>
> 
> This only helps SPARSEMEM and changes more headers than should be
> necessary. It would have been easier to do something simple like
> 
> if (!early_pfn_valid(pfn)) {
> 	pfn = ALIGN(pfn + MAX_ORDER_NR_PAGES, MAX_ORDER_NR_PAGES) - 1;
> 	continue;
> }
> 
> because that would obey the expectation that pages within a
> MAX_ORDER_NR_PAGES-aligned range are all valid or all invalid (ARM is the
> exception that breaks this rule). It would be less efficient on
> SPARSEMEM than what you're trying to merge but I do not see the need for
> the additional complexity unless you can show it makes a big difference
> to boot times.
> 

Mel,
I, too, was concerned that pfn_valid() was defined in so many header
files.  But, I did not feel that it was appropriate for me to try to
restructure things to consolidate those definitions just to add this one
new function.  Being a kernel newbie I did not believe that I had a good
enough understanding of what combinations and permutations of CONFIG and
architecture may have made all of those different definitions necessary,
so I left them in.

Yes, indeed, this fix is targeted for systems that have holes in memory.
That is where we see the problem.  We are creating large computer
systems and we would like for those machines to perform well, including
boot times.

Let me pass along the numbers I have.  We have what we call an
"architectural simulator".  It is a computer program that pretends that
it is a computer system.  We use it to test the firmware before real
hardware is available.  We have booted Linux on our simulator.  As you
would expect it takes longer to boot on the simulator than it does on
real hardware.

With my patch - boot time 41 minutes
Without patch - boot time 94 minutes

These numbers do not scale linearly to real hardware.  But indicate to
me a place where Linux can be improved.

Mike Yoknis


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
