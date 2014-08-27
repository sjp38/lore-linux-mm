Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1176B003A
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 11:32:32 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so472510pdb.33
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 08:32:31 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id o2si1045642pdo.163.2014.08.27.08.32.24
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 08:32:24 -0700 (PDT)
Date: Wed, 27 Aug 2014 10:32:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slub: do not add duplicate sysfs
In-Reply-To: <alpine.DEB.2.11.1408271023130.17080@gentwo.org>
Message-ID: <alpine.DEB.2.11.1408271030360.17080@gentwo.org>
References: <1409152488-21227-1-git-send-email-chaowang@redhat.com> <alpine.DEB.2.11.1408271023130.17080@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WANG Chao <chaowang@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:SLAB ALLOCATOR" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

Maybe something like this may be a proper fix:

Subject: slub: Disable tracing of mergeable slabs

Tracing of mergeable slabs is confusing since the objects
of multiple slab caches will be traced. Moreover this creates
a situation where a mergeable slab will become unmergeable.

If tracing is desired then it may be best to switch merging
off for starters.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-08-08 11:52:30.039681592 -0500
+++ linux/mm/slub.c	2014-08-27 10:30:16.508108726 -0500
@@ -4604,6 +4604,14 @@ static ssize_t trace_show(struct kmem_ca
 static ssize_t trace_store(struct kmem_cache *s, const char *buf,
 							size_t length)
 {
+	/*
+	 * Tracing a merged cache is going to give confusing results
+	 * as well as cause other issues like converting a mergeable
+	 * cache into an umergeable one.
+	 */
+	if (s->refcount > 1)
+		return -EINVAL;
+
 	s->flags &= ~SLAB_TRACE;
 	if (buf[0] == '1') {
 		s->flags &= ~__CMPXCHG_DOUBLE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
