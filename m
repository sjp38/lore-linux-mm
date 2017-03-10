Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3603280903
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 19:58:05 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 2so105993143oif.7
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 16:58:05 -0800 (PST)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id o129si577105oif.84.2017.03.09.16.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 16:58:04 -0800 (PST)
Received: by mail-oi0-x22f.google.com with SMTP id 62so45019582oih.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 16:58:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <7ce861c2-0eff-9b60-e009-06b1fddf7b73@virtuozzo.com>
References: <20170215205826.13356-1-nicstange@gmail.com> <CAPcyv4iwhkW+cLbsT1Ns4=DhnfvZvdhbEVmj0zZcS+PRP6GMpA@mail.gmail.com>
 <7ce861c2-0eff-9b60-e009-06b1fddf7b73@virtuozzo.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 9 Mar 2017 16:58:04 -0800
Message-ID: <CAPcyv4gFH5_FmuNodvoJiBm1_Swpn3Kmyo7Fg1k2XYzU4DF0xA@mail.gmail.com>
Subject: Re: [RFC 0/3] Regressions due to 7b79d10a2d64 ("mm: convert
 kmalloc_section_memmap() to populate_section_memmap()") and Kasan
 initialization on
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Nicolai Stange <nicstange@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

On Fri, Mar 3, 2017 at 8:08 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> On 02/25/2017 10:03 PM, Dan Williams wrote:
>> [ adding kasan folks ]
>>
>> On Wed, Feb 15, 2017 at 12:58 PM, Nicolai Stange <nicstange@gmail.com> wrote:
>>> Hi Dan,
>>>
>>> your recent commit 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to
>>> populate_section_memmap()") seems to cause some issues with respect to
>>> Kasan initialization on x86.
>>>
>>> This is because Kasan's initialization (ab)uses the arch provided
>>> vmemmap_populate().
>>>
>>> The first one is a boot failure, see [1/3]. The commit before the
>>> aforementioned one works fine.
>>>
>>> The second one, i.e. [2/3], is something that hit my eye while browsing
>>> the source and I verified that this is indeed an issue by printk'ing and
>>> dumping the page tables.
>>>
>>> The third one are excessive warnings from vmemmap_verify() due to Kasan's
>>> NUMA_NO_NODE page populations.
>>>
>>>
>>> I'll be travelling the next two days and certainly not be able to respond
>>> or polish these patches any further. Furthermore, the next merge window is
>>> close. So please, take these three patches as bug reports only, meant to
>>> illustrate the issues. Feel free to use, change and adopt them however
>>> you deemed best.
>>>
>>> That being said,
>>> - [2/3] will break arm64 due to the current lack of a pmd_large().
>>> - Maybe it's easier and better to restore former behaviour by letting
>>>   Kasan's shadow initialization on x86 use vmemmap_populate_hugepages()
>>>   directly rather than vmemmap_populate(). This would require x86_64
>>>   implying X86_FEATURE_PSE though. I'm not sure whether this holds,
>>>   in particular not since the vmemmap_populate() from
>>>   arch/x86/mm/init_64.c checks for it.
>>
>> I think your intuition is correct here, and yes, it is a safe
>> assumption that x86_64 implies X86_FEATURE_PSE. The following patch
>> works for me. If there's no objections I'll roll it into the series
>> and resubmit the sub-section hotplug support after testing on top of
>> 4.11-rc1.
>>
>
> Perhaps it would be better to get rid of vmemmap in kasan code at all
> and have a separate function that populates kasan shadow.
> kasan is abusing API designed for something else. We already had bugs on arm64 (see 2776e0e8ef683)
> because of that and now this one on x86_64.
> I can cook patches and send them on the next week.
>

Any concerns with proceeding with the conversion to explicit
vmemmap_populate_hugepages() calls in the meantime? That allows me to
unblock the sub-section hotplug patches and kasan can move away from
vemmap_populate() on its own schedule.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
