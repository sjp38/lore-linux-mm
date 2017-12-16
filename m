Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E94DE6B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 07:24:04 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id d18so5099498oic.22
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 04:24:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a135sor2922681oih.282.2017.12.16.04.24.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Dec 2017 04:24:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <8d5476e2-5f87-1134-62d4-9f649c4e709a@alibaba-inc.com>
References: <20171215125129.2948634-1-arnd@arndb.de> <8d5476e2-5f87-1134-62d4-9f649c4e709a@alibaba-inc.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 16 Dec 2017 13:24:02 +0100
Message-ID: <CAK8P3a3arg08JuBrz+Pqa47xsFCHtxTJ+7ywepeJpJro02NEjg@mail.gmail.com>
Subject: Re: [PATCH] mm: thp: avoid uninitialized variable use
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 7:01 PM, Yang Shi <yang.s@alibaba-inc.com> wrote:
>
>
> On 12/15/17 4:51 AM, Arnd Bergmann wrote:
>>
>> When the down_read_trylock() fails, 'vma' has not been initialized
>> yet, which gcc now warns about:
>>
>> mm/khugepaged.c: In function 'khugepaged':
>> mm/khugepaged.c:1659:25: error: 'vma' may be used uninitialized in this
>> function [-Werror=maybe-uninitialized]
>
>
> Arnd,
>
> Thanks for catching this. I'm wondering why my test didn't catch it. It
> might be because my gcc is old. I'm using gcc 4.8.5 on centos 7.

Correct, gcc-4.8 and earlier have too many false-positive warnings with
-Wmaybe-uninitialized, so we turn it off on those versions. 4.9 is much
better here, but I'd recommend using gcc-6 or gcc-7 when you upgrade,
they have a much better set of default warnings besides producing better
binary code.

See http://git.infradead.org/users/segher/buildall.git for a simple way
to build toolchains suitable for building kernels in varying architectures
and versions.

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
