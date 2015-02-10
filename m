Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0441A6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 07:37:11 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id b6so13279184lbj.12
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 04:37:10 -0800 (PST)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com. [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id pf5si11841625lbc.94.2015.02.10.04.37.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 04:37:09 -0800 (PST)
Received: by mail-lb0-f179.google.com with SMTP id w7so11700325lbi.10
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 04:37:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150209132351.f8b95644a1304543e5118820@linux-foundation.org>
References: <1423364112-15487-1-git-send-email-notasas@gmail.com>
	<20150209132351.f8b95644a1304543e5118820@linux-foundation.org>
Date: Tue, 10 Feb 2015 14:37:08 +0200
Message-ID: <CANOLnOOBgSOzSOiuZGW=A6dc1f4-fnL1XLgzjmsTwi53pJV=nw@mail.gmail.com>
Subject: Re: [PATCH] mm: actually remap enough memory
From: Grazvydas Ignotas <notasas@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Mon, Feb 9, 2015 at 11:23 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun,  8 Feb 2015 04:55:12 +0200 Grazvydas Ignotas <notasas@gmail.com> =
wrote:
>
>> For whatever reason, generic_access_phys() only remaps one page, but
>> actually allows to access arbitrary size. It's quite easy to trigger
>> large reads, like printing out large structure with gdb, which leads to
>> a crash. Fix it by remapping correct size.
>>
>> ...
>>
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -3829,7 +3829,7 @@ int generic_access_phys(struct vm_area_struct *vma=
, unsigned long addr,
>>       if (follow_phys(vma, addr, write, &prot, &phys_addr))
>>               return -EINVAL;
>>
>> -     maddr =3D ioremap_prot(phys_addr, PAGE_SIZE, prot);
>> +     maddr =3D ioremap_prot(phys_addr, PAGE_ALIGN(len + offset), prot);
>>       if (write)
>>               memcpy_toio(maddr + offset, buf, len);
>>       else
>
> hm, shouldn't this be PAGE_ALIGN(len)?

follow_phys() only returns page aligned address directly from page
table, so offset has to be added either to phys_addr or len. For
example if you need to read 4 bytes at address 0x10ffe or similar, 2
pages need to be mapped.

> Do we need the PAGE_ALIGN at all?  It's probably safer/saner to have it
> there, but x86 (at least) should be OK with arbitrary alignment on both
> addr and len?

Yes it's not strictly needed, but I'd prefer to keep it, as there is
already an assumption that ioremap operates in page quantities by
giving it page aligned phys_addr from follow_phys(). Or we could use
phys_addr + offset and len as arguments instead, no strong opinion
here.


Gra=C5=BEvydas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
