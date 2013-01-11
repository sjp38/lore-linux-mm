Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 7A04E6B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 00:12:12 -0500 (EST)
Date: Fri, 11 Jan 2013 14:12:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130111051210.GC6183@blaptop>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130108084949.GD4714@blaptop>
 <20130109221449.GA14880@lizard.fhda.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130109221449.GA14880@lizard.fhda.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Wed, Jan 09, 2013 at 02:14:49PM -0800, Anton Vorontsov wrote:
> On Tue, Jan 08, 2013 at 05:49:49PM +0900, Minchan Kim wrote:
> [...]
> > Sorry still I didn't look at your implementation about cgroup part.
> > but I had a question since long time ago.
> > 
> > How can we can make sure false positive about zone and NUMA?
> > I mean DMA zone is short in system so VM notify to user and user
> > free all memory of NORMAL zone because he can't know what pages live
> > in any zones. NUMA is ditto.
> 
> Um, we count scans irrespective of zones or nodes, i.e. we sum all 'number
> of scanned' and 'number of reclaimed' stats. So, it should not be a
> problem, as I see it.

Why is it no problem? For example, let's think of normal zone reclaim.
Page allocator try to allocate pages from NORMAL zone to DMA zone fallback
and your logic could trigger mpc_shrinker. So process A, B, C start to
release thier freeable memory but unfortunately, freed pages are all
HIGHMEM pages. Why should processes release memory unnecessary?
Is there any method for proecess to detect such situation in user level
before releasing the freeable memory?

In android smart phone, until now, there was a zone - DMA so low memory
killer didn't have a problem but these days smart phone use 2G DRAM so
we started seeing the above problem. Your generic approach should solve
the problem, too.

> 
> Thanks,
> Anton
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
