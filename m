Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 445476B0255
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 03:36:32 -0500 (EST)
Received: by wmuu63 with SMTP id u63so46395470wmu.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 00:36:31 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id b127si9051825wmh.67.2015.11.27.00.36.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 00:36:31 -0800 (PST)
Received: by wmww144 with SMTP id w144so48875309wmw.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 00:36:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56561C71.30602@android.com>
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
	<1447888808-31571-2-git-send-email-dcashman@android.com>
	<1447888808-31571-3-git-send-email-dcashman@android.com>
	<1447888808-31571-4-git-send-email-dcashman@android.com>
	<20151123150459.GD4236@arm.com>
	<56536114.1020305@android.com>
	<20151125120601.GC3109@e104818-lin.cambridge.arm.com>
	<56561C71.30602@android.com>
Date: Fri, 27 Nov 2015 11:36:30 +0300
Message-ID: <CAPAsAGyJr5OD+_4TO9dt2EwOGUGewEy4bAmhFhDbP3RJ+6QxaA@mail.gmail.com>
Subject: Re: [PATCH v3 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, dcashman@google.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, mingo <mingo@kernel.org>, aarcange@redhat.com, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, xypron.glpk@gmx.de, "x86@kernel.org" <x86@kernel.org>, hecmargi@upv.es, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Borislav Petkov <bp@suse.de>, nnk@google.com, dzickus@redhat.com, Kees Cook <keescook@chromium.org>, jpoimboe@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, salyzyn@android.com, "Eric W. Biederman" <ebiederm@xmission.com>, jeffv@google.com, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

2015-11-25 23:39 GMT+03:00 Daniel Cashman <dcashman@android.com>:
> On 11/25/2015 04:06 AM, Catalin Marinas wrote:
>> On Mon, Nov 23, 2015 at 10:55:16AM -0800, Daniel Cashman wrote:
>>> On 11/23/2015 07:04 AM, Will Deacon wrote:
>>>> On Wed, Nov 18, 2015 at 03:20:07PM -0800, Daniel Cashman wrote:
>>>>> +config ARCH_MMAP_RND_BITS_MAX
>>>>> +       default 20 if ARM64_64K_PAGES && ARCH_VA_BITS=39
>>
>> Where is ARCH_VA_BITS defined? We only have options like
>> ARM64_VA_BITS_39.
>>
>> BTW, we no longer allow the 64K pages and 39-bit VA combination.
>
> It is not, and should have been ARM64_VA_BITS.  This stanza was meant to
> mimic the one for ARM64_VA_BITS.  Thank you for pointing this, and the
> 39-bit combination out.
>
>>>>> +       default 24 if ARCH_VA_BITS=39
>>>>> +       default 23 if ARM64_64K_PAGES && ARCH_VA_BITS=42
>>>>> +       default 27 if ARCH_VA_BITS=42
>>>>> +       default 29 if ARM64_64K_PAGES && ARCH_VA_BITS=48
>>>>> +       default 33 if ARCH_VA_BITS=48
>>>>> +       default 15 if ARM64_64K_PAGES
>>>>> +       default 19
>>>>> +
>>>>> +config ARCH_MMAP_RND_COMPAT_BITS_MIN
>>>>> +       default 7 if ARM64_64K_PAGES
>>>>> +       default 11
>>>>
>>>> FYI: we now support 16k pages too, so this might need updating. It would
>>>> be much nicer if this was somehow computed rather than have the results
>>>> all open-coded like this.
>>>
>>> Yes, I ideally wanted this to be calculated based on the different page
>>> options and VA_BITS (which itself has a similar stanza), but I don't
>>> know how to do that/if it is currently supported in Kconfig. This would
>>> be even more desirable with the addition of 16K_PAGES, as with this
>>> setup we have a combinatorial problem.
>>
>> For KASan, we ended up calculating KASAN_SHADOW_OFFSET in
>> arch/arm64/Makefile. What would the formula be for the above
>> ARCH_MMAP_RND_BITS_MAX?
>
> The general formula I used ended up being:
> _max = floor(log(TASK_SIZE)) - log(PAGE_SIZE) - 3
>

For kasan, we calculate KASAN_SHADOW_OFFSET in Makefile, because we need to use
that value in Makefiles.

For ARCH_MMAP_RND_COMPAT_BITS_MIN/MAX I don't see a reason why it has
to be in Kconfig.
Can't we just use your formula to #define ARCH_MMAP_RND_COMPAT_BITS_*
in some arch header?

> which in the case of arm64 ended up being VA_BITS - PAGE_SHIFT - 3.
> Aside: following this would actually put COMPAT_BITS_MAX at 17 for 4k
> pages, rather than 16, but I left it at 16 to mirror what was put in
> arch/arm/Kconfig.
>
>
> Thank You,
> Dan
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
