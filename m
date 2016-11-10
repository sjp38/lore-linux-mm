Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 845566B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:32:43 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id hc3so75896922pac.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:32:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e17si1794506pgj.133.2016.11.09.16.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 16:32:42 -0800 (PST)
Date: Wed, 9 Nov 2016 16:32:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] z3fold: use per-page read/write lock
Message-Id: <20161109163241.c73742590270710040fdd25a@linux-foundation.org>
In-Reply-To: <20161109230117.GO26852@two.firstfloor.org>
References: <20161109115531.81d2a3fd4313236d483510f0@gmail.com>
	<20161109143304.538885b06a4b5d2289da1e52@linux-foundation.org>
	<20161109230117.GO26852@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

On Wed, 9 Nov 2016 15:01:17 -0800 Andi Kleen <andi@firstfloor.org> wrote:

> On Wed, Nov 09, 2016 at 02:33:04PM -0800, Andrew Morton wrote:
> > On Wed, 9 Nov 2016 11:55:31 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
> > 
> > > Subject: [PATCH v3] z3fold: use per-page read/write lock
> > 
> > I've rewritten the title to "mm/z3fold.c: use per-page spinlock"
> > 
> > (I prefer to have "mm" in the title to easily identify it as an MM
> > patch, and using "mm: z3fold: ..." seems odd when the actual pathname
> > conveys the same info.)
> 
> Still think it needs to be raw_spinlock_t, otherwise the build bug on
> on the header size will break again. 
> 
> Better would be to fix that build bug though

Yeah, that triggers for me immediately.  We could suppress it with
something silly like

--- a/mm/z3fold.c~z3fold-use-per-page-read-write-lock-fix
+++ a/mm/z3fold.c
@@ -872,7 +872,7 @@ MODULE_ALIAS("zpool-z3fold");
 static int __init init_z3fold(void)
 {
 	/* Make sure the z3fold header will fit in one chunk */
-	BUILD_BUG_ON(sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED);
+	BUILD_BUG_ON(sizeof(struct z3fold_header) - sizeof(spinlock_t) > ZHDR_SIZE_ALIGNED);
 	zpool_register_driver(&z3fold_zpool_driver);
 
 	return 0;

but that doesn't fix anything - the header is just too large with
lockdep enabled.

I'll drop the patch for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
