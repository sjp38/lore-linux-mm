Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E31C6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 20:24:49 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id x84so204828063oix.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 17:24:49 -0800 (PST)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id p15si6733758otd.84.2017.01.23.17.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 17:24:47 -0800 (PST)
Received: by mail-oi0-x22b.google.com with SMTP id m124so90980816oif.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 17:24:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170123143827.9408317a0809de2d17fce8df@linux-foundation.org>
References: <20170123165156.854464-1-arnd@arndb.de> <20170123143827.9408317a0809de2d17fce8df@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 23 Jan 2017 17:24:46 -0800
Message-ID: <CAPcyv4gyWe6a5b2-WhzG_HXufMbfNEQV8JPOjq43uRznCrJO+A@mail.gmail.com>
Subject: Re: [PATCH] mm: fix maybe-uninitialized warning in section_deactivate()
Content-Type: multipart/mixed; boundary=001a114098d455bcf80546ccfb5c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Fabian Frederick <fabf@skynet.be>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--001a114098d455bcf80546ccfb5c
Content-Type: text/plain; charset=UTF-8

On Mon, Jan 23, 2017 at 2:38 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 23 Jan 2017 17:51:17 +0100 Arnd Bergmann <arnd@arndb.de> wrote:
>
>> gcc cannot track the combined state of the 'mask' variable across the
>> barrier in pgdat_resize_unlock() at compile time, so it warns that we
>> can run into undefined behavior:
>>
>> mm/sparse.c: In function 'section_deactivate':
>> mm/sparse.c:802:7: error: 'early_section' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>>
>> We know that this can't happen because the spin_unlock() doesn't
>> affect the mask variable, so this is a false-postive warning, but
>> rearranging the code to bail out earlier here makes it obvious
>> to the compiler as well.
>>
>> ...
>>
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -807,23 +807,24 @@ static void section_deactivate(struct pglist_data *pgdat, unsigned long pfn,
>>       unsigned long mask = section_active_mask(pfn, nr_pages), flags;
>>
>>       pgdat_resize_lock(pgdat, &flags);
>> -     if (!ms->usage) {
>> -             mask = 0;
>> -     } else if ((ms->usage->map_active & mask) != mask) {
>> -             WARN(1, "section already deactivated active: %#lx mask: %#lx\n",
>> -                             ms->usage->map_active, mask);
>> -             mask = 0;
>> -     } else {
>> -             early_section = is_early_section(ms);
>> -             ms->usage->map_active ^= mask;
>> -             if (ms->usage->map_active == 0) {
>> -                     usage = ms->usage;
>> -                     ms->usage = NULL;
>> -                     memmap = sparse_decode_mem_map(ms->section_mem_map,
>> -                                     section_nr);
>> -                     ms->section_mem_map = 0;
>> -             }
>> +     if (!ms->usage ||
>> +         WARN((ms->usage->map_active & mask) != mask,
>> +              "section already deactivated active: %#lx mask: %#lx\n",
>> +                     ms->usage->map_active, mask)) {
>> +             pgdat_resize_unlock(pgdat, &flags);
>> +             return;
>>       }
>> +
>> +     early_section = is_early_section(ms);
>> +     ms->usage->map_active ^= mask;
>> +     if (ms->usage->map_active == 0) {
>> +             usage = ms->usage;
>> +             ms->usage = NULL;
>> +             memmap = sparse_decode_mem_map(ms->section_mem_map,
>> +                             section_nr);
>> +             ms->section_mem_map = 0;
>> +     }
>> +
>
> hm, OK, that looks equivalent.
>
> I wonder if we still need the later
>
>         if (!mask)
>                 return;
>
> I wonder if this code is appropriately handling the `mask == -1' case.
> section_active_mask() can do that.
>
> What does that -1 in section_active_mask() mean anyway?  Was it really
> intended to represent the all-ones pattern or is it an error?

It's supposed to represent a full section's worth of bits, patch below
to add comments and switch over to ULONG_MAX to make it clearer. I
also fixed a bug with the case where the start pfn is section aligned,
but nr_pages is less than a section.

> If the
> latter, was it appropriate for section_active_mask() to return an
> unsigned type?
>
> How come section_active_mask() is __init but its caller
> section_deactivate() is not?

section_deactivate() is called from the memory hot-remove path which
has traditionally not been tagged __meminit, so  section_active_mask()
can't be __init either.  I missed this earlier when I reviewed your
fix, and it seems you got it clarified now with the fix from Arnd.

Fix up patch attached, and possibly whitespace damaged version below:


--->8---
--001a114098d455bcf80546ccfb5c--
