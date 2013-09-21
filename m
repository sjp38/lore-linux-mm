Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 054196B0032
	for <linux-mm@kvack.org>; Sat, 21 Sep 2013 17:56:37 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1736548pdj.32
        for <linux-mm@kvack.org>; Sat, 21 Sep 2013 14:56:37 -0700 (PDT)
Date: Sat, 21 Sep 2013 21:56:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Problems with RAID 4/5/6 and kmem_cache
In-Reply-To: <1379646960-12553-1-git-send-email-jbrassow@redhat.com>
Message-ID: <0000014142863060-919062ff-7284-445d-b3ec-f38cc8d5a6c8-000000@email.amazonses.com>
References: <1379646960-12553-1-git-send-email-jbrassow@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Brassow <jbrassow@redhat.com>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Thu, 19 Sep 2013, Jonathan Brassow wrote:

> 4) kmem_cache_create(name="foo-a")
> - This FAILS because kmem_cache_sanity_check colides with the existing
>   name ("foo-a") associated with the non-removed cache.

That should not happen. breakage you see will result. Oh. I see the move
to common code resulted in the SLAB checks being used for SLUB.

The following patch should fix this.

Subject: slab_common: Do not check for duplicate slab names

SLUB can alias multiple slab kmem_create_requests to one slab cache
to save memory and increase the cache hotness. As a result the name
of the slab can be stale. Only check the name for duplicates if we are
in debug mode where we do not merge multiple caches.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2013-09-20 11:49:13.052208294 -0500
+++ linux/mm/slab_common.c	2013-09-21 16:55:23.097131481 -0500
@@ -56,6 +56,7 @@
 			continue;
 		}

+#if !defined(CONFIG_SLUB) || !defined(CONFIG_SLUB_DEBUG_ON)
 		/*
 		 * For simplicity, we won't check this in the list of memcg
 		 * caches. We have control over memcg naming, and if there
@@ -69,6 +70,7 @@
 			s = NULL;
 			return -EINVAL;
 		}
+#endif
 	}

 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
