Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 585346B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 21:14:48 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so5077469wiv.2
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 18:14:47 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id w12si25970947wiv.0.2014.07.21.18.14.46
        for <linux-mm@kvack.org>;
        Mon, 21 Jul 2014 18:14:47 -0700 (PDT)
Message-ID: <53CDBB01.7040007@imgtec.com>
Date: Mon, 21 Jul 2014 18:14:41 -0700
From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/highmem: make kmap cache coloring aware
References: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com> <alpine.DEB.2.02.1407211754350.7042@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407211754350.7042@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-xtensa@linux-xtensa.org, linux-kernel@vger.kernel.org

On 07/21/2014 05:58 PM, David Rientjes wrote:
> On Thu, 17 Jul 2014, Max Filippov wrote:
>
>> From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
>>
>> Provide hooks that allow architectures with aliasing cache to align
>> mapping address of high pages according to their color. Such architectures
>> may enforce similar coloring of low- and high-memory page mappings and
>> reuse existing cache management functions to support highmem.
>>
> Typically a change like this would be proposed along with a change to an
> architecture which would define this new ARCH_PKMAP_COLORING and have its
> own overriding definitions.  Based on who you sent this patch to, it looks
> like that would be mips and xtensa.  Now the only question is where are
> those patches to add the alternate definitions for those platforms?
Yes, there is one, at least for MIPS. This stuff can be a common ground 
for both platforms (MIPS and XTENSA)

>
>> Signed-off-by: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
>> [ Max: extract architecture-independent part of the original patch, clean
>>    up checkpatch and build warnings. ]
>> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>> ---
>> Changes v1->v2:
>> - fix description
>>
>>   mm/highmem.c | 19 ++++++++++++++++---
>>   1 file changed, 16 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/highmem.c b/mm/highmem.c
>> index b32b70c..6898a8b 100644
>> --- a/mm/highmem.c
>> +++ b/mm/highmem.c
>> @@ -44,6 +44,14 @@ DEFINE_PER_CPU(int, __kmap_atomic_idx);
>>    */
>>   #ifdef CONFIG_HIGHMEM
>>   
>> +#ifndef ARCH_PKMAP_COLORING
>> +#define set_pkmap_color(pg, cl)		/* */
> This is typically done with do {} while (0).
>
>> +#define get_last_pkmap_nr(p, cl)	(p)
>> +#define get_next_pkmap_nr(p, cl)	(((p) + 1) & LAST_PKMAP_MASK)
>> +#define is_no_more_pkmaps(p, cl)	(!(p))
> That's not gramatically proper.
>
>> +#define get_next_pkmap_counter(c, cl)	((c) - 1)
>> +#endif
>> +
>>   unsigned long totalhigh_pages __read_mostly;
>>   EXPORT_SYMBOL(totalhigh_pages);
>>   
>> @@ -161,19 +169,24 @@ static inline unsigned long map_new_virtual(struct page *page)
>>   {
>>   	unsigned long vaddr;
>>   	int count;
>> +	int color __maybe_unused;
>> +
>> +	set_pkmap_color(page, color);
>> +	last_pkmap_nr = get_last_pkmap_nr(last_pkmap_nr, color);
>>   
>>   start:
>>   	count = LAST_PKMAP;
>>   	/* Find an empty entry */
>>   	for (;;) {
>> -		last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
>> -		if (!last_pkmap_nr) {
>> +		last_pkmap_nr = get_next_pkmap_nr(last_pkmap_nr, color);
>> +		if (is_no_more_pkmaps(last_pkmap_nr, color)) {
>>   			flush_all_zero_pkmaps();
>>   			count = LAST_PKMAP;
>>   		}
>>   		if (!pkmap_count[last_pkmap_nr])
>>   			break;	/* Found a usable entry */
>> -		if (--count)
>> +		count = get_next_pkmap_counter(count, color);
> And that's not equivalent at all, --count decrements the auto variable and
> then tests it for being non-zero.  Your get_next_pkmap_counter() never
> decrements count.
David, the statements

             count = get_next_pkmap_counter(count, color);
             if (count > 0)

are extended in STANDARD (non colored) case to

             count = (count - 1);
             if (count > 0)

which are perfect equivalent of

             if (--count)

>
>> +		if (count > 0)
>>   			continue;
>>   
>>   		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
