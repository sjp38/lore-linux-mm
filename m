Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DAB316B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 11:07:03 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id z13so66666790iof.7
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 08:07:03 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0119.outbound.protection.outlook.com. [104.47.1.119])
        by mx.google.com with ESMTPS id e40si363252iod.35.2017.03.03.08.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 08:07:02 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [RFC 0/3] Regressions due to 7b79d10a2d64 ("mm: convert
 kmalloc_section_memmap() to populate_section_memmap()") and Kasan
 initialization on
References: <20170215205826.13356-1-nicstange@gmail.com>
 <CAPcyv4iwhkW+cLbsT1Ns4=DhnfvZvdhbEVmj0zZcS+PRP6GMpA@mail.gmail.com>
Message-ID: <7ce861c2-0eff-9b60-e009-06b1fddf7b73@virtuozzo.com>
Date: Fri, 3 Mar 2017 19:08:08 +0300
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iwhkW+cLbsT1Ns4=DhnfvZvdhbEVmj0zZcS+PRP6GMpA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Nicolai Stange <nicstange@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

On 02/25/2017 10:03 PM, Dan Williams wrote:
> [ adding kasan folks ]
> 
> On Wed, Feb 15, 2017 at 12:58 PM, Nicolai Stange <nicstange@gmail.com> wrote:
>> Hi Dan,
>>
>> your recent commit 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to
>> populate_section_memmap()") seems to cause some issues with respect to
>> Kasan initialization on x86.
>>
>> This is because Kasan's initialization (ab)uses the arch provided
>> vmemmap_populate().
>>
>> The first one is a boot failure, see [1/3]. The commit before the
>> aforementioned one works fine.
>>
>> The second one, i.e. [2/3], is something that hit my eye while browsing
>> the source and I verified that this is indeed an issue by printk'ing and
>> dumping the page tables.
>>
>> The third one are excessive warnings from vmemmap_verify() due to Kasan's
>> NUMA_NO_NODE page populations.
>>
>>
>> I'll be travelling the next two days and certainly not be able to respond
>> or polish these patches any further. Furthermore, the next merge window is
>> close. So please, take these three patches as bug reports only, meant to
>> illustrate the issues. Feel free to use, change and adopt them however
>> you deemed best.
>>
>> That being said,
>> - [2/3] will break arm64 due to the current lack of a pmd_large().
>> - Maybe it's easier and better to restore former behaviour by letting
>>   Kasan's shadow initialization on x86 use vmemmap_populate_hugepages()
>>   directly rather than vmemmap_populate(). This would require x86_64
>>   implying X86_FEATURE_PSE though. I'm not sure whether this holds,
>>   in particular not since the vmemmap_populate() from
>>   arch/x86/mm/init_64.c checks for it.
> 
> I think your intuition is correct here, and yes, it is a safe
> assumption that x86_64 implies X86_FEATURE_PSE. The following patch
> works for me. If there's no objections I'll roll it into the series
> and resubmit the sub-section hotplug support after testing on top of
> 4.11-rc1.
> 

Perhaps it would be better to get rid of vmemmap in kasan code at all
and have a separate function that populates kasan shadow.
kasan is abusing API designed for something else. We already had bugs on arm64 (see 2776e0e8ef683)
because of that and now this one on x86_64.
I can cook patches and send them on the next week.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
