Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 38C186B0257
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 11:12:41 -0500 (EST)
Received: by pacej9 with SMTP id ej9so71366976pac.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 08:12:41 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id d1si12781228pas.96.2015.12.03.08.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 08:12:40 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so73336228pab.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 08:12:40 -0800 (PST)
Subject: Re: [PATCH v5 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
References: <1449000658-11475-1-git-send-email-dcashman@android.com>
 <1449000658-11475-2-git-send-email-dcashman@android.com>
 <1449000658-11475-3-git-send-email-dcashman@android.com>
 <1449000658-11475-4-git-send-email-dcashman@android.com>
 <20151203121712.GE11337@arm.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <566069F0.3060409@android.com>
Date: Thu, 3 Dec 2015 08:12:32 -0800
MIME-Version: 1.0
In-Reply-To: <20151203121712.GE11337@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de

On 12/3/15 4:17 AM, Will Deacon wrote:
>> +	select HAVE_ARCH_MMAP_RND_BITS if MMU
>> +	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if MMU && COMPAT
> 
> You can drop the 'if MMU' bits, since we don't support !MMU on arm64.

Ok, will do. I was a little uneasy leaving it implicit, but even if
something w/out MMU on arm64 shows up, it'll easily be corrected.

>> +config ARCH_MMAP_RND_BITS_MIN
>> +       default 15 if ARM64_64K_PAGES
>> +       default 17 if ARM64_16K_PAGES
>> +       default 19
> 
> Is this correct? We currently have a mask of 0x3ffff, so that's 18 bits.

Off-by-one errors provide a good example of why hardening features are
useful? =/ Will change.

>> +config ARCH_MMAP_RND_BITS_MAX
>> +       default 19 if ARM64_VA_BITS=36
>> +       default 20 if ARM64_64K_PAGES && ARM64_VA_BITS=39
>> +       default 22 if ARM64_16K_PAGES && ARM64_VA_BITS=39
>> +       default 24 if ARM64_VA_BITS=39
>> +       default 23 if ARM64_64K_PAGES && ARM64_VA_BITS=42
>> +       default 25 if ARM64_16K_PAGES && ARM64_VA_BITS=42
>> +       default 27 if ARM64_VA_BITS=42
>> +       default 30 if ARM64_VA_BITS=47
>> +       default 29 if ARM64_64K_PAGES && ARM64_VA_BITS=48
>> +       default 31 if ARM64_16K_PAGES && ARM64_VA_BITS=48
>> +       default 33 if ARM64_VA_BITS=48
>> +       default 15 if ARM64_64K_PAGES
>> +       default 17 if ARM64_16K_PAGES
>> +       default 19
> 
> Could you add a comment above this with the formula
> (VA_BITS - PAGE_SHIFT - 3), please, so that we can update this easily in
> the future if we need to?
> 
Yes, seems reasonable.  Time will tell if this remains true for all
architectures, or even here, but it would be good to document it where
someone considering a change could easily find it.

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
