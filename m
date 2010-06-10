Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 40FFF6B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 21:16:44 -0400 (EDT)
Date: Wed, 9 Jun 2010 21:16:17 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] only drop root anon_vma if not self
Message-ID: <20100609211617.3e7e41bd@annuminas.surriel.com>
In-Reply-To: <AANLkTik-cwrabXH_bQRPFtTo3C9r30B83jMf4IwJKCms@mail.gmail.com>
References: <AANLkTin1OS3LohKBvWyS81BoAk15Y-riCiEdcevSA7ye@mail.gmail.com>
	<1275929000.3021.56.camel@e102109-lin.cambridge.arm.com>
	<AANLkTilsCkBiGtfEKkNXYclsRKhfuq4yI_1mrxMa8yJG@mail.gmail.com>
	<AANLkTik-cwrabXH_bQRPFtTo3C9r30B83jMf4IwJKCms@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010 17:19:02 +0800
Dave Young <hidave.darkstar@gmail.com> wrote:

> > Manually bisected mm patches, the memleak caused by following patch:
> >
> > mm-extend-ksm-refcounts-to-the-anon_vma-root.patch
>
> 
> So I guess the refcount break, either drop-without-get or over-drop

I'm guessing I did not run the kernel with enough debug options enabled
when I tested my patches...

Dave & Catalin, thank you for tracking this down.

Dave, does the below patch fix your issue?

Andrew, if the patch below works, you'll probably want to merge it as
mm-extend-ksm-refcounts-to-the-anon_vma-root-fix.patch :)

----------------

With the new anon_vma code we take a refcount on the root anon_vma.
However, the root anon_vma does not have a refcount on itself, so
we should not try to do a drop on itself when it is being unlinked.

Signed-off-by: Rik van Riel <riel@redhat.com>

--- linux-2.6-rtavma/mm/rmap.c.orig	2010-06-09 21:10:07.349376896 -0400
+++ linux-2.6-rtavma/mm/rmap.c	2010-06-09 21:10:24.180406299 -0400
@@ -275,7 +275,8 @@ static void anon_vma_unlink(struct anon_
 
 	if (empty) {
 		/* We no longer need the root anon_vma */
-		drop_anon_vma(anon_vma->root);
+		if (anon_vma->root != anon_vma)
+			drop_anon_vma(anon_vma->root);
 		anon_vma_free(anon_vma);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
