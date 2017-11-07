Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20C306B02CE
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 10:23:21 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q81so2489552ioi.12
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 07:23:21 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [69.252.207.40])
        by mx.google.com with ESMTPS id t2si1169956ioa.218.2017.11.07.07.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 07:23:20 -0800 (PST)
Date: Tue, 7 Nov 2017 09:22:18 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix sysfs duplicate filename creation when
 slub_debug=O
In-Reply-To: <1510023934-17517-1-git-send-email-miles.chen@mediatek.com>
Message-ID: <alpine.DEB.2.20.1711070916480.18776@nuc-kabylake>
References: <1510023934-17517-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org

On Tue, 7 Nov 2017, miles.chen@mediatek.com wrote:

> When slub_debug=O is set. It is possible to clear debug flags
> for an "unmergeable" slab cache in kmem_cache_open().
> It makes the "unmergeable" cache became "mergeable" in sysfs_slab_add().

Right but that is only if disable_higher_order_debug is set.

> These caches will generate their "unique IDs" by create_unique_id(),
> but it is possible to create identical unique IDs. In my experiment,
> sgpool-128, names_cache, biovec-256 generate the same ID ":Ft-0004096"
> and the kernel reports "sysfs: cannot create duplicate filename
> '/kernel/slab/:Ft-0004096'".

Ok then the aliasing failed for some reason. The creation of the unique id
and the alias detection needs to be in sync otherwise duplicate filenames
are created. What is the difference there?

The clearing of the DEBUG_METADATA_FLAGS looks ok to me. kmem_cache_alias
should do the same right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
