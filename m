Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9E26B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 10:47:53 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id et14so2850440pad.16
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 07:47:52 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTPS id qw2si6957150pbb.80.2014.08.28.07.47.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 Aug 2014 07:47:51 -0700 (PDT)
Date: Thu, 28 Aug 2014 09:47:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slub: do not add duplicate sysfs
In-Reply-To: <20140828043211.GD3971@dhcp-17-37.nay.redhat.com>
Message-ID: <alpine.DEB.2.11.1408280947270.3275@gentwo.org>
References: <1409152488-21227-1-git-send-email-chaowang@redhat.com> <alpine.DEB.2.11.1408271023130.17080@gentwo.org> <alpine.DEB.2.11.1408271030360.17080@gentwo.org> <20140828043211.GD3971@dhcp-17-37.nay.redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WANG Chao <chaowang@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:SLAB ALLOCATOR" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

On Thu, 28 Aug 2014, WANG Chao wrote:

> What about failslab_store()? SLAB_FAILSLAB is also a nomerge flag.


Subject: slub: Disable tracing and failslab for merged slabs

Tracing of mergeable slabs as well as uses of failslab are
confusing since the objects of multiple slab caches will be
affected. Moreover this creates a situation where a mergeable
slab will become unmergeable.

If tracing or failslab testing is desired then it may be best to
switch merging off for starters.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-08-08 11:52:30.039681592 -0500
+++ linux/mm/slub.c	2014-08-28 09:45:58.748840392 -0500
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
@@ -4721,6 +4729,9 @@ static ssize_t failslab_show(struct kmem
 static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
 							size_t length)
 {
+	if (s->refcount > 1)
+		return -EINVAL;
+
 	s->flags &= ~SLAB_FAILSLAB;
 	if (buf[0] == '1')
 		s->flags |= SLAB_FAILSLAB;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
