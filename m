Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB996B006E
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 15:12:35 -0400 (EDT)
Received: by pactp5 with SMTP id tp5so92655222pac.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 12:12:34 -0700 (PDT)
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com. [209.85.220.49])
        by mx.google.com with ESMTPS id he1si8653305pbc.130.2015.04.02.12.12.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 12:12:34 -0700 (PDT)
Received: by paboj16 with SMTP id oj16so11743474pab.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 12:12:33 -0700 (PDT)
Date: Thu, 2 Apr 2015 13:12:30 -0600
From: Lina Iyer <lina.iyer@linaro.org>
Subject: Re: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid
 ICE in gcc 4.7.3
Message-ID: <20150402191230.GA24219@linaro.org>
References: <CANMBJr68dsbYvvHUzy6U4m4fEM6nq8dVHBH4kLQ=0c4QNOhLPQ@mail.gmail.com>
 <20150327002554.GA5527@verge.net.au>
 <20150327100612.GB1562@arm.com>
 <7hbnj99epe.fsf@deeprootsystems.com>
 <CAKv+Gu_ZHZFm-1eXn+r7fkEHOxqSmj+Q+Mmy7k6LK531vSfAjQ@mail.gmail.com>
 <7h8uec95t2.fsf@deeprootsystems.com>
 <alpine.DEB.2.10.1504011130030.14762@ayla.of.borg>
 <551BBEC5.7070801@arm.com>
 <20150401124007.20c440cc43a482f698f461b8@linux-foundation.org>
 <7hwq1v4iq4.fsf@deeprootsystems.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <7hwq1v4iq4.fsf@deeprootsystems.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nishanth Menon <nm@ti.com>, Magnus Damm <magnus.damm@gmail.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Tyler Baker <tyler.baker@linaro.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Simon Horman <horms@verge.net.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Apr 01 2015 at 15:57 -0600, Kevin Hilman wrote:
>Andrew Morton <akpm@linux-foundation.org> writes:
>
>> On Wed, 01 Apr 2015 10:47:49 +0100 Marc Zyngier <marc.zyngier@arm.com> wrote:
>>
>>> > -static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
>>> > -			unsigned long private, struct page *page, int force,
>>> > -			enum migrate_mode mode)
>>> > +static noinline int unmap_and_move(new_page_t get_new_page,
>>> > +				   free_page_t put_new_page,
>>> > +				   unsigned long private, struct page *page,
>>> > +				   int force, enum migrate_mode mode)
>>> >  {
>>> >  	int rc = 0;
>>> >  	int *result = NULL;
>>> >
>>>
>>> Ouch. That's really ugly. And on 32bit ARM, we end-up spilling half of
>>> the parameters on the stack, which is not going to help performance
>>> either (not that this would be useful on 32bit ARM anyway...).
>>>
>>> Any chance you could make this dependent on some compiler detection
>>> mechanism?
>>
>> With my arm compiler (gcc-4.4.4) the patch makes no difference -
>> unmap_and_move() isn't being inlined anyway.
>>
>> How does this look?
>>
>> Kevin, could you please retest?  I might have fat-fingered something...
>
>Your patch on top of Geert's still compiles fine for me with gcc-4.7.3.
>However, I'm not sure how specific we can be on the versions.
>
>/me goes to test a few more compilers...   OK...
>
>ICE: 4.7.1, 4.7.3, 4.8.3
>OK: 4.6.3, 4.9.2, 4.9.3
>
>The diff below[2] on top of yours compiles fine here and at least covers
>the compilers I *know* to trigger the ICE.

I see ICE on 
arm-linux-gnueabi-gcc (Ubuntu/Linaro 4.7.4-2ubuntu1) 4.7.4

>
>Kevin
>
>
>[1]
>diff --git a/mm/migrate.c b/mm/migrate.c
>index 25fd7f6291de..6e15ae3248e0 100644
>--- a/mm/migrate.c
>+++ b/mm/migrate.c
>@@ -901,10 +901,10 @@ out:
> }
>
> /*
>- * gcc-4.7.3 on arm gets an ICE when inlining unmap_and_move().  Work around
>+ * gcc 4.7 and 4.8 on arm gets an ICE when inlining unmap_and_move().  Work around
>  * it.
>  */
>-#if GCC_VERSION == 40703 && defined(CONFIG_ARM)
>+#if (GCC_VERSION >= 40700 && GCC_VERSION < 40900) && defined(CONFIG_ARM)
> #define ICE_noinline noinline
> #else
> #define ICE_noinline
>
>_______________________________________________
>linux-arm-kernel mailing list
>linux-arm-kernel@lists.infradead.org
>http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
