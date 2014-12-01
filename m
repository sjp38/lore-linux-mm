Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 07A656B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 00:25:11 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so10297890pad.23
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 21:25:10 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id wu7si4649937pbc.226.2014.11.30.21.25.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Nov 2014 21:25:09 -0800 (PST)
Date: Mon, 1 Dec 2014 16:24:48 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH v2] slab: Fix nodeid bounds check for non-contiguous node
 IDs
Message-ID: <20141201052448.GC11234@drongo>
References: <20141201042844.GB11234@drongo>
 <1417410134.16178.2.camel@concordia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417410134.16178.2.camel@concordia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linuxppc-dev@ozlabs.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Dec 01, 2014 at 04:02:14PM +1100, Michael Ellerman wrote:
> On Mon, 2014-12-01 at 15:28 +1100, Paul Mackerras wrote:
> > The bounds check for nodeid in ____cache_alloc_node gives false
> > positives on machines where the node IDs are not contiguous, leading
> > to a panic at boot time.  For example, on a POWER8 machine the node
> > IDs are typically 0, 1, 16 and 17.  This means that num_online_nodes()
> > returns 4, so when ____cache_alloc_node is called with nodeid = 16 the
> > VM_BUG_ON triggers, like this:
> ...
> > 
> > To fix this, we instead compare the nodeid with MAX_NUMNODES, and
> > additionally make sure it isn't negative (since nodeid is an int).
> > The check is there mainly to protect the array dereference in the
> > get_node() call in the next line, and the array being dereferenced is
> > of size MAX_NUMNODES.  If the nodeid is in range but invalid (for
> > example if the node is off-line), the BUG_ON in the next line will
> > catch that.
> 
> When did this break? How come we only just noticed?

Commit 14e50c6a9bc2, which went into 3.10-rc1.

You'll only notice if you have CONFIG_SLAB=y and CONFIG_DEBUG_VM=y
and you're running on a machine with discontiguous node IDs.

> Also needs:
> 
> Cc: stable@vger.kernel.org

It does.  I remembered that a minute after I sent the patch.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
