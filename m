Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 0125C6B0071
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 17:31:09 -0500 (EST)
Date: Thu, 5 Jan 2012 22:31:06 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120105223106.GG27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
 <20120105142017.GA27881@csn.ul.ie>
 <20120105144011.GU11810@n2100.arm.linux.org.uk>
 <20120105161739.GD27881@csn.ul.ie>
 <20120105140645.42498cdd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120105140645.42498cdd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, Jan 05, 2012 at 02:06:45PM -0800, Andrew Morton wrote:
> On Thu, 5 Jan 2012 16:17:39 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > mm: page allocator: Guard against CPUs going offline while draining per-cpu page lists
> > 
> > While running a CPU hotplug stress test under memory pressure, I
> > saw cases where under enough stress the machine would halt although
> > it required a machine with 8 cores and plenty memory. I think the
> > problems may be related.
> 
> When we first implemented them, the percpu pages in the page allocator
> were of really really marginal benefit.  I didn't merge the patches at
> all for several cycles, and it was eventually a 49/51 decision.
> 
> So I suggest that our approach to solving this particular problem
> should be to nuke the whole thing, then see if that caused any
> observeable problems.  If it did, can we solve those problems by means
> other than bringing the dang things back?
> 

Sounds drastic. It would be less controversial to replace this patch
with a version that calls get_online_cpu() in drain_all_pages() but
remove the call to drain_all_pages() call from the page allocator on
the grounds it is not safe against CPU hotplug and to hell with the
slightly elevated allocation failure rates and stalls. That would avoid
the try_get_online_cpus() crappiness and be less complex.

If you really want to consider deleting the per-cpu allocator, maybe
it could be a LSF/MM topic? Personally I would be wary of deleting
it but mostly because I lack regular access to the type of hardware
to evaulate whether it was safe to remove or not. Minimally, removing
the per-cpu allocator could make the zone lock very hot even though slub
probably makes it very hot already.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
