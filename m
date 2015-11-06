Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id CFDD982F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 15:52:33 -0500 (EST)
Received: by igbhv6 with SMTP id hv6so43464799igb.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:52:33 -0800 (PST)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id x7si778737igw.73.2015.11.06.12.52.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 12:52:32 -0800 (PST)
Received: by igvi2 with SMTP id i2so41602919igv.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:52:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <563BA393.9020504@android.com>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<1446574204-15567-2-git-send-email-dcashman@android.com>
	<CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
	<56393FD0.6080001@android.com>
	<CAGXu5jLe=OgZ2DG_MRXA8x6BwpEd77fNZBj3wjbDiSdiBurz7w@mail.gmail.com>
	<563A4EDC.6090403@android.com>
	<563BA393.9020504@android.com>
Date: Fri, 6 Nov 2015 12:52:32 -0800
Message-ID: <CAGXu5j+2xiRwt6mKrjzuf9O745GWOcjXzutONp6rz_Kj+3PfVQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>, Michael Ellerman <michael@ellerman.id.au>

On Thu, Nov 5, 2015 at 10:44 AM, Daniel Cashman <dcashman@android.com> wrote:
> On 11/04/2015 10:30 AM, Daniel Cashman wrote:
>> On 11/3/15 3:21 PM, Kees Cook wrote:
>>> On Tue, Nov 3, 2015 at 3:14 PM, Daniel Cashman <dcashman@android.com> wrote:
>>>> On 11/03/2015 11:19 AM, Kees Cook wrote:
>>>>> Do you have patches for x86 and arm64?
>>>>
>>>> I was holding off on those until I could gauge upstream reception.  If
>>>> desired, I could put those together and add them as [PATCH 3/4] and
>>>> [PATCH 4/4].
>>>
>>> If they're as trivial as I'm hoping, yeah, let's toss them in now. If
>>> not, skip 'em. PowerPC, MIPS, and s390 should be relatively simple
>>> too, but one or two of those have somewhat stranger calculations when
>>> I looked, so their Kconfigs may not be as clean.
>>
>> Creating the patches should be simple, it's the choice of minimum and
>> maximum values for each architecture that I'd be most concerned about.
>> I'll put them together, though, and the ranges can be changed following
>> discussion with those more knowledgeable, if needed.  I also don't have
>> devices on which to test the PowerPC, MIPS and s390 changes, so I'll
>> need someone's help for that.
>
> Actually, in preparing the x86 and arm64 patches, it became apparent
> that the current patch-set does not address 32-bit executables running
> on 64-bit systems (compatibility mode), since only one procfs
> mmap_rnd_bits variable is created and exported. Some possible solutions:
>
> 1) Create a second set for compatibility, e.g. mmap_rnd_compat_bits,
> mmap_rnd_compat_bits_min, mmap_rnd_compat_bits_max and export it as with
> mmap_rnd_bits.  This provides the most control and is truest to the
> spirit of this patch, but pollutes the Kconfigs and procfs a bit more,
> especially if we ever need a mmap_rnd_64compat_bits...
>
> 2) Get rid of the arch-independent nature of this patch and instead let
> each arch define its own Kconfig values and procfs entries. Essentially
> the same outcome as the above, but with less disruption in the common
> kernel code, although also with a potentially variable ABI.
>
> 3) Default to the lowest-supported, e.g. arm64 running with
> CONFIG_COMPAT would be limited to the same range as arm.  This solution
> I think is highly undesirable, as it actually makes things worse for
> existing 64-bit platforms.
>
> 4) Support setting the COMPAT values by Kconfig, but don't expose them
> via procfs.  This keeps the procfs change simple and gets most of its
> benefits.
>
> 5) Leave the COMPAT values specified in code, and only adjust introduce
> config and tunable options for the 64-bit processes.  Basically keep
> this patch-set as-is and not give any benefit to compatible applications.
>
> My preference would be for either solutions 1 or 4, but would love
> feedback and/or other solutions. Thoughts?

How about a single new CONFIG+sysctl that is the compat delta. For
example, on x86, it's 20 bits. Then we don't get splashed with a whole
new set of min/maxes, but we can reasonably control compat?

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
