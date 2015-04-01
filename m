Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 752506B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 17:55:03 -0400 (EDT)
Received: by patj18 with SMTP id j18so64141130pat.2
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 14:55:03 -0700 (PDT)
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com. [209.85.220.46])
        by mx.google.com with ESMTPS id t17si4585605pdl.223.2015.04.01.14.55.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 14:55:02 -0700 (PDT)
Received: by pacgg7 with SMTP id gg7so64152370pac.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 14:55:02 -0700 (PDT)
From: Kevin Hilman <khilman@kernel.org>
Subject: Re: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid ICE in gcc 4.7.3
References: <20150324004537.GA24816@verge.net.au>
	<CAKv+Gu-0jPk=KQ4gY32ELc+BVbe=1QdcrwQ+Pb=RkdwO9K3Vkw@mail.gmail.com>
	<20150324161358.GA694@kahuna> <20150326003939.GA25368@verge.net.au>
	<20150326133631.GB2805@arm.com>
	<CANMBJr68dsbYvvHUzy6U4m4fEM6nq8dVHBH4kLQ=0c4QNOhLPQ@mail.gmail.com>
	<20150327002554.GA5527@verge.net.au> <20150327100612.GB1562@arm.com>
	<7hbnj99epe.fsf@deeprootsystems.com>
	<CAKv+Gu_ZHZFm-1eXn+r7fkEHOxqSmj+Q+Mmy7k6LK531vSfAjQ@mail.gmail.com>
	<7h8uec95t2.fsf@deeprootsystems.com>
	<alpine.DEB.2.10.1504011130030.14762@ayla.of.borg>
	<551BBEC5.7070801@arm.com>
	<20150401124007.20c440cc43a482f698f461b8@linux-foundation.org>
Date: Wed, 01 Apr 2015 14:54:59 -0700
In-Reply-To: <20150401124007.20c440cc43a482f698f461b8@linux-foundation.org>
	(Andrew Morton's message of "Wed, 1 Apr 2015 12:40:07 -0700")
Message-ID: <7hwq1v4iq4.fsf@deeprootsystems.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marc Zyngier <marc.zyngier@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <Will.Deacon@arm.com>, Simon Horman <horms@verge.net.au>, Tyler Baker <tyler.baker@linaro.org>, Nishanth Menon <nm@ti.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Magnus Damm <magnus.damm@gmail.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed, 01 Apr 2015 10:47:49 +0100 Marc Zyngier <marc.zyngier@arm.com> wrote:
>
>> > -static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
>> > -			unsigned long private, struct page *page, int force,
>> > -			enum migrate_mode mode)
>> > +static noinline int unmap_and_move(new_page_t get_new_page,
>> > +				   free_page_t put_new_page,
>> > +				   unsigned long private, struct page *page,
>> > +				   int force, enum migrate_mode mode)
>> >  {
>> >  	int rc = 0;
>> >  	int *result = NULL;
>> > 
>> 
>> Ouch. That's really ugly. And on 32bit ARM, we end-up spilling half of
>> the parameters on the stack, which is not going to help performance
>> either (not that this would be useful on 32bit ARM anyway...).
>> 
>> Any chance you could make this dependent on some compiler detection
>> mechanism?
>
> With my arm compiler (gcc-4.4.4) the patch makes no difference -
> unmap_and_move() isn't being inlined anyway.
>
> How does this look?
>
> Kevin, could you please retest?  I might have fat-fingered something...

Your patch on top of Geert's still compiles fine for me with gcc-4.7.3.
However, I'm not sure how specific we can be on the versions.  

/me goes to test a few more compilers...   OK...

ICE: 4.7.1, 4.7.3, 4.8.3
OK: 4.6.3, 4.9.2, 4.9.3

The diff below[2] on top of yours compiles fine here and at least covers
the compilers I *know* to trigger the ICE.

Kevin


[1]
diff --git a/mm/migrate.c b/mm/migrate.c
index 25fd7f6291de..6e15ae3248e0 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -901,10 +901,10 @@ out:
 }
 
 /*
- * gcc-4.7.3 on arm gets an ICE when inlining unmap_and_move().  Work around
+ * gcc 4.7 and 4.8 on arm gets an ICE when inlining unmap_and_move().  Work around
  * it.
  */
-#if GCC_VERSION == 40703 && defined(CONFIG_ARM)
+#if (GCC_VERSION >= 40700 && GCC_VERSION < 40900) && defined(CONFIG_ARM)
 #define ICE_noinline noinline
 #else
 #define ICE_noinline

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
