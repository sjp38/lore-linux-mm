Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 13D7F5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 19:04:33 -0400 (EDT)
Date: Thu, 21 Oct 2010 18:04:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <20101021142121.3ddb7e0a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1010211759220.3431@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <20101021124054.14b85e50.akpm@linux-foundation.org> <alpine.DEB.2.00.1010211455100.30295@router.home> <20101021131428.f2f7214a.akpm@linux-foundation.org> <alpine.DEB.2.00.1010211527050.32674@router.home>
 <20101021133636.68979e37.akpm@linux-foundation.org> <alpine.DEB.2.00.1010211547120.32674@router.home> <20101021135904.48a9c479.akpm@linux-foundation.org> <alpine.DEB.2.00.1010211607430.32674@router.home> <20101021142121.3ddb7e0a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, Andrew Morton wrote:

> > Do you know what the point of calling slab_shrink() per zone in one
> > location (kswapd) vs. for each reclaim pass in direct reclaim is?
>
> No.  As I said, I don't recall the thinking behind it.  And I (and
> apparently only I) made the effort to find out.
>
> It could be in the very old email archives.  It would be a lot of work
> to find it if so.  Which is why we should put things in comments and
> changelogs.  With great diligence.  So we don't cause regressions five
> years later.

I dont think there can be any point in calling a reclaim functions thrice
given that the reclaim function has logic to fine tune the pressure to be
put on a cache. It will do 3 times what only should have been done once.
If someone would have intentionally wanted this then the logic to tune the
pressure in the slab reclaim function would have been changed.

> > But maybe its better to throw the two changes together to make this one
> > patch for per node slab reclaim support.
>
> It could be that the patch improves behaviour on smaller machines.  Or
> worsens it or, more likely, has no discernable effect.

Likely no discernable effect since it only occurs for background reclaim
where it would be barely noticeable.

Direct reclaim is something else. There we have it outside of the loop
over zones being called only once per reclaim pass.

> But for heavens sake we shouldn't go patching people's kernels when we
> don't know what the effect of our change is!  Is this controversial?

We need to understand the code first. If we do not know what the effect of
the change is then our knowledge about how the kernel operates is
deficient and we are not able to control the code. Certainly tests need to
be run but first lets hash out our understanding of the code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
