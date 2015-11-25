Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A9DAD6B0254
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 14:16:49 -0500 (EST)
Received: by padhx2 with SMTP id hx2so65785913pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:16:49 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id kz10si2803565pab.59.2015.11.25.11.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 11:16:48 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so65657350pac.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 11:16:48 -0800 (PST)
Subject: Re: [PATCH v3 1/4] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
 <1447888808-31571-2-git-send-email-dcashman@android.com>
 <20151124164001.71844bcfb4d7a500cd25d9c6@linux-foundation.org>
 <CAGXu5jKaW=H1WWuW_M4LpfcGGUWE3yvsiMnzMiAbeta__YpSJg@mail.gmail.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <5656091E.6080803@android.com>
Date: Wed, 25 Nov 2015 11:16:46 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKaW=H1WWuW_M4LpfcGGUWE3yvsiMnzMiAbeta__YpSJg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

On 11/24/2015 04:47 PM, Kees Cook wrote:
> On Tue, Nov 24, 2015 at 4:40 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Wed, 18 Nov 2015 15:20:05 -0800 Daniel Cashman <dcashman@android.com> wrote:
>>
>>> --- a/kernel/sysctl.c
>>> +++ b/kernel/sysctl.c
>>> @@ -1568,6 +1568,28 @@ static struct ctl_table vm_table[] = {
>>>               .mode           = 0644,
>>>               .proc_handler   = proc_doulongvec_minmax,
>>>       },
>>> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
>>> +     {
>>> +             .procname       = "mmap_rnd_bits",
>>> +             .data           = &mmap_rnd_bits,
>>> +             .maxlen         = sizeof(mmap_rnd_bits),
>>> +             .mode           = 0644,
>>
>> Is there any harm in permitting the attacker to read these values?
>>
>> And is there any benefit in permitting non-attackers to read them?
> 
> I'm on the fence. Things like kernel/randomize_va_space is 644. But
> since I don't see a benefit in exposing them, let's make them all 600
> instead -- it's a new interface, better to keep it narrower now.

Is there any harm in allowing the attacker to read these values? Nothing
immediately comes to mind.  It is a form of information leakage, and I
guess a local attacker could use this information to calibrate an attack
or decide whether or not brute-forcing is a worthy approach, but this
easily could be leaked in other ways as well.

Is there a benefit to allowing non-attackers to read them?  Possibly
could be used in tests seeking to verify the system environment, but
again, this could be discovered in other ways.

I like Kees' suggestion of starting narrow and granting if need arises.

>>>
>>> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
>>> +int mmap_rnd_bits_min = CONFIG_ARCH_MMAP_RND_BITS_MIN;
>>> +int mmap_rnd_bits_max = CONFIG_ARCH_MMAP_RND_BITS_MAX;
>>> +int mmap_rnd_bits = CONFIG_ARCH_MMAP_RND_BITS;
>>> +#endif
>>> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
>>> +int mmap_rnd_compat_bits_min = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN;
>>> +int mmap_rnd_compat_bits_max = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX;
>>> +int mmap_rnd_compat_bits = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
>>
>> These could be __read_mostly.
>>
>> If one believes in such things.  One effect of __read_mostly is to
>> clump the write-often stuff into the same cachelines and I've never
>> been convinced that one outweighs the other...
> 
> The _min and _max values should be const, actually, since they're
> build-time selected. The _bits could easily be __read_mostly, yeah.

Yes, one would generally expect these to never be touched, and even if
they were, the threshold of __read_mostly would certainly be crossed.

-Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
