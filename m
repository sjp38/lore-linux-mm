Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 988FA6B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 09:32:17 -0500 (EST)
Date: Wed, 2 Jan 2013 14:32:16 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] tmpfs mempolicy: fix /proc/mounts corrupting
 memory
In-Reply-To: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils>
Message-ID: <0000013bfbad4630-c888f29b-7294-4685-8164-87e2fb136796-000000@email.amazonses.com>
References: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2 Jan 2013, Hugh Dickins wrote:

> Recent NUMA enhancements are not to blame: this dates back to 2.6.35,
> when commit e17f74af351c "mempolicy: don't call mpol_set_nodemask()
> when no_context" skipped mpol_parse_str()'s call to mpol_set_nodemask(),
> which used to initialize v.preferred_node, or set MPOL_F_LOCAL in flags.
> With slab poisoning, you can then rely on mpol_to_str() to set the bit
> for node 0x6b6b, probably in the next page above the caller's stack.

Ugly. But 2.6.35 means that the patch was not included in several
enterprise linux releases.

> I don't understand why MPOL_LOCAL is described as a pseudo-policy:
> it's a reasonable policy which suffers from a confusing implementation
> in terms of MPOL_PREFERRED with MPOL_F_LOCAL.  I believe this would be
> much more robust if MPOL_LOCAL were recognized in switch statements
> throughout, MPOL_F_LOCAL deleted, and MPOL_PREFERRED use the (possibly
> empty) nodes mask like everyone else, instead of its preferred_node
> variant (I presume an optimization from the days before MPOL_LOCAL).
> But that would take me too long to get right and fully tested.

The current approaches to implementing NUMA scheduling are making
MPOL_LOCAL an explicit policy. See
https://patchwork.kernel.org/patch/1703641/.

Does that address the concerns?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
