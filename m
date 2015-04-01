Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 509696B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 15:40:09 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so64788385pdb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 12:40:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qe8si4245090pdb.99.2015.04.01.12.40.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 12:40:08 -0700 (PDT)
Date: Wed, 1 Apr 2015 12:40:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid
 ICE in gcc 4.7.3
Message-Id: <20150401124007.20c440cc43a482f698f461b8@linux-foundation.org>
In-Reply-To: <551BBEC5.7070801@arm.com>
References: <20150324004537.GA24816@verge.net.au>
	<CAKv+Gu-0jPk=KQ4gY32ELc+BVbe=1QdcrwQ+Pb=RkdwO9K3Vkw@mail.gmail.com>
	<20150324161358.GA694@kahuna>
	<20150326003939.GA25368@verge.net.au>
	<20150326133631.GB2805@arm.com>
	<CANMBJr68dsbYvvHUzy6U4m4fEM6nq8dVHBH4kLQ=0c4QNOhLPQ@mail.gmail.com>
	<20150327002554.GA5527@verge.net.au>
	<20150327100612.GB1562@arm.com>
	<7hbnj99epe.fsf@deeprootsystems.com>
	<CAKv+Gu_ZHZFm-1eXn+r7fkEHOxqSmj+Q+Mmy7k6LK531vSfAjQ@mail.gmail.com>
	<7h8uec95t2.fsf@deeprootsystems.com>
	<alpine.DEB.2.10.1504011130030.14762@ayla.of.borg>
	<551BBEC5.7070801@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Kevin Hilman <khilman@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <Will.Deacon@arm.com>, Simon Horman <horms@verge.net.au>, Tyler Baker <tyler.baker@linaro.org>, Nishanth Menon <nm@ti.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Magnus Damm <magnus.damm@gmail.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 01 Apr 2015 10:47:49 +0100 Marc Zyngier <marc.zyngier@arm.com> wrote:

> > -static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
> > -			unsigned long private, struct page *page, int force,
> > -			enum migrate_mode mode)
> > +static noinline int unmap_and_move(new_page_t get_new_page,
> > +				   free_page_t put_new_page,
> > +				   unsigned long private, struct page *page,
> > +				   int force, enum migrate_mode mode)
> >  {
> >  	int rc = 0;
> >  	int *result = NULL;
> > 
> 
> Ouch. That's really ugly. And on 32bit ARM, we end-up spilling half of
> the parameters on the stack, which is not going to help performance
> either (not that this would be useful on 32bit ARM anyway...).
> 
> Any chance you could make this dependent on some compiler detection
> mechanism?

With my arm compiler (gcc-4.4.4) the patch makes no difference -
unmap_and_move() isn't being inlined anyway.

How does this look?

Kevin, could you please retest?  I might have fat-fingered something...

--- a/mm/migrate.c~mm-migrate-mark-unmap_and_move-noinline-to-avoid-ice-in-gcc-473-fix
+++ a/mm/migrate.c
@@ -901,10 +901,20 @@ out:
 }
 
 /*
+ * gcc-4.7.3 on arm gets an ICE when inlining unmap_and_move().  Work around
+ * it.
+ */
+#if GCC_VERSION == 40703 && defined(CONFIG_ARM)
+#define ICE_noinline noinline
+#else
+#define ICE_noinline
+#endif
+
+/*
  * Obtain the lock on page, remove all ptes and migrate the page
  * to the newly allocated page in newpage.
  */
-static noinline int unmap_and_move(new_page_t get_new_page,
+static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 				   free_page_t put_new_page,
 				   unsigned long private, struct page *page,
 				   int force, enum migrate_mode mode)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
