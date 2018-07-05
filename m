Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 565D46B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 11:44:20 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id x14-v6so8055227ybj.9
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 08:44:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v145-v6sor1479971ywa.71.2018.07.05.08.44.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 08:44:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180705145539.9627-1-osalvador@techadventures.net>
References: <20180705145539.9627-1-osalvador@techadventures.net>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 5 Jul 2018 08:44:18 -0700
Message-ID: <CAGXu5jL4O_qwwAHmW1C8q77Jv1fe_1JCq6iFxC73VySBkvHSQw@mail.gmail.com>
Subject: Re: [PATCH] fs, elf: Make sure to page align bss in load_elf_library
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Nicolas Pitre <nicolas.pitre@linaro.org>, Oscar Salvador <osalvador@suse.de>

On Thu, Jul 5, 2018 at 7:55 AM,  <osalvador@techadventures.net> wrote:
> From: Oscar Salvador <osalvador@suse.de>
>
> The current code does not make sure to page align bss before calling
> vm_brk(), and this can lead to a VM_BUG_ON() in __mm_populate()
> due to the requested lenght not being correctly aligned.
>
> Let us make sure to align it properly.
>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Tested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Reported-by: syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com

Wow. CONFIG_USELIB? I'm surprised distros are still using this. 32-bit
only, and libc5 and earlier only.

Regardless, this appears to match the current bss alignment logic in
the main elf loader, so:

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  fs/binfmt_elf.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 0ac456b52bdd..816cc921cf36 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -1259,9 +1259,8 @@ static int load_elf_library(struct file *file)
>                 goto out_free_ph;
>         }
>
> -       len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
> -                           ELF_MIN_ALIGN - 1);
> -       bss = eppnt->p_memsz + eppnt->p_vaddr;
> +       len = ELF_PAGEALIGN(eppnt->p_filesz + eppnt->p_vaddr);
> +       bss = ELF_PAGEALIGN(eppnt->p_memsz + eppnt->p_vaddr);
>         if (bss > len) {
>                 error = vm_brk(len, bss - len);
>                 if (error)
> --
> 2.13.6
>



-- 
Kees Cook
Pixel Security
