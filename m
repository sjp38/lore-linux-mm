Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 713416B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 20:35:51 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q11-v6so5240759oih.15
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 17:35:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 189-v6si1651470oid.384.2018.07.04.17.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 17:35:49 -0700 (PDT)
Message-Id: <201807050035.w650Z4RT018631@www262.sakura.ne.jp>
Subject: Re: kernel BUG at mm/gup.c:LINE!
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 05 Jul 2018 09:35:04 +0900
References: <20180704121107.GL22503@dhcp22.suse.cz> <20180704151529.GA23317@techadventures.net>
In-Reply-To: <20180704151529.GA23317@techadventures.net>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, viro@zeniv.linux.org.uk
Cc: Michal Hocko <mhocko@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

Oscar Salvador wrote:
> Anyway, I just gave it a try, and making sure that bss gets page aligned seems to
> "fix" the issue (at the process doesn't hang anymore):
> 
> -       bss = eppnt->p_memsz + eppnt->p_vaddr;
> +       bss = ELF_PAGESTART(eppnt->p_memsz + eppnt->p_vaddr);
> 	if (bss > len) {
>                 error = vm_brk(len, bss - len);
> 
> Although I'm not sure about the correctness of this.

static int set_brk(unsigned long start, unsigned long end, int prot)
{
        start = ELF_PAGEALIGN(start);
        end = ELF_PAGEALIGN(end);
        if (end > start) {
                /*
                 * Map the last of the bss segment.
                 * If the header is requesting these pages to be
                 * executable, honour that (ppc32 needs this).
                 */
                int error = vm_brk_flags(start, end - start,
                                prot & PROT_EXEC ? VM_EXEC : 0);
                if (error)
                        return error;
        }
        current->mm->start_brk = current->mm->brk = end;
        return 0;
}

static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
                struct file *interpreter, unsigned long *interp_map_addr,
                unsigned long no_base, struct elf_phdr *interp_elf_phdata)
{
(...snipped...)
        /*
         * Next, align both the file and mem bss up to the page size,
         * since this is where elf_bss was just zeroed up to, and where
         * last_bss will end after the vm_brk_flags() below.
         */
        elf_bss = ELF_PAGEALIGN(elf_bss);
        last_bss = ELF_PAGEALIGN(last_bss);
        /* Finally, if there is still more bss to allocate, do it. */
        if (last_bss > elf_bss) {
                error = vm_brk_flags(elf_bss, last_bss - elf_bss,
                                bss_prot & PROT_EXEC ? VM_EXEC : 0);
                if (error)
                        goto out;
        }
(...snipped...)
}

static int load_elf_library(struct file *file)
{
(...snipped...)
        len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
                            ELF_MIN_ALIGN - 1);
        bss = eppnt->p_memsz + eppnt->p_vaddr;
        if (bss > len) {
                error = vm_brk(len, bss - len);
                if (error)
                        goto out_free_ph;
        }
(...snipped...)
}

So, indeed "bss" needs to be aligned.
But ELF_PAGESTART() or ELF_PAGEALIGN(), which one to use?

#define ELF_PAGESTART(_v) ((_v) & ~(unsigned long)(ELF_MIN_ALIGN-1))
#define ELF_PAGEALIGN(_v) (((_v) + ELF_MIN_ALIGN - 1) & ~(ELF_MIN_ALIGN - 1))

Is

-	len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
-			    ELF_MIN_ALIGN - 1);
+	len = ELF_PAGEALIGN(eppnt->p_filesz + eppnt->p_vaddr);

suggesting that

-	bss = eppnt->p_memsz + eppnt->p_vaddr;
+	bss = ELF_PAGEALIGN(eppnt->p_memsz + eppnt->p_vaddr);

is the right choice? I don't know...
