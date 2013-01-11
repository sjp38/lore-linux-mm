Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 14C5E6B005D
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 00:42:07 -0500 (EST)
Received: by mail-oa0-f51.google.com with SMTP id n12so1438231oag.38
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 21:42:06 -0800 (PST)
Date: Thu, 10 Jan 2013 21:38:31 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130111053831.GA18053@lizard.gateway.2wire.net>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <20130108084949.GD4714@blaptop>
 <20130109221449.GA14880@lizard.fhda.edu>
 <20130111051210.GC6183@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130111051210.GC6183@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jan 11, 2013 at 02:12:10PM +0900, Minchan Kim wrote:
> On Wed, Jan 09, 2013 at 02:14:49PM -0800, Anton Vorontsov wrote:
> > On Tue, Jan 08, 2013 at 05:49:49PM +0900, Minchan Kim wrote:
> > [...]
> > > Sorry still I didn't look at your implementation about cgroup part.
> > > but I had a question since long time ago.
> > > 
> > > How can we can make sure false positive about zone and NUMA?
> > > I mean DMA zone is short in system so VM notify to user and user
> > > free all memory of NORMAL zone because he can't know what pages live
> > > in any zones. NUMA is ditto.
> > 
> > Um, we count scans irrespective of zones or nodes, i.e. we sum all 'number
> > of scanned' and 'number of reclaimed' stats. So, it should not be a
> > problem, as I see it.
> 
> Why is it no problem? For example, let's think of normal zone reclaim.
> Page allocator try to allocate pages from NORMAL zone to DMA zone fallback
> and your logic could trigger mpc_shrinker. So process A, B, C start to
> release thier freeable memory but unfortunately, freed pages are all
> HIGHMEM pages. Why should processes release memory unnecessary?
> Is there any method for proecess to detect such situation in user level
> before releasing the freeable memory?

Ahh. You're talking about the shrinker interface. Yes, there is no way to
tell if the freed memory will be actually "released" (and if not, then
yes, we released it unnecessary).

But that's not only problem with NUMA or zones. Shared pages are in the
same boat, right? An app might free some memory, but as another process
might be still using it, we don't know whether our action helps or not.

The situation is a little bit easier for the in-kernel shrinkers, since we
have more control over pages, but still, even for the kernel shrinkers, we
don't provide all the information (only gfpmask, which, I just looked into
the random user, drivers/gpu/drm/ttm, sometimes is not used).

So, answering your question: no, I don't know how to solve it for the
userland. But I also don't think it's a big concern (especially if we make
it cgroup-aware -- this would be cgroup's worry then, i.e. we might
isolate task to only some nodes/zones, if we really care about precise
accounting?). But I'm surely open for ideas. :)

Thanks!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
