Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 663186B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 14:08:55 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id r185so103182112qkf.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 11:08:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 1si5987791qkk.154.2016.05.11.11.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 11:08:54 -0700 (PDT)
Date: Wed, 11 May 2016 20:08:47 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Getting rid of dynamic TASK_SIZE (on x86, at least)
Message-ID: <20160511180847.GA27195@redhat.com>
References: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
 <20160510182055.GA24868@redhat.com>
 <CALCETrU4me1X7oTriLgFQpTqwaebMsT5sdYZzjC=_EERXNbqzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrU4me1X7oTriLgFQpTqwaebMsT5sdYZzjC=_EERXNbqzA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Dmitry Safonov <0x7f454c46@gmail.com>, Borislav Petkov <bp@alien8.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Ruslan Kabatsayev <b7.10110111@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 05/10, Andy Lutomirski wrote:
>
> On May 10, 2016 11:21 AM, "Oleg Nesterov" <oleg@redhat.com> wrote:
> >
> > On 05/10, Andy Lutomirski wrote:
> > >
> > >  - xol_add_vma: This one is weird: uprobes really is doing something
> > > behind the task's back, and the addresses need to be consistent with
> > > the address width.  I'm not quite sure what to do here.
> >
> > It can use mm->task_size instead, plus this is just a hint. And perhaps
> > mm->task_size should have more users, say get_unmapped_area...
>
> Ick.  I hadn't noticed mm->task_size.  We have a *lot* of different
> indicators of task size.  mm->task_size appears to have basically no
> useful uses except maybe for ppc.
>
> On x86, bitness can change without telling the kernel, and tasks
> running in 64-bit mode can do 32-bit syscalls.

Sure, but imo this doesn't mean that mm->task_size or (say) is_64bit_mm()
make no sense.

> So maybe I should add mm->task_size to my list of things that would be
> nice to remove.  Or maybe I'm just tilting at windmills.

I dunno. But afaics there is no other way to look at foreign mm and find
out its limit. Say, the usage of mm->task_size in validate_range() looks
valid even if (afaics) nothing bad can happen if start/end >= task_size,
so validate_range() could just check that len+start doesn't overflow.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
