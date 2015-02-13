Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0D46B0093
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 18:25:27 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so25008372obb.13
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 15:25:27 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id k10si1870970oen.92.2015.02.13.15.25.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Feb 2015 15:25:26 -0800 (PST)
Received: by mail-ob0-f181.google.com with SMTP id vb8so25593407obc.12
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 15:25:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1502132316320.4925@pobox.suse.cz>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
	<CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
	<alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
	<CAGXu5jKSfGzkpNt1-_vRykDCJTCxJg+vRi1D_9a=8auKu-YtgQ@mail.gmail.com>
	<alpine.LNX.2.00.1502132316320.4925@pobox.suse.cz>
Date: Fri, 13 Feb 2015 15:25:26 -0800
Message-ID: <CAGXu5jL3UMkeHpAxe1RBpnQhLWGquR1NJQx1AsukiwA31AA78g@mail.gmail.com>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Fri, Feb 13, 2015 at 2:20 PM, Jiri Kosina <jkosina@suse.cz> wrote:
> On Fri, 13 Feb 2015, Kees Cook wrote:
>
>> > Commit e2b32e678 ("x86, kaslr: randomize module base load address") makes
>> > the base address for module to be unconditionally randomized in case when
>> > CONFIG_RANDOMIZE_BASE is defined and "nokaslr" option isn't present on the
>> > commandline.
>> >
>> > This is not consistent with how choose_kernel_location() decides whether
>> > it will randomize kernel load base.
>> >
>> > Namely, CONFIG_HIBERNATION disables kASLR (unless "kaslr" option is
>> > explicitly specified on kernel commandline), which makes the state space
>> > larger than what module loader is looking at. IOW CONFIG_HIBERNATION &&
>> > CONFIG_RANDOMIZE_BASE is a valid config option, kASLR wouldn't be applied
>> > by default in that case, but module loader is not aware of that.
>> >
>> > Instead of fixing the logic in module.c, this patch takes more generic
>> > aproach. It introduces a new bootparam setup data_type SETUP_KASLR and
>> > uses that to pass the information whether kaslr has been applied during
>> > kernel decompression, and sets a global 'kaslr_enabled' variable
>> > accordingly, so that any kernel code (module loading, livepatching, ...)
>> > can make decisions based on its value.
>> >
>> > x86 module loader is converted to make use of this flag.
>> >
>> > Signed-off-by: Jiri Kosina <jkosina@suse.cz>
>>
>> Thanks for working on this! If others are happy with the setup_data
>> approach, I think this is fine.
>
> This is for x86 folks to decide. I hope my original CC covers this, so
> let's wait for their verdict.
>
>> My only concern is confusion over seeing SETUP_KASLR that was added by a
>> boot loader.
>
> Well, so you are concerned about bootloader that is evil on purpose?

No, no; I agree: a malicious boot loader is a lost cause. I mean
mostly from a misbehavior perspective. Like, someone sees "kaslr" in
the setup args and thinks they can set it to 1 and boot a kernel, etc.
Or they set it to 0, but they lack HIBERNATION and "1" gets appended,
but the setup_data parser sees the boot-loader one set to 0, etc. I'm
just curious if we should avoid getting some poor system into a
confusing state.

>
> If you have such bootloader, you are screwed anyway, because it's free to
> setup asynchronous events that will corrupt your kernel anyway (DMA that
> will happen only after the loaded kernel is already active, for example).
> If you want to avoid evil bootloaders, secure boot is currently The
> option, I am afraid.
>
>> Another way to handle it might be to do some kind of relocs-like poking
>> of a value into the decompressed kernel?
>
> This is so hackish that I'd like to avoid it in favor of the boot params
> aproach as much as possbile :)

Yeah, I think so too. :)

>
> [ ... snip ... ]
>> > diff --git a/arch/x86/boot/compressed/aslr.c b/arch/x86/boot/compressed/aslr.c
>> > index bb13763..d9d1da9 100644
>> > --- a/arch/x86/boot/compressed/aslr.c
>> > +++ b/arch/x86/boot/compressed/aslr.c
>> > @@ -14,6 +14,13 @@
>> >  static const char build_str[] = UTS_RELEASE " (" LINUX_COMPILE_BY "@"
>> >                 LINUX_COMPILE_HOST ") (" LINUX_COMPILER ") " UTS_VERSION;
>> >
>> > +struct kaslr_setup_data {
>>
>> Should this be "static"?
>
> Good catch. So let's wait what x86 folks have to say. I'll either update
> in in v3, or hopefully someone will fix this when applying the patch for
> -tip.

Great!

-Kees

>
> Thanks,
>
> --
> Jiri Kosina
> SUSE Labs



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
