Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 029B86B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 09:52:53 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <986278020.2030861285581319128.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Date: Mon, 27 Sep 2010 06:52:43 -0700
In-Reply-To: <986278020.2030861285581319128.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	(caiqian@redhat.com's message of "Mon, 27 Sep 2010 05:55:19 -0400
	(EDT)")
Message-ID: <m1zkv3uwd0.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [PATCH 0/3] Generic support for revoking mappings
Sender: owner-linux-mm@kvack.org
To: caiqian@redhat.com
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
List-ID: <linux-mm.kvack.org>

caiqian@redhat.com writes:

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 6128dc8..00161a4 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2009,6 +2009,7 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
>                         removed_exe_file_vma(mm);
>                 fput(new->vm_file);
>         }
> +       unlink_anon_vmas(new);
>   out_free_mpol:
>         mpol_put(pol);
>   out_free_vma:
>
> It became this after manually merged them,

As a conflict resolution doesn't look wrong, but clearly I should rebase
on top of mmtom and see what is going on.

> @@ -2002,20 +2006,15 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
>                 return 0;
>  
>         /* Clean everything up if vma_adjust failed. */
> -       if (new->vm_ops && new->vm_ops->close)
> -               new->vm_ops->close(new);
> -       if (new->vm_file) {
> -               if (vma->vm_flags & VM_EXECUTABLE)
> -                       removed_exe_file_vma(mm);
> -               fput(new->vm_file);
> -       }
>         unlink_anon_vmas(new);
> +       remove_vma(new);
> + out_err:
> +       return err;
>   out_free_mpol:
>         mpol_put(pol);
>   out_free_vma:
>         kmem_cache_free(vm_area_cachep, new);
> - out_err:
> -       return err;
> +       goto out_err;
>  }

Is it possible that something did not recompile cleanly?  Where I
touched the struct address_space if everything did not rebuild it is
possible for two pieces of incrementally compiled code to think they are
accessing the same fields and are not.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
