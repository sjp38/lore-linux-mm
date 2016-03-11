Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1796B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 20:52:28 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id d205so75589502oia.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 17:52:28 -0800 (PST)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id v3si4604170oie.34.2016.03.10.17.52.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 17:52:27 -0800 (PST)
Received: by mail-oi0-x231.google.com with SMTP id m82so75542075oif.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 17:52:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160310095601.GA9677@gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-4-git-send-email-mingo@kernel.org> <CALCETrXV34q4ViE46sHN6QxucmxoBYN0xKz4p7H9Cr=7VpwQUA@mail.gmail.com>
 <CALCETrUijqLwS98M_EnW5OH=CSv_SwjKGC5FkAxFEcWiq0RM2A@mail.gmail.com> <20160310095601.GA9677@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 10 Mar 2016 17:52:07 -0800
Message-ID: <CALCETrUDpzHV0mZXkg4QX9zspJKZ8vngA2_ybL6E+faiTJqpkw@mail.gmail.com>
Subject: Re: [PATCH 03/11] x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Mar 10, 2016 at 1:56 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Andy Lutomirski <luto@amacapital.net> wrote:
>
>> On Fri, Feb 12, 2016 at 11:04 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>> > On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
>> >> So when memory hotplug removes a piece of physical memory from pagetable
>> >> mappings, it also frees the underlying PGD entry.
>> >>
>> >> This complicates PGD management, so don't do this. We can keep the
>> >> PGD mapped and the PUD table all clear - it's only a single 4K page
>> >> per 512 GB of memory hotplugged.
>> >
>> > Ressurecting an ancient thread: I want this particular change to make
>> > it (much) easier to make vmapped stacks work correctly.  Could it be
>> > applied by itself?
>> >
>>
>> It's incomplete.  pageattr.c has another instance of the same thing.
>> I'll see if I can make it work, but I may end up doing something a
>> little different.
>
> If so then mind picking up (and fixing ;-) tip:WIP.x86/mm in its entirety? It's
> well tested so shouldn't have too many easy to hit bugs. Feel free to rebase and
> restructure it, it's a WIP tree.

I'll chew on this one patch a bit and see where the whole things go.
If I can rebase the rest on top, I'll use them.

BTW, how are current kernels possibly correct when this code runs?  We
zap a pgd from the init pgd.  I can't find any code that would try to
propagate that zapped pgd to other pgds.  Then, if we hotplug in some
more memory or claim the slot for vmap, we'll install a new pgd entry,
and we might access *that* through a different pgd.  There vmalloc
fault fixup won't help because the MMU will chase a stale pointer in
the old pgd.

So we might actually need this patch sooner rather than later.

>
> I keep getting distracted with other things but I'd hate if this got dropped on
> the floor.
>
> Thanks,
>
>         Ingo



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
