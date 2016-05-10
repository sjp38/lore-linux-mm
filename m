Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D33F76B0005
	for <linux-mm@kvack.org>; Tue, 10 May 2016 13:05:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m64so15793704lfd.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 10:05:49 -0700 (PDT)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id p13si2144831lfd.169.2016.05.10.10.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 10:05:48 -0700 (PDT)
Received: by mail-lf0-x22a.google.com with SMTP id u64so22257322lff.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 10:05:48 -0700 (PDT)
Date: Tue, 10 May 2016 20:05:45 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: Getting rid of dynamic TASK_SIZE (on x86, at least)
Message-ID: <20160510170545.GI14377@uranus.lan>
References: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
 <20160510163045.GH14377@uranus.lan>
 <CALCETrVFJN+ktqjGAMckVpUf3JA4_iJf2R1tXDG=WmwwwLEF-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVFJN+ktqjGAMckVpUf3JA4_iJf2R1tXDG=WmwwwLEF-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Ruslan Kabatsayev <b7.10110111@gmail.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Pavel Emelyanov <xemul@parallels.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, May 10, 2016 at 09:45:34AM -0700, Andy Lutomirski wrote:
> On Tue, May 10, 2016 at 9:30 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> > On Tue, May 10, 2016 at 09:07:49AM -0700, Andy Lutomirski wrote:
> >> Hi all-
> >>
> >> I'm trying to get rid of x86's dynamic TASK_SIZE and just redefine it
> >> to TASK_SIZE_MAX.  So far, these are the TASK_SIZE users that actually
> >> seem to care about the task in question:
> >>
> >> get_unmapped_area.  This is used by mmap, mremap, exec, uprobe XOL,
> >> and maybe some other things.
> >>
> >>  - mmap, mremap, etc: IMO this should check in_compat_syscall, not
> >> TIF_ADDR32.  If a 64-bit task does an explicit 32-bit mmap (using int
> >> $0x80, for example), it should get a 32-bit address back.
> >>
> >>  - xol_add_vma: This one is weird: uprobes really is doing something
> >> behind the task's back, and the addresses need to be consistent with
> >> the address width.  I'm not quite sure what to do here.
> >>
> >>  - exec.  This wants to set up mappings that are appropriate for the new task.
> >>
> >> My inclination would be add a new 'limit' parameter to all the
> >> get_unmapped_area variants and possible to vm_brk and friends and to
> >> thus push the decision into the callers.  For the syscalls, we could
> >> add:
> >>
> >> static inline unsigned long this_syscall_addr_limit(void) { return TASK_SIZE; }
> >>
> >> and override it on x86.
> >>
> >> I'm not super excited to write that patch, though...
> >
> > Andy, could you please highlight what's wrong with TASK_SIZE helper
> > in first place? The idea behind is to clean up the code or there
> > some real problem?
> 
> It's annoying and ugly.  It also makes the idea of doing 32-bit CRIU
> restore by starting in 64-bit mode and switching to 32-bit more
> complicated because it requires switching TASK_SIZE.

Well, you know I'm not sure it's that annoying. It serves as it should
for task limit. Sure we can add one more parameter into get-unmapped-addr
but same time the task-size will be present in say page faulting code
(the helper might be renamed but it will be here still). Same applies
to arch_get_unmapped_area_topdown, should there be some argument
passed instead of open-coded TASK_SIZE helper?

Don't get me wrong please, just trying to figure out how many code
places need to be patche if we start this procedure.

As to starting restore in 64 bit and switch into 32 bit -- should
not we simply scan for "current" memory map and test if all areas
mapped belong to compat limit? And that's all. (Sorry I didn't
follow precisely on your and Dmitry's conversation so I quite
probably missing something obvious here).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
