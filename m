Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 78BDE6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 22:05:08 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so11034734pdj.22
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 19:05:08 -0700 (PDT)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id fl10si28717092pab.132.2014.07.01.19.05.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 19:05:07 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 2 Jul 2014 12:05:03 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id CB1512CE8040
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 12:04:57 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s621gV1064421982
	for <linux-mm@kvack.org>; Wed, 2 Jul 2014 11:42:31 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6224uMT026846
	for <linux-mm@kvack.org>; Wed, 2 Jul 2014 12:04:56 +1000
Date: Wed, 2 Jul 2014 10:04:54 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: mm: slub: invalid memory access in setup_object
Message-ID: <20140702020454.GA6961@richard>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <53AAFDF7.2010607@oracle.com>
 <alpine.DEB.2.11.1406251228130.29216@gentwo.org>
 <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1407010956470.5353@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1407010956470.5353@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Tue, Jul 01, 2014 at 09:58:52AM -0500, Christoph Lameter wrote:
>On Mon, 30 Jun 2014, David Rientjes wrote:
>
>> It's not at all clear to me that that patch is correct.  Wei?
>
>Looks ok to me. But I do not like the convoluted code in new_slab() which
>Wei's patch does not make easier to read. Makes it difficult for the
>reader to see whats going on.

My patch is somewhat convoluted since I wanted to preserve the original logic
and make minimal change. And yes, it looks not that nice to audience.

I feel a little hurt by this patch. What I found and worked is gone with this
patch.

>
>Lets drop the use of the variable named "last".
>
>
>Subject: slub: Only call setup_object once for each object
>
>Modify the logic for object initialization to be less convoluted
>and initialize an object only once.
>
>Signed-off-by: Christoph Lameter <cl@linux.com>
>
>Index: linux/mm/slub.c
>===================================================================
>--- linux.orig/mm/slub.c	2014-07-01 09:50:02.486846653 -0500
>+++ linux/mm/slub.c	2014-07-01 09:52:07.918802585 -0500
>@@ -1409,7 +1409,6 @@ static struct page *new_slab(struct kmem
> {
> 	struct page *page;
> 	void *start;
>-	void *last;
> 	void *p;
> 	int order;
>
>@@ -1432,15 +1431,11 @@ static struct page *new_slab(struct kmem
> 	if (unlikely(s->flags & SLAB_POISON))
> 		memset(start, POISON_INUSE, PAGE_SIZE << order);
>
>-	last = start;
> 	for_each_object(p, s, start, page->objects) {
>-		setup_object(s, page, last);
>-		set_freepointer(s, last, p);
>-		last = p;
>+		setup_object(s, page, p);
>+		set_freepointer(s, p, p + s->size);
> 	}
>-	setup_object(s, page, last);
>-	set_freepointer(s, last, NULL);
>-
>+	set_freepointer(s, start + (page->objects - 1) * s->size, NULL);
> 	page->freelist = start;
> 	page->inuse = page->objects;
> 	page->frozen = 1;

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
