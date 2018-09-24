Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7ABF88E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 16:03:39 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id q141-v6so10647232ywg.5
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 13:03:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h129-v6sor31797yba.91.2018.09.24.13.03.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 13:03:38 -0700 (PDT)
Received: from mail-yb1-f180.google.com (mail-yb1-f180.google.com. [209.85.219.180])
        by smtp.gmail.com with ESMTPSA id e194-v6sm383307ywe.8.2018.09.24.13.03.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 13:03:35 -0700 (PDT)
Received: by mail-yb1-f180.google.com with SMTP id 5-v6so8785524ybf.3
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 13:03:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1537815554.19013.49.camel@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com>
 <1536874298-23492-4-git-send-email-rick.p.edgecombe@intel.com>
 <CAGXu5jJj+08J9UeyQs5ku8CziYWA72iJ+hxMR2Z2tLiVwvU8MA@mail.gmail.com> <1537815554.19013.49.camel@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 24 Sep 2018 13:03:33 -0700
Message-ID: <CAGXu5j+w0mHMSjcwRcQuyvfRa+XSy2zs7kLYj+qNpnokfSwb3A@mail.gmail.com>
Subject: Re: [PATCH v6 3/4] vmalloc: Add debugfs modfraginfo
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jannh@google.com" <jannh@google.com>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

On Mon, Sep 24, 2018 at 11:58 AM, Edgecombe, Rick P
<rick.p.edgecombe@intel.com> wrote:
> On Fri, 2018-09-21 at 11:56 -0700, Kees Cook wrote:
>> On Thu, Sep 13, 2018 at 2:31 PM, Rick Edgecombe
>> <rick.p.edgecombe@intel.com> wrote:
>> > +done:
>> > +       gap = (MODULES_END - last_end);
>> > +       if (gap > largest_free)
>> > +               largest_free = gap;
>> > +       total_free += gap;
>> > +
>> > +       spin_unlock(&vmap_area_lock);
>> > +
>> > +       seq_printf(m, "\tLargest free space:\t%lu kB\n", largest_free /
>> > 1024);
>> > +       seq_printf(m, "\t  Total free space:\t%lu kB\n", total_free / 1024);
>> > +
>> > +       if (IS_ENABLED(CONFIG_RANDOMIZE_BASE) && kaslr_enabled())
>> > +               seq_printf(m, "Allocations in backup area:\t%lu\n",
>> > backup_cnt);
>> I don't think the IS_ENABLED is needed here?
> The reason for this is that for ARCH=um, CONFIG_X86_64 is defined but
> kaslr_enabled is not. kaslr_enabled is declared above to protect against a
> compiler error.
>
> So IS_ENABLED(CONFIG_RANDOMIZE_BASE) is protecting kaslr_enabled from causing a
> linker error. It gets constant evaluated to 0 and the compiler optimizes out the
> kaslr_enabled call. Thought it was better to guard with CONFIG_RANDOMIZE_BASE
> than with CONFIG_UM, to try to catch the broader situation. I guess I could move
> it to a helper inside ifdefs instead. Was trying to keep the ifdef-ed code down.

Ah yes, UM. Perhaps kaslr_enabled() could be defined somewhere so that
it would link sanely? (Maybe in module.h?)

>> I wonder if there is a better way to arrange this code that uses fewer
>> ifdefs, etc. Maybe a single CONFIG that capture whether or not
>> fine-grained module randomization is built in, like:
>>
>> config RANDOMIZE_FINE_MODULE
>>     def_bool y if RANDOMIZE_BASE && X86_64
>>
>> #ifdef CONFIG_RANDOMIZE_FINE_MODULE
>> ...
>> #endif
>>
>> But that doesn't capture the DEBUG_FS and PROC_FS bits ... so ...
>> maybe not worth it. I guess, either way:
> Hmmm, didn't know about that. Would clean it up some at least.
>
> I wish the debugfs info could be in module.c to help with this IFDEFs, but it
> needs vmalloc internals. MODULES_VADDR is not standardized across the ARCH's as
> well, so this was my best attempt to implement this without having to make
> changes in other architectures.

Yeah, I've long wanted to try to sandardize the module+vmalloc guts,
but it's just different enough in each architecture that it eludes
people.

-Kees

-- 
Kees Cook
Pixel Security
