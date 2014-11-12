Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF4790001D
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 21:11:25 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so11850775pad.21
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 18:11:25 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ug3si5863167pab.87.2014.11.11.18.11.23
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 18:11:24 -0800 (PST)
Date: Wed, 12 Nov 2014 11:13:35 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-ID: <20141112021335.GA21951@js1304-P5Q-DELUXE>
References: <bug-87891-27@https.bugzilla.kernel.org/>
 <alpine.DEB.2.11.1411111833220.8762@gentwo.org>
 <20141111164913.3616531c21c91499871c46de@linux-foundation.org>
 <201411120054.04651.luke@dashjr.org>
 <20141111170243.c24ce5fdb5efaf0814071847@linux-foundation.org>
 <20141112012244.GA21576@js1304-P5Q-DELUXE>
 <20141111174412.ba0ac86f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141111174412.ba0ac86f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luke Dashjr <luke@dashjr.org>, Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Tue, Nov 11, 2014 at 05:44:12PM -0800, Andrew Morton wrote:
> On Wed, 12 Nov 2014 10:22:45 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > On Tue, Nov 11, 2014 at 05:02:43PM -0800, Andrew Morton wrote:
> > > On Wed, 12 Nov 2014 00:54:01 +0000 Luke Dashjr <luke@dashjr.org> wrote:
> > > 
> > > > On Wednesday, November 12, 2014 12:49:13 AM Andrew Morton wrote:
> > > > > But anyway - Luke, please attach your .config to
> > > > > https://bugzilla.kernel.org/show_bug.cgi?id=87891?
> > > > 
> > > > Done: https://bugzilla.kernel.org/attachment.cgi?id=157381
> > > > 
> > > 
> > > OK, thanks.  No CONFIG_HIGHMEM of course.  I'm stumped.
> > 
> > Hello, Andrew.
> > 
> > I think that the cause is GFP_HIGHMEM.
> > GFP_HIGHMEM is always defined regardless CONFIG_HIGHMEM.
> > Please look at the do_huge_pmd_anonymous_page().
> > It calls alloc_hugepage_vma() and then alloc_pages_vma() is called
> > with alloc_hugepage_gfpmask(). This gfpmask includes GFP_TRANSHUGE
> > and then GFP_HIGHUSER_MOVABLE.
> 
> OK.
> 
> So where's the bug?  I'm inclined to say that it's in ttm.  It's taking

I agree that.

> a gfp_mask which means "this is the allocation attempt which we are
> attempting to satisfy" and uses that for its own allocation.
> 
> But ttm has no business using that gfp_mask for its own allocation
> attempt.  If anything it should use something like, err,
> 
> 	GFP_KERNEL & ~__GFP_IO & ~__GFP_FS | __GFP_HIGH
> 
> although as I mentioned earlier, it would be better to avoid allocation
> altogether.

Yes, avoiding would be the best.

If not possible, introducing new common helper for changing shrinker
control's gfp to valid allocation gfp is better than just open code.

Thanks.

> 
> Poor ttm guys - this is a bit of a trap we set for them.
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
