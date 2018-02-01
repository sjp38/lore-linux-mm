Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE966B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 16:06:27 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id l205so11705917vke.13
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 13:06:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f73sor245770vke.104.2018.02.01.13.06.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Feb 2018 13:06:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180201134829.GL21609@dhcp22.suse.cz>
References: <5acba3c2-754d-e449-24ff-a72a0ad0d895@linux.vnet.ibm.com>
 <20180126140415.GD5027@dhcp22.suse.cz> <15da8c87-e6db-13aa-01c8-a913656bfdb6@linux.vnet.ibm.com>
 <6db9b33d-fd46-c529-b357-3397926f0733@linux.vnet.ibm.com> <20180129132235.GE21609@dhcp22.suse.cz>
 <87k1w081e7.fsf@concordia.ellerman.id.au> <20180130094205.GS21609@dhcp22.suse.cz>
 <5eccdc1b-6a10-b48a-c63f-295f69473d97@linux.vnet.ibm.com> <20180131131937.GA6740@dhcp22.suse.cz>
 <bfecda5e-ae8b-df91-0add-df6322b42a70@linux.vnet.ibm.com> <20180201134829.GL21609@dhcp22.suse.cz>
From: Kees Cook <keescook@google.com>
Date: Fri, 2 Feb 2018 08:06:25 +1100
Message-ID: <CAGXu5jJMQ0HK2NeRw9VmZmOkuaw2g8tAf2yZ-OxfwZBTXxuZMw@mail.gmail.com>
Subject: Re: ppc elf_map breakage with MAP_FIXED_NOREPLACE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-Next <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Mark Brown <broonie@kernel.org>

On Fri, Feb 2, 2018 at 12:48 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 01-02-18 08:43:34, Anshuman Khandual wrote:
> [...]
>> $dmesg | grep elf_brk
>> [    9.571192] elf_brk 10030328 elf_bss 10030000
>>
>> static int load_elf_binary(struct linux_binprm *bprm)
>> ---------------------
>>
>>       if (unlikely (elf_brk > elf_bss)) {
>>                       unsigned long nbyte;
>>
>>                       /* There was a PT_LOAD segment with p_memsz > p_filesz
>>                          before this one. Map anonymous pages, if needed,
>>                          and clear the area.  */
>>                       retval = set_brk(elf_bss + load_bias,
>>                                        elf_brk + load_bias,
>>                                        bss_prot);
>>
>>
>> ---------------------
>
> Just a blind shot... Does the following make any difference?
> ---
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 021fe78998ea..04b24d00c911 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -895,7 +895,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>            the correct location in memory. */
>         for(i = 0, elf_ppnt = elf_phdata;
>             i < loc->elf_ex.e_phnum; i++, elf_ppnt++) {
> -               int elf_prot = 0, elf_flags;
> +               int elf_prot = 0, elf_flags, elf_fixed = MAP_FIXED_NOREPLACE;
>                 unsigned long k, vaddr;
>                 unsigned long total_size = 0;
>
> @@ -927,6 +927,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                                          */
>                                 }
>                         }
> +                       elf_fixed = MAP_FIXED;
>                 }
>
>                 if (elf_ppnt->p_flags & PF_R)
> @@ -944,7 +945,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                  * the ET_DYN load_addr calculations, proceed normally.
>                  */
>                 if (loc->elf_ex.e_type == ET_EXEC || load_addr_set) {
> -                       elf_flags |= MAP_FIXED_NOREPLACE;
> +                       elf_flags |= elf_fixed;
>                 } else if (loc->elf_ex.e_type == ET_DYN) {
>                         /*
>                          * This logic is run once for the first LOAD Program
> @@ -980,7 +981,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                                 load_bias = ELF_ET_DYN_BASE;
>                                 if (current->flags & PF_RANDOMIZE)
>                                         load_bias += arch_mmap_rnd();
> -                               elf_flags |= MAP_FIXED_NOREPLACE;
> +                               elf_flags |= elf_fixed;
>                         } else
>                                 load_bias = 0;

If I'm reading this patch correctly, the intention is to allow LOADs
after brk-expansion to collide with the prior LOAD? (This patch will
need more comments for our future sanity.) I think this makes sense,
though it might be nice to be sure we're overlapping only with the
prior LOAD (and nothing else), but it's not clear to me the best way
to accomplish that here. Even without that extra check, I think this
is a net benefit (i.e. gain MAP_FIXED_NOREPLACE without breaking
page-crossing LOADs).

Actually, maybe the second LOAD could be page-aligned first, so it
doesn't collide with the prior LOAD, and it could keep
MAP_FIXED_NOREPLACE? I'll have more time to study this on Monday...

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
