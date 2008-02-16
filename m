Received: by py-out-1112.google.com with SMTP id f47so1042388pye.20
        for <linux-mm@kvack.org>; Sat, 16 Feb 2008 04:12:01 -0800 (PST)
Message-ID: <8bd0f97a0802160412ve49103cya446b89d8560458b@mail.gmail.com>
Date: Sat, 16 Feb 2008 07:12:01 -0500
From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] procfs task exe symlink
In-Reply-To: <1202348669.9062.271.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1202348669.9062.271.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@tv-sign.ru>, David Howells <dhowells@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Christoph Hellwig <chellwig@de.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Bryan Wu <Bryan.Wu@analog.com>
List-ID: <linux-mm.kvack.org>

On Feb 6, 2008 8:44 PM, Matt Helsley <matthltc@us.ibm.com> wrote:
> The kernel implements readlink of /proc/pid/exe by getting the file from the
> first executable VMA. Then the path to the file is reconstructed and reported as
> the result.
>
> Because of the VMA walk the code is slightly different on nommu systems. This
> patch avoids separate /proc/pid/exe code on nommu systems. Instead of walking
> the VMAs to find the first executable file-backed VMA we store a reference to
> the exec'd file in the mm_struct.
>
> That reference would prevent the filesystem holding the executable file from
> being unmounted even after unmapping the VMAs. So we track the number of
> VM_EXECUTABLE VMAs and drop the new reference when the last one is unmapped.
> This avoids pinning the mounted filesystem.
>
> Andrew, these are the updates I promised. Please consider this patch for
> inclusion in -mm.

mm/nommu.c wasnt compiled tested, it's trivially broken:

> --- linux-2.6.24.orig/mm/nommu.c
> +++ linux-2.6.24/mm/nommu.c
> @@ -960,12 +960,15 @@ unsigned long do_mmap_pgoff(struct file
>         if (!vma)
>                 goto error_getting_vma;
>
>         INIT_LIST_HEAD(&vma->anon_vma_node);
>         atomic_set(&vma->vm_usage, 1);
> -       if (file)
> +       if (file) {
>                 get_file(file);
> +               if (vm_flags & VM_EXECUTABLE)
> +                       added_exe_file_vma(mm);
> +       }
>         vma->vm_file    = file;
>         vma->vm_flags   = vm_flags;
>         vma->vm_start   = addr;
>         vma->vm_end     = addr + len;
>         vma->vm_pgoff   = pgoff;

this function has no variable named "mm"

mm/nommu.c: In function 'do_mmap_pgoff':
mm/nommu.c:968: error: 'mm' undeclared (first use in this function)
mm/nommu.c:968: error: (Each undeclared identifier is reported only once
mm/nommu.c:968: error: for each function it appears in.)
make[1]: *** [mm/nommu.o] Error 1
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
