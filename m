Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 966B16B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 23:44:41 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so19439597pbc.35
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 20:44:41 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id sj5si57071960pab.168.2014.01.06.20.44.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 20:44:40 -0800 (PST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 10:14:37 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B3624394002D
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 10:14:34 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s074iRxn27131992
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 10:14:27 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s074iXj2020924
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 10:14:33 +0530
Date: Tue, 7 Jan 2014 12:44:32 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: slub: fix ALLOC_SLOWPATH stat
Message-ID: <52cb8638.2590420a.46e0.ffffd916SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20140106204300.DE79BA86@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140106204300.DE79BA86@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, akpm@linux-foundation.org, penberg@kernel.org

On Mon, Jan 06, 2014 at 12:43:00PM -0800, Dave Hansen wrote:
>
>From: Dave Hansen <dave.hansen@linux.intel.com>
>
>There used to be only one path out of __slab_alloc(), and
>ALLOC_SLOWPATH got bumped in that exit path.  Now there are two,
>and a bunch of gotos.  ALLOC_SLOWPATH can now get set more than once
>during a single call to __slab_alloc() which is pretty bogus.
>Here's the sequence:
>
>1. Enter __slab_alloc(), fall through all the way to the
>   stat(s, ALLOC_SLOWPATH);
>2. hit 'if (!freelist)', and bump DEACTIVATE_BYPASS, jump to
>   new_slab (goto #1)
>3. Hit 'if (c->partial)', bump CPU_PARTIAL_ALLOC, goto redo
>   (goto #2)
>4. Fall through in the same path we did before all the way to
>   stat(s, ALLOC_SLOWPATH)
>5. bump ALLOC_REFILL stat, then return
>
>Doing this is obviously bogus.  It keeps us from being able to
>accurately compare ALLOC_SLOWPATH vs. ALLOC_FASTPATH.  It also
>means that the total number of allocs always exceeds the total
>number of frees.
>
>This patch moves stat(s, ALLOC_SLOWPATH) to be called from the
>same place that __slab_alloc() is.  This makes it much less
>likely that ALLOC_SLOWPATH will get botched again in the
>spaghetti-code inside __slab_alloc().
>
>Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
>
> linux.git-davehans/mm/slub.c |    8 +++-----
> 1 file changed, 3 insertions(+), 5 deletions(-)
>
>diff -puN mm/slub.c~slub-ALLOC_SLOWPATH-stat mm/slub.c
>--- linux.git/mm/slub.c~slub-ALLOC_SLOWPATH-stat	2014-01-06 12:39:28.148072544 -0800
>+++ linux.git-davehans/mm/slub.c	2014-01-06 12:39:28.155072860 -0800
>@@ -2301,8 +2301,6 @@ redo:
> 	if (freelist)
> 		goto load_freelist;
>
>-	stat(s, ALLOC_SLOWPATH);
>-
> 	freelist = get_freelist(s, page);
>
> 	if (!freelist) {
>@@ -2409,10 +2407,10 @@ redo:
>
> 	object = c->freelist;
> 	page = c->page;
>-	if (unlikely(!object || !node_match(page, node)))
>+	if (unlikely(!object || !node_match(page, node))) {
> 		object = __slab_alloc(s, gfpflags, node, addr, c);
>-
>-	else {
>+		stat(s, ALLOC_SLOWPATH);
>+	} else {
> 		void *next_object = get_freepointer_safe(s, object);
>
> 		/*
>_
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
