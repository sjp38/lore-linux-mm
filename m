Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id D96786B0071
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 10:47:01 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so4504538qge.22
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 07:47:01 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id u6si13490658qad.104.2014.06.06.07.47.00
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 07:47:01 -0700 (PDT)
Date: Fri, 6 Jun 2014 09:46:57 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm v2 5/8] slub: make slab_free non-preemptable
In-Reply-To: <7cd6784a36ed997cc6631615d98e11e02e811b1b.1402060096.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1406060942160.32229@gentwo.org>
References: <cover.1402060096.git.vdavydov@parallels.com> <7cd6784a36ed997cc6631615d98e11e02e811b1b.1402060096.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Jun 2014, Vladimir Davydov wrote:

> This patch makes SLUB's implementation of kmem_cache_free
> non-preemptable. As a result, synchronize_sched() will work as a barrier
> against kmem_cache_free's in flight, so that issuing it before cache
> destruction will protect us against the use-after-free.


Subject: slub: reenable preemption before the freeing of slabs from slab_free

I would prefer to call the page allocator with preemption enabled if possible.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-05-29 11:45:32.065859887 -0500
+++ linux/mm/slub.c	2014-06-06 09:45:12.822480834 -0500
@@ -1998,6 +1998,7 @@
 	if (n)
 		spin_unlock(&n->list_lock);

+	preempt_enable();
 	while (discard_page) {
 		page = discard_page;
 		discard_page = discard_page->next;
@@ -2006,6 +2007,7 @@
 		discard_slab(s, page);
 		stat(s, FREE_SLAB);
 	}
+	preempt_disable();
 #endif
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
