Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 0E7B36B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 21:30:08 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7704018dak.14
        for <linux-mm@kvack.org>; Tue, 29 May 2012 18:30:08 -0700 (PDT)
Date: Wed, 30 May 2012 10:29:55 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 13/28] slub: create duplicate cache
Message-ID: <20120530012955.GA4854@google.com>
References: <alpine.DEB.2.00.1205291101580.6723@router.home>
 <4FC501E9.60607@parallels.com>
 <alpine.DEB.2.00.1205291222360.8495@router.home>
 <4FC506E6.8030108@parallels.com>
 <alpine.DEB.2.00.1205291424130.8495@router.home>
 <4FC52612.5060006@parallels.com>
 <alpine.DEB.2.00.1205291454030.2504@router.home>
 <4FC52CC6.7020109@parallels.com>
 <alpine.DEB.2.00.1205291514090.2504@router.home>
 <4FC530C0.30509@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC530C0.30509@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

Hello, Christoph, Glauber.

On Wed, May 30, 2012 at 12:25:36AM +0400, Glauber Costa wrote:
> >We have never worked container like logic like that in the kernel due to
> >the complicated logic you would have to put in. The requirement that all
> >objects in a page come from the same container is not necessary. If you
> >drop this notion then things become very easy and the patches will become
> >simple.
> 
> I promise to look at that in more detail and get back to it. In the
> meantime, I think it would be enlightening to hear from other
> parties as well, specially the ones also directly interested in
> using the technology.

I don't think I'm too interested in using the technology ;) and
haven't read the code (just glanced through the descriptions and
discussions), but, in general, I think the approach of duplicating
memory allocator per-memcg is a sane approach.  It isn't the most
efficient one with the possibility of wasting considerable amount of
caching area per memcg but it is something which can mostly stay out
of the way if done right and that's how I want cgroup implementations
to be.

The two goals for cgroup controllers that I think are important are
proper (no, not crazy perfect but good enough) isolation and an
implementation which doesn't impact !cg path in an intrusive manner -
if someone who doesn't care about cgroup but knows and wants to work
on the subsystem should be able to mostly ignore cgroup support.  If
that means overhead for cgroup users, so be it.

Without looking at the actual code, my rainbow-farting unicorn here
would be having a common slXb interface layer which handles
interfacing with memory allocator users and cgroup and let slXb
implement the same backend interface which doesn't care / know about
cgroup at all (other than using the correct allocation context, that
is).  Glauber, would something like that be possible?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
