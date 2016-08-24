Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2596B0253
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 21:09:13 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u191so6601257oie.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:09:13 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l19si7611457ioi.75.2016.08.23.18.09.11
        for <linux-mm@kvack.org>;
        Tue, 23 Aug 2016 18:09:12 -0700 (PDT)
Date: Wed, 24 Aug 2016 10:15:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: what is the purpose of SLAB and SLUB (was: Re: [PATCH v3]
 mm/slab: Improve performance of gathering slabinfo) stats
Message-ID: <20160824011501.GA21997@js1304-P5Q-DELUXE>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160818115218.GJ30162@dhcp22.suse.cz>
 <20160823021303.GB17039@js1304-P5Q-DELUXE>
 <20160823153807.GN23577@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823153807.GN23577@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Jiri Slaby <jslaby@suse.cz>

On Tue, Aug 23, 2016 at 05:38:08PM +0200, Michal Hocko wrote:
> On Tue 23-08-16 11:13:03, Joonsoo Kim wrote:
> > On Thu, Aug 18, 2016 at 01:52:19PM +0200, Michal Hocko wrote:
> [...]
> > > I am not opposing the patch (to be honest it is quite neat) but this
> > > is buggering me for quite some time. Sorry for hijacking this email
> > > thread but I couldn't resist. Why are we trying to optimize SLAB and
> > > slowly converge it to SLUB feature-wise. I always thought that SLAB
> > > should remain stable and time challenged solution which works reasonably
> > > well for many/most workloads, while SLUB is an optimized implementation
> > > which experiment with slightly different concepts that might boost the
> > > performance considerably but might also surprise from time to time. If
> > > this is not the case then why do we have both of them in the kernel. It
> > > is a lot of code and some features need tweaking both while only one
> > > gets testing coverage. So this is mainly a question for maintainers. Why
> > > do we maintain both and what is the purpose of them.
> > 
> > I don't know full history about it since I joined kernel communitiy
> > recently(?). Christoph would be a better candidate for this topic.
> > Anyway,
> > 
> > SLAB if SLUB beats SLAB completely. But, there are fundamental
> > differences in implementation detail so they cannot beat each other
> > for all the workloads. It is similar with filesystem case that various
> > filesystems exist for it's own workload.
> 
> Do we have any documentation/study about which particular workloads
> benefit from which allocator? It seems that most users will use whatever
> the default or what their distribution uses. E.g. SLES kernel use SLAB
> because this is what we used to have for ages and there was no strong
> reason to change that default. From such a perspective having a stable
> allocator with minimum changes - just bug fixes - makes a lot of sense.

It doesn't make sense to me. Even if someone uses SLAB due to
conventional reason, they would want to use shiny new feature and get
performance improvement.

And, it is not only reason to use SLAB. There would be many different
reasons to use SLAB.

> I remember Mel doing some benchmarks when "why opensuse kernels do not
> use the default SLUB allocator" came the last time and he didn't see any
> large winner there
> https://lists.opensuse.org/opensuse-kernel/2015-08/msg00098.html
> This set of workloads is of course not comprehensive to rule one or
> other but I am wondering whether there are still any pathological
> workloads where we really want to keep SLAB or add new features to it.

AFAIK, some network benchmark still shows regression in SLUB.

http://lkml.kernel.org/r/20150907113026.5bb28ca3@redhat.com

> > Then, second plan was started. It is commonizing the code as much
> > as possible to develope new feature and maintain the code easily. The
> > code goes this direction, although it is slow. If it is achieved, we
> > don't need to worry about maintanance overhead.
> 
> I fully agree, commonizing the code base makes perfect sense. If a
> feature can be made independent on the underlying implementation then I
> am all for adding it but AFAIR kmemcg or kmemleak both need to touch
> quite deep internals and that brings risk for introducing new bugs which
> would be SL[AU]B specific. I remember Jiri Slaby was fighting a kmemlead
> false positives recently with SLAB which were not present in SLUB for
> example.

I guess that if commonizing work is done, there is a little to do for
allocator specific.

Thanks.

> > Anyway, we cannot remove one without regression so we don't remove one
> > until now. In this case, there is no point to stop improving one.
> 
> I can completely see the reason to not drop SLAB (and I am not suggesting
> that) but I would expect that SLAB would be more in a feature freeze
> state. Or if both of them need to evolve then at least describe which
> workloads pathologically benefit/suffer from one or the other.
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
