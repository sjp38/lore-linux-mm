Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 3257B6B0072
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 13:31:01 -0500 (EST)
Received: by mail-da0-f49.google.com with SMTP id v40so6553707dad.22
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 10:31:00 -0800 (PST)
Date: Wed, 2 Jan 2013 10:30:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] tmpfs mempolicy: fix /proc/mounts corrupting
 memory
In-Reply-To: <0000013bfbad4630-c888f29b-7294-4685-8164-87e2fb136796-000000@email.amazonses.com>
Message-ID: <alpine.LNX.2.00.1301021011520.30549@eggly.anvils>
References: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils> <0000013bfbad4630-c888f29b-7294-4685-8164-87e2fb136796-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2 Jan 2013, Christoph Lameter wrote:
> On Wed, 2 Jan 2013, Hugh Dickins wrote:
> 
> > Recent NUMA enhancements are not to blame: this dates back to 2.6.35,
> > when commit e17f74af351c "mempolicy: don't call mpol_set_nodemask()
> > when no_context" skipped mpol_parse_str()'s call to mpol_set_nodemask(),
> > which used to initialize v.preferred_node, or set MPOL_F_LOCAL in flags.
> > With slab poisoning, you can then rely on mpol_to_str() to set the bit
> > for node 0x6b6b, probably in the next page above the caller's stack.
> 
> Ugly. But 2.6.35 means that the patch was not included in several
> enterprise linux releases.

Thanks, that's some relief.  I forgot to mention that a good test for
whether your particular kernel (with who knows what additional patches
applied) is affected, is to

mount -o remount,mpol=local /dev/shm # which should be a tmpfs
grep /dev/shm /proc/mounts

If that says "mpol=prefer" then you're affected and need the fix; if
it says "mpol=local" (like 2.6.34 or after this fix) then you're safe.

(Conversely, setting "mpol=prefer" shows up as "mpol=local" after the,
fix, since that's what prefer without a node specification amounts to.)

> 
> > I don't understand why MPOL_LOCAL is described as a pseudo-policy:
> > it's a reasonable policy which suffers from a confusing implementation
> > in terms of MPOL_PREFERRED with MPOL_F_LOCAL.  I believe this would be
> > much more robust if MPOL_LOCAL were recognized in switch statements
> > throughout, MPOL_F_LOCAL deleted, and MPOL_PREFERRED use the (possibly
> > empty) nodes mask like everyone else, instead of its preferred_node
> > variant (I presume an optimization from the days before MPOL_LOCAL).
> > But that would take me too long to get right and fully tested.
> 
> The current approaches to implementing NUMA scheduling are making
> MPOL_LOCAL an explicit policy. See
> https://patchwork.kernel.org/patch/1703641/.

It's a good step in the right direction.

> 
> Does that address the concerns?

It makes no difference to this bug, and does not go far enough to
remove all the MPOL_F_LOCAL MPOL_PREFERRED MPOL_LOCAL twistiness.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
