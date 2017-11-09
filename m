Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D00B440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 18:51:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t10so7029133pgo.20
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 15:51:57 -0800 (PST)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id j125si8135246pfg.171.2017.11.09.15.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 15:51:56 -0800 (PST)
Message-ID: <1510271512.11555.3.camel@mtkswgap22>
Subject: Re: [PATCH] slub: Fix sysfs duplicate filename creation when
 slub_debug=O
From: Miles Chen <miles.chen@mediatek.com>
Date: Fri, 10 Nov 2017 07:51:52 +0800
In-Reply-To: <alpine.DEB.2.20.1711090949250.12587@nuc-kabylake>
References: <1510023934-17517-1-git-send-email-miles.chen@mediatek.com>
	 <alpine.DEB.2.20.1711070916480.18776@nuc-kabylake>
	 <1510119138.17435.19.camel@mtkswgap22>
	 <alpine.DEB.2.20.1711080903460.6161@nuc-kabylake>
	 <1510217554.32371.17.camel@mtkswgap22>
	 <alpine.DEB.2.20.1711090949250.12587@nuc-kabylake>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org

On Thu, 2017-11-09 at 09:49 -0600, Christopher Lameter wrote:
> On Thu, 9 Nov 2017, Miles Chen wrote:
> 
> > In this fix patch, it disables slab merging if SLUB_DEBUG=O and
> > CONFIG_SLUB_DEBUG_ON=y but the debug features are disabled by the
> > disable_higher_order_debug logic and it holds the "slab merging is off
> > if any debug features are enabled" behavior.
> 
> Sounds good. Where is the patch?
> 
> 
Sorry for confusing, I meant the original patch of this thread :-)

By checking disable_higher_order_debug & (slub_debug &
SLAB_NEVER_MERGE), we can detect if a cache is unmergeable but become
mergeable because the disable_higher_order_debug=1 logic. Those kind of
caches should be keep unmergeable.


diff --git a/mm/slub.c b/mm/slub.c
index 1efbb812..8cbf9f7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5704,6 +5704,10 @@ static int sysfs_slab_add(struct kmem_cache *s)
                return 0;
        }
 
+       if (!unmergeable && disable_higher_order_debug &&
+                       (slub_debug & SLAB_NEVER_MERGE))
+               unmergeable = 1;
+
        if (unmergeable) {
                /*
                 * Slabcache can never be merged so we can use the name
proper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
