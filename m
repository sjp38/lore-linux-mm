Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 4B2A76B0062
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 18:31:59 -0400 (EDT)
Date: Tue, 30 Oct 2012 15:31:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: memmap_init_zone() performance improvement
Message-Id: <20121030153157.70279408.akpm@linux-foundation.org>
In-Reply-To: <1351291667.6504.13.camel@MikesLinux.fc.hp.com>
References: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com>
	<20121008151656.GM29125@suse.de>
	<1349794597.29752.10.camel@MikesLinux.fc.hp.com>
	<1350676398.1169.6.camel@MikesLinux.fc.hp.com>
	<20121020082858.GA2698@suse.de>
	<1351093667.1205.11.camel@MikesLinux.fc.hp.com>
	<20121025094410.GA2558@suse.de>
	<1351291667.6504.13.camel@MikesLinux.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.yoknis@hp.com
Cc: Mel Gorman <mgorman@suse.de>, mingo@redhat.com, linux-arch@vger.kernel.org, mmarek@suse.cz, tglx@linutronix.de, hpa@zytor.com, arnd@arndb.de, sam@ravnborg.org, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 26 Oct 2012 16:47:47 -0600
Mike Yoknis <mike.yoknis@hp.com> wrote:

> memmap_init_zone() loops through every Page Frame Number (pfn),
> including pfn values that are within the gaps between existing
> memory sections.  The unneeded looping will become a boot
> performance issue when machines configure larger memory ranges
> that will contain larger and more numerous gaps.
> 
> The code will skip across invalid pfn values to reduce the
> number of loops executed.
> 

So I was wondering how much difference this makes.  Then I see Mel
already asked and was answered.  The lesson: please treat a reviewer
question as a sign that the changelog needs more information!  I added
this text to the changelog:

: We have what we call an "architectural simulator".  It is a computer
: program that pretends that it is a computer system.  We use it to test the
: firmware before real hardware is available.  We have booted Linux on our
: simulator.  As you would expect it takes longer to boot on the simulator
: than it does on real hardware.
: 
: With my patch - boot time 41 minutes
: Without patch - boot time 94 minutes
: 
: These numbers do not scale linearly to real hardware.  But indicate to me
: a place where Linux can be improved.

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3857,8 +3857,11 @@ void __meminit memmap_init_zone(unsigned long
> size, int nid, unsigned long zone,
>  		 * exist on hotplugged memory.
>  		 */
>  		if (context == MEMMAP_EARLY) {
> -			if (!early_pfn_valid(pfn))
> +			if (!early_pfn_valid(pfn)) {
> +				pfn = ALIGN(pfn + MAX_ORDER_NR_PAGES,
> +						MAX_ORDER_NR_PAGES) - 1;
>  				continue;
> +			}
>  			if (!early_pfn_in_nid(pfn, nid))
>  				continue;
>  		}

So what is the assumption here?  That each zone's first page has a pfn
which is a multiple of MAX_ORDER_NR_PAGES?

That seems reasonable, but is it actually true, for all architectures
and for all time?  Where did this come from?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
