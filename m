Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF5A6B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 20:45:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u108so11148396wrb.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 17:45:21 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id o184si861410wma.92.2017.03.16.17.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 17:45:20 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id z133so905973wmb.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 17:45:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d4e8433d-4680-dced-4f11-2f3cc8ebc613@nvidia.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-8-git-send-email-jglisse@redhat.com> <20170316160520.d03ac02474cad6d2c8eba9bc@linux-foundation.org>
 <d4e8433d-4680-dced-4f11-2f3cc8ebc613@nvidia.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 17 Mar 2017 11:45:19 +1100
Message-ID: <CAKTCnzmYob5uq11zkJE781BX9rDH9EYM7zxHH+ZMtTs4D5kkiQ@mail.gmail.com>
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use with
 device memory v4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, Mar 17, 2017 at 11:22 AM, John Hubbard <jhubbard@nvidia.com> wrote:
> On 03/16/2017 04:05 PM, Andrew Morton wrote:
>>
>> On Thu, 16 Mar 2017 12:05:26 -0400 J=C3=A9r=C3=B4me Glisse <jglisse@redh=
at.com>
>> wrote:
>>
>>> +static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
>>> +{
>>> +       if (!(mpfn & MIGRATE_PFN_VALID))
>>> +               return NULL;
>>> +       return pfn_to_page(mpfn & MIGRATE_PFN_MASK);
>>> +}
>>
>>
>> i386 allnoconfig:
>>
>> In file included from mm/page_alloc.c:61:
>> ./include/linux/migrate.h: In function 'migrate_pfn_to_page':
>> ./include/linux/migrate.h:139: warning: left shift count >=3D width of t=
ype
>> ./include/linux/migrate.h:141: warning: left shift count >=3D width of t=
ype
>> ./include/linux/migrate.h: In function 'migrate_pfn_size':
>> ./include/linux/migrate.h:146: warning: left shift count >=3D width of t=
ype
>>
>
> It seems clear that this was never meant to work with < 64-bit pfns:
>
> // migrate.h excerpt:
> #define MIGRATE_PFN_VALID       (1UL << (BITS_PER_LONG_LONG - 1))
> #define MIGRATE_PFN_MIGRATE     (1UL << (BITS_PER_LONG_LONG - 2))
> #define MIGRATE_PFN_HUGE        (1UL << (BITS_PER_LONG_LONG - 3))
> #define MIGRATE_PFN_LOCKED      (1UL << (BITS_PER_LONG_LONG - 4))
> #define MIGRATE_PFN_WRITE       (1UL << (BITS_PER_LONG_LONG - 5))
> #define MIGRATE_PFN_DEVICE      (1UL << (BITS_PER_LONG_LONG - 6))
> #define MIGRATE_PFN_ERROR       (1UL << (BITS_PER_LONG_LONG - 7))
> #define MIGRATE_PFN_MASK        ((1UL << (BITS_PER_LONG_LONG - PAGE_SHIFT=
))
> - 1)
>
> ...obviously, there is not enough room for these flags, in a 32-bit pfn.
>
> So, given the current HMM design, I think we are going to have to provide=
 a
> 32-bit version of these routines (migrate_pfn_to_page, and related) that =
is
> a no-op, right?

Or make the HMM Kconfig feature 64BIT only by making it depend on 64BIT?


Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
