Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5421A6B0253
	for <linux-mm@kvack.org>; Tue, 10 May 2016 13:49:20 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so16719153lfq.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 10:49:20 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id k194si2303671lfb.59.2016.05.10.10.49.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 10:49:18 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id y84so23622074lfc.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 10:49:18 -0700 (PDT)
Date: Tue, 10 May 2016 20:49:15 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: Getting rid of dynamic TASK_SIZE (on x86, at least)
Message-ID: <20160510174915.GJ14377@uranus.lan>
References: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
 <20160510163045.GH14377@uranus.lan>
 <CALCETrVFJN+ktqjGAMckVpUf3JA4_iJf2R1tXDG=WmwwwLEF-Q@mail.gmail.com>
 <20160510170545.GI14377@uranus.lan>
 <CALCETrWS5YpRMh00tH3Lx6yUNhzSti3kpema8nwv-d-jUKbGaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWS5YpRMh00tH3Lx6yUNhzSti3kpema8nwv-d-jUKbGaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Ruslan Kabatsayev <b7.10110111@gmail.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Pavel Emelyanov <xemul@parallels.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, May 10, 2016 at 10:26:05AM -0700, Andy Lutomirski wrote:
...
> >>
> >> It's annoying and ugly.  It also makes the idea of doing 32-bit CRIU
> >> restore by starting in 64-bit mode and switching to 32-bit more
> >> complicated because it requires switching TASK_SIZE.
> >
> > Well, you know I'm not sure it's that annoying. It serves as it should
> > for task limit. Sure we can add one more parameter into get-unmapped-addr
> > but same time the task-size will be present in say page faulting code
> > (the helper might be renamed but it will be here still).
> 
> Why should the page faulting code care at all what type of task it is?
> If there's a vma there, fault it in.  If there isn't, then don't.

__bad_area_nosemaphore
  ...
		/* Kernel addresses are always protection faults: */
		if (address >= TASK_SIZE)
			error_code |= PF_PROT;

For sure page faulting must consider what kind of fault is it.
Or we gonna drop such code at all?

> > Same applies
> > to arch_get_unmapped_area_topdown, should there be some argument
> > passed instead of open-coded TASK_SIZE helper?
> >
> > Don't get me wrong please, just trying to figure out how many code
> > places need to be patche if we start this procedure.
> >
> > As to starting restore in 64 bit and switch into 32 bit -- should
> > not we simply scan for "current" memory map and test if all areas
> > mapped belong to compat limit?
> 
> I don't see what's wrong with leaving a high vma around.  The task is
> unlikely to use it, but, if the task does use it (via long jump, for
> example), it'll worj.

True, from cpu perspective there is nothing wrong if in compat
(kernel compat) mode some memory slabs get left. Just thought
at first iteration we wanted unchanged behaviour.

> > And that's all. (Sorry I didn't
> > follow precisely on your and Dmitry's conversation so I quite
> > probably missing something obvious here).
> 
> It's not all.  We'd need an API to allow the task to cause TASK_SIZE
> to change from TASK_SIZE64 to TASK_SIZE32.  I don't want to add that
> API because I think its sole purpose is to work around kernel
> silliness, and I'd rather we just fixed the silliness.

I implied the change of task-size. Anyway, I see what you mean, thanks
for clarification. Still I think we won't be able to completely
replace task-size with task-size-mask. Some places such as base
for elf-dynload use it as a part of api (not directly though),
and at least in load_elf_binary the choose of base address should
be preserved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
