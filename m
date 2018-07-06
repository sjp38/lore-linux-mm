Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2ACF6B0269
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:23:40 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id w16-v6so6466922ywj.7
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:23:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w186-v6sor2377833yba.24.2018.07.06.12.23.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 12:23:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180706071323.GA7959@techadventures.net>
References: <20180705145539.9627-1-osalvador@techadventures.net>
 <CAGXu5jL4O_qwwAHmW1C8q77Jv1fe_1JCq6iFxC73VySBkvHSQw@mail.gmail.com> <20180706071323.GA7959@techadventures.net>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 6 Jul 2018 12:23:38 -0700
Message-ID: <CAGXu5jJXC39v_asc9EKkYWMdUvKxdj7Z1fjH+=fwdeOVm0cfpw@mail.gmail.com>
Subject: Re: [PATCH] fs, elf: Make sure to page align bss in load_elf_library
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Nicolas Pitre <nicolas.pitre@linaro.org>, Oscar Salvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jul 6, 2018 at 12:13 AM, Oscar Salvador
<osalvador@techadventures.net> wrote:
> On Thu, Jul 05, 2018 at 08:44:18AM -0700, Kees Cook wrote:
>> On Thu, Jul 5, 2018 at 7:55 AM,  <osalvador@techadventures.net> wrote:
>> > From: Oscar Salvador <osalvador@suse.de>
>> >
>> > The current code does not make sure to page align bss before calling
>> > vm_brk(), and this can lead to a VM_BUG_ON() in __mm_populate()
>> > due to the requested lenght not being correctly aligned.
>> >
>> > Let us make sure to align it properly.
>> >
>> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
>> > Tested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
>> > Reported-by: syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com
>>
>> Wow. CONFIG_USELIB? I'm surprised distros are still using this. 32-bit
>> only, and libc5 and earlier only.
>>
>> Regardless, this appears to match the current bss alignment logic in
>> the main elf loader, so:
>>
>> Acked-by: Kees Cook <keescook@chromium.org>
>>
>> -Kees
>>
>> > ---
>> >  fs/binfmt_elf.c | 5 ++---
>> >  1 file changed, 2 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
>> > index 0ac456b52bdd..816cc921cf36 100644
>> > --- a/fs/binfmt_elf.c
>> > +++ b/fs/binfmt_elf.c
>> > @@ -1259,9 +1259,8 @@ static int load_elf_library(struct file *file)
>> >                 goto out_free_ph;
>> >         }
>> >
>> > -       len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
>> > -                           ELF_MIN_ALIGN - 1);
>> > -       bss = eppnt->p_memsz + eppnt->p_vaddr;
>> > +       len = ELF_PAGEALIGN(eppnt->p_filesz + eppnt->p_vaddr);
>> > +       bss = ELF_PAGEALIGN(eppnt->p_memsz + eppnt->p_vaddr);
>> >         if (bss > len) {
>> >                 error = vm_brk(len, bss - len);
>> >                 if (error)
>> > --
>> > 2.13.6
>> >
> CC Andrew
>
> Hi Andrew,
>
> in case this patch gets accepted, does it have to go through your tree?
> Or is it for someone else to take it?

(FWIW, binfmt_elf changes have traditionally gone through -mm, yes.)

-Kees

-- 
Kees Cook
Pixel Security
