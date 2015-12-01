Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id C884F6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 19:04:38 -0500 (EST)
Received: by igcto18 with SMTP id to18so84014576igc.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 16:04:38 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id p9si6381197igi.65.2015.11.30.16.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 16:04:38 -0800 (PST)
Received: by igbxm8 with SMTP id xm8so85559521igb.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 16:04:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151130160118.e43a2e53a59e347a95a94d5c@linux-foundation.org>
References: <1448578785-17656-1-git-send-email-dcashman@android.com>
	<1448578785-17656-2-git-send-email-dcashman@android.com>
	<20151130155412.b1a087f4f6f4d4180ab4472d@linux-foundation.org>
	<20151130160118.e43a2e53a59e347a95a94d5c@linux-foundation.org>
Date: Mon, 30 Nov 2015 16:04:36 -0800
Message-ID: <CAGXu5jK7UzjBxXKQajxhLv-uLk_xQXR_FHOsmW6RLJNeK_-dZg@mail.gmail.com>
Subject: Re: [PATCH v4 1/4] mm: mmap: Add new /proc tunable for mmap_base ASLR.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Cashman <dcashman@android.com>, LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

On Mon, Nov 30, 2015 at 4:01 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 30 Nov 2015 15:54:12 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Thu, 26 Nov 2015 14:59:42 -0800 Daniel Cashman <dcashman@android.com> wrote:
>>
>> > ASLR  only uses as few as 8 bits to generate the random offset for the
>> > mmap base address on 32 bit architectures. This value was chosen to
>> > prevent a poorly chosen value from dividing the address space in such
>> > a way as to prevent large allocations. This may not be an issue on all
>> > platforms. Allow the specification of a minimum number of bits so that
>> > platforms desiring greater ASLR protection may determine where to place
>> > the trade-off.
>> >
>> > --- a/kernel/sysctl.c
>> > +++ b/kernel/sysctl.c
>> > @@ -1568,6 +1568,28 @@ static struct ctl_table vm_table[] = {
>> >             .mode           = 0644,
>> >             .proc_handler   = proc_doulongvec_minmax,
>> >     },
>> > +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
>> > +   {
>> > +           .procname       = "mmap_rnd_bits",
>> > +           .data           = &mmap_rnd_bits,
>> > +           .maxlen         = sizeof(mmap_rnd_bits),
>> > +           .mode           = 0600,
>> > +           .proc_handler   = proc_dointvec_minmax,
>> > +           .extra1         = (void *) &mmap_rnd_bits_min,
>> > +           .extra2         = (void *) &mmap_rnd_bits_max,
>>
>> hm, why the typecasts?  They're unneeded and are omitted everywhere(?)
>> else in kernel/sysctl.c.
>
> Oh.  Casting away constness.
>
> What's the thinking here?  They can change at any time so they aren't
> const so we shouldn't declare them to be const?

The _min and _max values shouldn't be changing: they're decided based
on the various CONFIG options that calculate the valid min/maxes. Only
mmap_rnd_bits itself should be changing.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
