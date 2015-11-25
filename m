Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E022B6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 15:39:16 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so67384976pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:39:16 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id w69si36372161pfa.82.2015.11.25.12.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 12:39:16 -0800 (PST)
Received: by padhx2 with SMTP id hx2so67514621pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:39:16 -0800 (PST)
Subject: Re: [PATCH v3 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
 <1447888808-31571-2-git-send-email-dcashman@android.com>
 <1447888808-31571-3-git-send-email-dcashman@android.com>
 <1447888808-31571-4-git-send-email-dcashman@android.com>
 <20151123150459.GD4236@arm.com> <56536114.1020305@android.com>
 <20151125120601.GC3109@e104818-lin.cambridge.arm.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <56561C71.30602@android.com>
Date: Wed, 25 Nov 2015 12:39:13 -0800
MIME-Version: 1.0
In-Reply-To: <20151125120601.GC3109@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, dcashman@google.com, linux-doc@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, aarcange@redhat.com, linux@arm.linux.org.uk, corbet@lwn.net, xypron.glpk@gmx.de, x86@kernel.org, hecmargi@upv.es, mgorman@suse.de, rientjes@google.com, bp@suse.de, nnk@google.com, dzickus@redhat.com, keescook@chromium.org, jpoimboe@redhat.com, tglx@linutronix.de, n-horiguchi@ah.jp.nec.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, salyzyn@android.com, ebiederm@xmission.com, jeffv@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com

On 11/25/2015 04:06 AM, Catalin Marinas wrote:
> On Mon, Nov 23, 2015 at 10:55:16AM -0800, Daniel Cashman wrote:
>> On 11/23/2015 07:04 AM, Will Deacon wrote:
>>> On Wed, Nov 18, 2015 at 03:20:07PM -0800, Daniel Cashman wrote:
>>>> +config ARCH_MMAP_RND_BITS_MAX
>>>> +       default 20 if ARM64_64K_PAGES && ARCH_VA_BITS=39
> 
> Where is ARCH_VA_BITS defined? We only have options like
> ARM64_VA_BITS_39.
> 
> BTW, we no longer allow the 64K pages and 39-bit VA combination.

It is not, and should have been ARM64_VA_BITS.  This stanza was meant to
mimic the one for ARM64_VA_BITS.  Thank you for pointing this, and the
39-bit combination out.

>>>> +       default 24 if ARCH_VA_BITS=39
>>>> +       default 23 if ARM64_64K_PAGES && ARCH_VA_BITS=42
>>>> +       default 27 if ARCH_VA_BITS=42
>>>> +       default 29 if ARM64_64K_PAGES && ARCH_VA_BITS=48
>>>> +       default 33 if ARCH_VA_BITS=48
>>>> +       default 15 if ARM64_64K_PAGES
>>>> +       default 19
>>>> +
>>>> +config ARCH_MMAP_RND_COMPAT_BITS_MIN
>>>> +       default 7 if ARM64_64K_PAGES
>>>> +       default 11
>>>
>>> FYI: we now support 16k pages too, so this might need updating. It would
>>> be much nicer if this was somehow computed rather than have the results
>>> all open-coded like this.
>>
>> Yes, I ideally wanted this to be calculated based on the different page
>> options and VA_BITS (which itself has a similar stanza), but I don't
>> know how to do that/if it is currently supported in Kconfig. This would
>> be even more desirable with the addition of 16K_PAGES, as with this
>> setup we have a combinatorial problem.
> 
> For KASan, we ended up calculating KASAN_SHADOW_OFFSET in
> arch/arm64/Makefile. What would the formula be for the above
> ARCH_MMAP_RND_BITS_MAX?

The general formula I used ended up being:
_max = floor(log(TASK_SIZE)) - log(PAGE_SIZE) - 3

which in the case of arm64 ended up being VA_BITS - PAGE_SHIFT - 3.
Aside: following this would actually put COMPAT_BITS_MAX at 17 for 4k
pages, rather than 16, but I left it at 16 to mirror what was put in
arch/arm/Kconfig.


Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
