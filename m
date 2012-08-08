Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3F2846B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 11:52:49 -0400 (EDT)
Date: Wed, 8 Aug 2012 10:51:32 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common10 [12/20] Move sysfs_slab_add to common
In-Reply-To: <CAAmzW4MHW39RZ7TjAdbHZ0EWaAiqmo5NuAhRqQFpNtO5gWAGvQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1208081048180.7756@greybox.home>
References: <20120803192052.448575403@linux.com> <20120803192154.777250838@linux.com> <CAAmzW4MHW39RZ7TjAdbHZ0EWaAiqmo5NuAhRqQFpNtO5gWAGvQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Sun, 5 Aug 2012, JoonSoo Kim wrote:

> Why not handle error case of sysfs_slab_add()?
> Before patch, it is handled.
> Is there any reason for that?

The kmem_cache creation was successful so its usable from the subsystem
that created the cache. Its just that the sysfs entry was not registered.

We could handle the failure with a syslog entry?
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-08 10:52:30.023371373 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-08 10:52:08.551323219 -0500
@@ -140,8 +140,13 @@ out:
 		return NULL;
 	}

-	if (s->refcount == 1)
-		sysfs_slab_add(s);
+	if (s->refcount == 1) {
+		err = sysfs_slab_add(s);
+		if (err)
+			printk(KERN_WARNING "kmem_cache_create(%s) failed to"
+				" create sysfs entry. Error %d\n",
+					name, err);
+	}

 	return s;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
