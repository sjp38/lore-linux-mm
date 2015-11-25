Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 696036B0257
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 19:47:39 -0500 (EST)
Received: by ioc74 with SMTP id 74so38579034ioc.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:47:39 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id p16si1826674igw.68.2015.11.24.16.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 16:47:38 -0800 (PST)
Received: by igl9 with SMTP id 9so84478084igl.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:47:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151124164001.71844bcfb4d7a500cd25d9c6@linux-foundation.org>
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
	<1447888808-31571-2-git-send-email-dcashman@android.com>
	<20151124164001.71844bcfb4d7a500cd25d9c6@linux-foundation.org>
Date: Tue, 24 Nov 2015 16:47:37 -0800
Message-ID: <CAGXu5jKaW=H1WWuW_M4LpfcGGUWE3yvsiMnzMiAbeta__YpSJg@mail.gmail.com>
Subject: Re: [PATCH v3 1/4] mm: mmap: Add new /proc tunable for mmap_base ASLR.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Cashman <dcashman@android.com>, LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

On Tue, Nov 24, 2015 at 4:40 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 18 Nov 2015 15:20:05 -0800 Daniel Cashman <dcashman@android.com> wrote:
>
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -1568,6 +1568,28 @@ static struct ctl_table vm_table[] = {
>>               .mode           = 0644,
>>               .proc_handler   = proc_doulongvec_minmax,
>>       },
>> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
>> +     {
>> +             .procname       = "mmap_rnd_bits",
>> +             .data           = &mmap_rnd_bits,
>> +             .maxlen         = sizeof(mmap_rnd_bits),
>> +             .mode           = 0644,
>
> Is there any harm in permitting the attacker to read these values?
>
> And is there any benefit in permitting non-attackers to read them?

I'm on the fence. Things like kernel/randomize_va_space is 644. But
since I don't see a benefit in exposing them, let's make them all 600
instead -- it's a new interface, better to keep it narrower now.

>
>> +             .proc_handler   = proc_dointvec_minmax,
>> +             .extra1         = &mmap_rnd_bits_min,
>> +             .extra2         = &mmap_rnd_bits_max,
>> +     },
>> +#endif
>> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
>> +     {
>> +             .procname       = "mmap_rnd_compat_bits",
>> +             .data           = &mmap_rnd_compat_bits,
>> +             .maxlen         = sizeof(mmap_rnd_compat_bits),
>> +             .mode           = 0644,
>> +             .proc_handler   = proc_dointvec_minmax,
>> +             .extra1         = &mmap_rnd_compat_bits_min,
>> +             .extra2         = &mmap_rnd_compat_bits_max,
>> +     },
>> +#endif
>>
>> ...
>>
>> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
>> +int mmap_rnd_bits_min = CONFIG_ARCH_MMAP_RND_BITS_MIN;
>> +int mmap_rnd_bits_max = CONFIG_ARCH_MMAP_RND_BITS_MAX;
>> +int mmap_rnd_bits = CONFIG_ARCH_MMAP_RND_BITS;
>> +#endif
>> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
>> +int mmap_rnd_compat_bits_min = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN;
>> +int mmap_rnd_compat_bits_max = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX;
>> +int mmap_rnd_compat_bits = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
>
> These could be __read_mostly.
>
> If one believes in such things.  One effect of __read_mostly is to
> clump the write-often stuff into the same cachelines and I've never
> been convinced that one outweighs the other...

The _min and _max values should be const, actually, since they're
build-time selected. The _bits could easily be __read_mostly, yeah.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
