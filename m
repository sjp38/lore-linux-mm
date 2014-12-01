Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id AEA736B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 03:52:28 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so10473588pdb.4
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 00:52:28 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id ko6si27862554pab.94.2014.12.01.00.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 00:52:26 -0800 (PST)
Message-ID: <1417423941.25107.2.camel@concordia>
Subject: Re: [PATCH v2] slab: Fix nodeid bounds check for non-contiguous
 node IDs
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 01 Dec 2014 19:52:21 +1100
In-Reply-To: <20141201052448.GC11234@drongo>
References: <20141201042844.GB11234@drongo>
	 <1417410134.16178.2.camel@concordia> <20141201052448.GC11234@drongo>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linuxppc-dev@ozlabs.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 2014-12-01 at 16:24 +1100, Paul Mackerras wrote:
> On Mon, Dec 01, 2014 at 04:02:14PM +1100, Michael Ellerman wrote:
> > On Mon, 2014-12-01 at 15:28 +1100, Paul Mackerras wrote:
> > > The bounds check for nodeid in ____cache_alloc_node gives false
> > > positives on machines where the node IDs are not contiguous, leading
> > > to a panic at boot time.  For example, on a POWER8 machine the node
> > > IDs are typically 0, 1, 16 and 17.  This means that num_online_nodes()
> > > returns 4, so when ____cache_alloc_node is called with nodeid = 16 the
> > > VM_BUG_ON triggers, like this:
> > ...
> > > 
> > > To fix this, we instead compare the nodeid with MAX_NUMNODES, and
> > > additionally make sure it isn't negative (since nodeid is an int).
> > > The check is there mainly to protect the array dereference in the
> > > get_node() call in the next line, and the array being dereferenced is
> > > of size MAX_NUMNODES.  If the nodeid is in range but invalid (for
> > > example if the node is off-line), the BUG_ON in the next line will
> > > catch that.
> > 
> > When did this break? How come we only just noticed?
> 
> Commit 14e50c6a9bc2, which went into 3.10-rc1.

OK. So a Fixes tag is nice:

Fixes: 14e50c6a9bc2 ("mm: slab: Verify the nodeid passed to ____cache_alloc_node")

> You'll only notice if you have CONFIG_SLAB=y and CONFIG_DEBUG_VM=y
> and you're running on a machine with discontiguous node IDs.

Right. And we have SLUB=y for all the defconfigs that are likely to hit that.

> > Also needs:
> > 
> > Cc: stable@vger.kernel.org
> 
> It does.  I remembered that a minute after I sent the patch.

OK. Hopefully one of the slab maintainers will be happy to add it for us when
they merge this?

cheers



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
