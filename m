Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB5E56B026C
	for <linux-mm@kvack.org>; Sun,  7 Jan 2018 04:02:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q1so4364737pgv.4
        for <linux-mm@kvack.org>; Sun, 07 Jan 2018 01:02:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m7si6754542pfi.179.2018.01.07.01.02.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 07 Jan 2018 01:02:33 -0800 (PST)
Date: Sun, 7 Jan 2018 10:02:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: ppc elf_map breakage with MAP_FIXED_NOREPLACE (was: Re: mmotm
 2018-01-04-16-19 uploaded)
Message-ID: <20180107090229.GB24862@dhcp22.suse.cz>
References: <5a4ec4bc.u5I/HzCSE6TLVn02%akpm@linux-foundation.org>
 <7e35e16a-d71c-2ec8-03ed-b07c2af562f8@linux.vnet.ibm.com>
 <20180105084631.GG2801@dhcp22.suse.cz>
 <e81dce2b-5d47-b7d3-efbf-27bc171ba4ab@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e81dce2b-5d47-b7d3-efbf-27bc171ba4ab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org

On Sun 07-01-18 12:19:32, Anshuman Khandual wrote:
> On 01/05/2018 02:16 PM, Michal Hocko wrote:
[...]
> > Could you give us more information about the failure please. Debugging
> > patch from http://lkml.kernel.org/r/20171218091302.GL16951@dhcp22.suse.cz
> > should help to see what is the clashing VMA.
> 
> Seems like its re-requesting the same mapping again.

It always seems to be the same mapping which is a bit strange as we
have multiple binaries here. Are these binaries any special? Does this
happen to all bianries (except for init which has obviously started
successfully)? Could you add an additional debugging (at the do_mmap
layer) to see who is requesting the mapping for the first time?

> [   23.423642] 9148 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
> [   23.423706] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon

I also find it a bit unexpected that this is an anonymous mapping
because the elf loader should always map a file backed one.

> [   23.426089] 9151 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
> [   23.426232] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
> [   23.429048] 9154 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
> [   23.429196] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
> [   23.482766] 9164 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
> [   23.482904] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
> [   23.485849] 9167 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
> [   23.485945] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
> [   76.041836] 9262 (hostname): Uhuuh, elf segment at 0000000010020000 requested but the memory is mapped already
> [   76.041965] requested [10020000, 10030000] mapped [10020000, 10030000] 100073 anon
> [   76.207197] 9285 (pkg-config): Uhuuh, elf segment at 0000000010020000 requested but the memory is mapped already
> [   76.207326] requested [10020000, 10030000] mapped [10020000, 10030000] 100073 anon
> [   76.371073] 9299 (sed): Uhuuh, elf segment at 0000000010030000 requested but the memory is mapped already
> [   76.371165] requested [10030000, 10040000] mapped [10030000, 10040000] 100073 anon
> 
> 
> I have fixed/changed the debug patch a bit
> 
> 
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index d8c5657..a43eccaa 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -372,11 +372,35 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
>         } else
>                 map_addr = vm_mmap(filep, addr, size, prot, type, off);
> 
> -       if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr))
> +       if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr)) {
> +               struct vm_area_struct *vma;
> +               unsigned long end;
> +
> +               if (total_size)
> +                       end = addr + total_size;
> +               else
> +                       end = addr + size;
> +
>                 pr_info("%d (%s): Uhuuh, elf segment at %p requested but the memory is mapped already\n",
>                                 task_pid_nr(current), current->comm,
>                                 (void *)addr);
> 
> +               vma = find_vma(current->mm, addr);
> +               if (vma && vma->vm_start <= addr) {
> +                       pr_info("requested [%lx, %lx] mapped [%lx, %lx] %lx ", addr, end,
> +                                       vma->vm_start, vma->vm_end, vma->vm_flags);
> +                       if (!vma->vm_file) {
> +                               pr_cont("anon\n");
> +                       } else {
> +                               char path[512];
> +                               char *p = file_path(vma->vm_file, path, sizeof(path));
> +                               if (IS_ERR(p))
> +                                       p = "?";
> +                               pr_cont("\"%s\"\n", kbasename(p));
> +                       }
> +                       dump_stack();
> +               }
> +       }
>         return(map_addr);
>  }
> 
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
