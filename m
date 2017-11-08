Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7022E4403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 00:32:24 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 184so1602351pga.3
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 21:32:24 -0800 (PST)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id l3si2880864pgs.468.2017.11.07.21.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 21:32:23 -0800 (PST)
Message-ID: <1510119138.17435.19.camel@mtkswgap22>
Subject: Re: [PATCH] slub: Fix sysfs duplicate filename creation when
 slub_debug=O
From: Miles Chen <miles.chen@mediatek.com>
Date: Wed, 8 Nov 2017 13:32:18 +0800
In-Reply-To: <alpine.DEB.2.20.1711070916480.18776@nuc-kabylake>
References: <1510023934-17517-1-git-send-email-miles.chen@mediatek.com>
	 <alpine.DEB.2.20.1711070916480.18776@nuc-kabylake>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org

On Tue, 2017-11-07 at 09:22 -0600, Christopher Lameter wrote:
> On Tue, 7 Nov 2017, miles.chen@mediatek.com wrote:
> 
> > When slub_debug=O is set. It is possible to clear debug flags
> > for an "unmergeable" slab cache in kmem_cache_open().
> > It makes the "unmergeable" cache became "mergeable" in sysfs_slab_add().
> 
> Right but that is only if disable_higher_order_debug is set.

yes

> 
> > These caches will generate their "unique IDs" by create_unique_id(),
> > but it is possible to create identical unique IDs. In my experiment,
> > sgpool-128, names_cache, biovec-256 generate the same ID ":Ft-0004096"
> > and the kernel reports "sysfs: cannot create duplicate filename
> > '/kernel/slab/:Ft-0004096'".
> 
> Ok then the aliasing failed for some reason. The creation of the unique id
> and the alias detection needs to be in sync otherwise duplicate filenames
> are created. What is the difference there?

The aliasing failed because find_mergeable() returns if (flags &
SLAB_NEVER_MERGE) is true. So we do not go to search for alias caches.

__kmem_cache_alias()
  find_mergeable()
    kmem_cache_flags()  --> setup flag by the slub_debug
    if (flags & SLAB_NEVER_MERGE) return NULL;
    ...
    search alias logic...
    

The flags maybe changed if disable_higher_order_debug=1. So the
unmergeable cache becomes mergeable later.

> 
> The clearing of the DEBUG_METADATA_FLAGS looks ok to me. kmem_cache_alias
> should do the same right?
> 
Yes, I think clearing DEBUG_METADATA flags in kmem_cache_alias is
another solution for this issue.

We will need to do calculate_sizes() by using original flags and compare
the order of s->size and s->object_size when
disable_higher_order_debug=1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
