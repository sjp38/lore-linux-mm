Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 311776B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 12:55:21 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id l75so3769043vke.20
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:55:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k31sor1672998uad.301.2018.04.19.09.55.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 09:55:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <db2f91ab-9565-7bda-b3c3-a1cdb61d1587@linux.intel.com>
References: <20180406205501.24A1A4E7@viggo.jf.intel.com> <20180406205518.E3D989EB@viggo.jf.intel.com>
 <CAGXu5jJS-PYS7ONy_neDQCqVGRwrtjg=VdktXALQnzRe1+RNuA@mail.gmail.com> <db2f91ab-9565-7bda-b3c3-a1cdb61d1587@linux.intel.com>
From: Kees Cook <keescook@google.com>
Date: Thu, 19 Apr 2018 09:55:16 -0700
Message-ID: <CAGXu5jJWOPLDsj4ZtF=q+D4r4nFBfH+7Q6+zqhKhxiUKwbxNew@mail.gmail.com>
Subject: Re: [PATCH 11/11] x86/pti: leave kernel text global for !PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, namit@vmware.com

On Thu, Apr 19, 2018 at 9:02 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 04/18/2018 05:11 PM, Kees Cook wrote:
>> On Fri, Apr 6, 2018 at 1:55 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>>> +/*
>>> + * For some configurations, map all of kernel text into the user page
>>> + * tables.  This reduces TLB misses, especially on non-PCID systems.
>>> + */
>>> +void pti_clone_kernel_text(void)
>>> +{
>>> +       unsigned long start = PFN_ALIGN(_text);
>>> +       unsigned long end = ALIGN((unsigned long)_end, PMD_PAGE_SIZE);
>> I think this is too much set global: _end is after data, bss, and brk,
>> and all kinds of other stuff that could hold secrets. I think this
>> should match what mark_rodata_ro() is doing and use
>> __end_rodata_hpage_align. (And on i386, this should be maybe _etext.)
>
> Sounds reasonable to me.  This does assume that there are no secrets
> built into the kernel image, right?

It's hard to say, but I was trying to consider the basic threat model
of having your kernel image available to an attacker (i.e. a distro
kernel can be examined from packages, etc). In that case, the text and
rodata are readable through much more direct mechanisms. Everything
after rodata is run-time state, and should be excluded in the general
case.

I would expect more paranoid system builders to boot with "pti=on",
but perhaps we should disable Global under other specific CONFIGs, or
make a specific CONFIG for it that other options can select, probably.

-Kees

-- 
Kees Cook
Pixel Security
