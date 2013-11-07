Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C650D6B0166
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 11:29:19 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so834740pad.39
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 08:29:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.135])
        by mx.google.com with SMTP id ru9si3169759pbc.258.2013.11.07.08.29.17
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 08:29:18 -0800 (PST)
Date: Thu, 7 Nov 2013 16:29:15 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: Switch slub_debug kernel option to early_param
 to avoid boot panic
In-Reply-To: <alpine.DEB.2.02.1311071008010.22533@gentwo.org>
Message-ID: <000001423365730f-486d720c-11cd-4f7d-939b-8ff2860c60b7-000000@email.amazonses.com>
References: <20131106184529.GB5661@alberich> <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com> <20131106195417.GK5661@alberich> <20131106203429.GL5661@alberich> <20131106211604.GM5661@alberich>
 <000001422f59e79e-ba0d30e2-fe7d-4e6f-9029-65dc5978fe60-000000@email.amazonses.com> <20131107082732.GN5661@alberich> <20131107084129.GP5661@alberich> <alpine.DEB.2.02.1311071008010.22533@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.02.1311071028282.22533@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Herrmann <andreas.herrmann@calxeda.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

There is still something not optimal with the patch since it would disable
debuggin on the kmalloc stack. Ccheck name for NULL only if
slub_debug_slabs.


Subject: slub: Handle NULL parameter in kmem_cache_flags V2

V1->V2
 - flags need to be applied regardless if !slub_debug_slabs

kmem_cache_flags may be called with NULL parameter during early boot.
Skip the test in that case.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2013-11-07 10:25:49.669706521 -0600
+++ linux/mm/slub.c	2013-11-07 10:27:49.130394661 -0600
@@ -1217,8 +1217,8 @@ static unsigned long kmem_cache_flags(un
 	/*
 	 * Enable debugging if selected on the kernel commandline.
 	 */
-	if (slub_debug && (!slub_debug_slabs ||
-		!strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs))))
+	if (slub_debug && (!slub_debug_slabs || (name &&
+		!strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs)))))
 		flags |= slub_debug;

 	return flags;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
