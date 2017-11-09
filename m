Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9F0440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 03:52:41 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id a125so8375774ita.8
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 00:52:41 -0800 (PST)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id k6si5621402pgq.102.2017.11.09.00.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 00:52:39 -0800 (PST)
Message-ID: <1510217554.32371.17.camel@mtkswgap22>
Subject: Re: [PATCH] slub: Fix sysfs duplicate filename creation when
 slub_debug=O
From: Miles Chen <miles.chen@mediatek.com>
Date: Thu, 9 Nov 2017 16:52:34 +0800
In-Reply-To: <alpine.DEB.2.20.1711080903460.6161@nuc-kabylake>
References: <1510023934-17517-1-git-send-email-miles.chen@mediatek.com>
	 <alpine.DEB.2.20.1711070916480.18776@nuc-kabylake>
	 <1510119138.17435.19.camel@mtkswgap22>
	 <alpine.DEB.2.20.1711080903460.6161@nuc-kabylake>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org

On Wed, 2017-11-08 at 09:05 -0600, Christopher Lameter wrote:
> On Wed, 8 Nov 2017, Miles Chen wrote:
> 
> > > Ok then the aliasing failed for some reason. The creation of the unique id
> > > and the alias detection needs to be in sync otherwise duplicate filenames
> > > are created. What is the difference there?
> >
> > The aliasing failed because find_mergeable() returns if (flags &
> > SLAB_NEVER_MERGE) is true. So we do not go to search for alias caches.
> >
> > __kmem_cache_alias()
> >   find_mergeable()
> >     kmem_cache_flags()  --> setup flag by the slub_debug
> >     if (flags & SLAB_NEVER_MERGE) return NULL;
> >     ...
> >     search alias logic...
> >
> >
> > The flags maybe changed if disable_higher_order_debug=1. So the
> > unmergeable cache becomes mergeable later.
> 
> Ok so make sure taht the aliasing logic also clears those flags before
> checking for SLAB_NEVER_MERGE.
> 
> > > The clearing of the DEBUG_METADATA_FLAGS looks ok to me. kmem_cache_alias
> > > should do the same right?
> > >
> > Yes, I think clearing DEBUG_METADATA flags in kmem_cache_alias is
> > another solution for this issue.
> >
> > We will need to do calculate_sizes() by using original flags and compare
> > the order of s->size and s->object_size when
> > disable_higher_order_debug=1.
> 
> Hmmm... Or move the aliasing check to a point where we know the size of
> the slab objects?

The biggest concern is that we may have some merged caches even if we
enable CONFIG_SLUB_DEBUG_ON and slub_debug=O. So a developer cannot say
"I set CONFIG_SLUB_DEBUG_ON=y to stop all slab merging". 
(https://www.spinics.net/lists/linux-mm/msg77919.html)

In this fix patch, it disables slab merging if SLUB_DEBUG=O and
CONFIG_SLUB_DEBUG_ON=y but the debug features are disabled by the
disable_higher_order_debug logic and it holds the "slab merging is off
if any debug features are enabled" behavior.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
