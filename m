Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0853E6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 17:24:48 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so23071624wic.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 14:24:47 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id w13si5288528wjq.111.2015.05.07.14.24.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 14:24:46 -0700 (PDT)
Received: by widdi4 with SMTP id di4so6945553wid.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 14:24:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150506163016.a2d79f89abc7543cb80307ac@linux-foundation.org>
References: <cover.1430772743.git.tony.luck@intel.com>
	<ec15446621a86b74ab1c7237c8c3e21b0b3e0e06.1430772743.git.tony.luck@intel.com>
	<20150506163016.a2d79f89abc7543cb80307ac@linux-foundation.org>
Date: Thu, 7 May 2015 14:24:46 -0700
Message-ID: <CA+8MBbLh4xX2TWaNncJO3Snre7oXJoDpVV95rQhch7vE4=t2yg@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/memblock: Allocate boot time data structures from
 mirrored memory
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, May 6, 2015 at 4:30 PM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
>> +     if (!ret && flag) {
>> +             pr_warn("Could not allocate %lld bytes of mirrored memory\=
n", size);
>
> This printk will warn on some configs.  Print a phys_addr_t with %pap.
> I think.  See huge comment over lib/vsprintf.c:pointer().

The comment may be huge - but it seems to lie about phys_addr_t :-(

I changed to %pap and got:

mm/memblock.c: In function =E2=80=98memblock_find_in_range=E2=80=99:
mm/memblock.c:276:3: warning: format =E2=80=98%p=E2=80=99 expects argument =
of type
=E2=80=98void *=E2=80=99, but argument 2 has type =E2=80=98phys_addr_t=E2=
=80=99 [-Wformat=3D]
   pr_warn("Could not allocate %pap bytes of mirrored memory\n",

<linux/types.h> says:
#ifdef CONFIG_PHYS_ADDR_T_64BIT
typedef u64 phys_addr_t;
#else
typedef u32 phys_addr_t;
#endif

So my original %lld would indeed have barfed on 32-bit builds ... but
%pap doesn't
seem to be the right answer either.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
