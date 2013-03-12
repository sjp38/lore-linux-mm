Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 1DF5A6B0006
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 20:24:34 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id rr4so4323334pbb.27
        for <linux-mm@kvack.org>; Mon, 11 Mar 2013 17:24:33 -0700 (PDT)
Date: Mon, 11 Mar 2013 17:24:29 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 4/9] mm: use mm_populate() for blocking remap_file_pages()
Message-ID: <20130312002429.GA24360@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
 <1356050997-2688-5-git-send-email-walken@google.com>
 <CA+ydwtqD67m9_JLCNwvdP72rko93aTkVgC-aK4TacyyM5DoCTA@mail.gmail.com>
 <20130311160322.830cc6b670fd24faa8366413@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130311160322.830cc6b670fd24faa8366413@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tommi Rantala <tt.rantala@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

(Sorry for the late reply)

On Mon, Mar 11, 2013 at 4:03 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Sun, 10 Mar 2013 20:55:21 +0200 Tommi Rantala <tt.rantala@gmail.com> wrote:
>
>> 2012/12/21 Michel Lespinasse <walken@google.com>:
>> > Signed-off-by: Michel Lespinasse <walken@google.com>
>>
>> Hello, this patch introduced the following bug, seen while fuzzing with trinity:
>>
>> [  396.825414] BUG: unable to handle kernel NULL pointer dereference
>> at 0000000000000050

Good catch...

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/fremap.c: fix oops on error path
>
> If find_vma() fails, sys_remap_file_pages() will dereference `vma', which
> contains NULL.  Fix it by checking the pointer.
>
> (We could alternatively check for err==0, but this seems more direct)
>
> (The vm_flags change is to squish a bogus used-uninitialised warning
> without adding extra code).
>
> Reported-by: Tommi Rantala <tt.rantala@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/fremap.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff -puN mm/fremap.c~mm-fremapc-fix-oops-on-error-path mm/fremap.c
> --- a/mm/fremap.c~mm-fremapc-fix-oops-on-error-path
> +++ a/mm/fremap.c
> @@ -163,7 +163,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
>          * and that the remapped range is valid and fully within
>          * the single existing vma.
>          */
> -       if (!vma || !(vma->vm_flags & VM_SHARED))
> +       vm_flags = vma->vm_flags;
> +       if (!vma || !(vm_flags & VM_SHARED))
>                 goto out;

Your commit message indicates the vm_flags load here doesn't generate any code, but this seems very brittle and compiler dependent. If the compiler was to generate an actual load here, the issue with vma == NULL would reappear.

>         if (!vma->vm_ops || !vma->vm_ops->remap_pages)
> @@ -254,7 +255,8 @@ get_write_lock:
>          */
>
>  out:
> -       vm_flags = vma->vm_flags;
> +       if (vma)
> +               vm_flags = vma->vm_flags;
>         if (likely(!has_write_lock))
>                 up_read(&mm->mmap_sem);
>         else



Would the following work ? I think it's simpler, and with the compiler
I'm using here it doesn't emit warnings:

diff --git a/mm/fremap.c b/mm/fremap.c
index 0cd4c11488ed..329507e832fb 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -254,7 +254,8 @@ get_write_lock:
 	 */
 
 out:
-	vm_flags = vma->vm_flags;
+	if (!err)
+		vm_flags = vma->vm_flags;
 	if (likely(!has_write_lock))
 		up_read(&mm->mmap_sem);
 	else

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
