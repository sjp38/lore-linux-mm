Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id D10A86B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 16:47:04 -0400 (EDT)
Date: Tue, 12 Mar 2013 13:47:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/9] mm: use mm_populate() for blocking
 remap_file_pages()
Message-Id: <20130312134702.a972d9a141bf86f14768ad41@linux-foundation.org>
In-Reply-To: <20130312002429.GA24360@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
	<1356050997-2688-5-git-send-email-walken@google.com>
	<CA+ydwtqD67m9_JLCNwvdP72rko93aTkVgC-aK4TacyyM5DoCTA@mail.gmail.com>
	<20130311160322.830cc6b670fd24faa8366413@linux-foundation.org>
	<20130312002429.GA24360@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Tommi Rantala <tt.rantala@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Mon, 11 Mar 2013 17:24:29 -0700 Michel Lespinasse <walken@google.com> wrote:
> > --- a/mm/fremap.c~mm-fremapc-fix-oops-on-error-path
> > +++ a/mm/fremap.c
> > @@ -163,7 +163,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
> >          * and that the remapped range is valid and fully within
> >          * the single existing vma.
> >          */
> > -       if (!vma || !(vma->vm_flags & VM_SHARED))
> > +       vm_flags = vma->vm_flags;
> > +       if (!vma || !(vm_flags & VM_SHARED))
> >                 goto out;
> 
> Your commit message indicates the vm_flags load here doesn't generate any code, but this seems very brittle and compiler dependent. If the compiler was to generate an actual load here, the issue with vma == NULL would reappear.

I didn't try very hard.  I have a surprisingly strong dislike of adding
"= 0" everywhere just to squish warnings.

There are actually quite a lot of places where this function could use
s/vma->vm_flags/vm_flags/ and might save a bit of code as a result. 
But the function's pretty straggly and I stopped doing it.

> 
> >         if (!vma->vm_ops || !vma->vm_ops->remap_pages)
> > @@ -254,7 +255,8 @@ get_write_lock:
> >          */
> >
> >  out:
> > -       vm_flags = vma->vm_flags;
> > +       if (vma)
> > +               vm_flags = vma->vm_flags;
> >         if (likely(!has_write_lock))
> >                 up_read(&mm->mmap_sem);
> >         else
> 
> 
> 
> Would the following work ? I think it's simpler, and with the compiler
> I'm using here it doesn't emit warnings:
> 
> diff --git a/mm/fremap.c b/mm/fremap.c
> index 0cd4c11488ed..329507e832fb 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -254,7 +254,8 @@ get_write_lock:
>  	 */
>  
>  out:
> -	vm_flags = vma->vm_flags;
> +	if (!err)
> +		vm_flags = vma->vm_flags;
>  	if (likely(!has_write_lock))
>  		up_read(&mm->mmap_sem);
>  	else

Yes, this will work.

gcc-4.4.4 does generate the warning with this.

Testing `err' was my v1, but it is not obvious that err==0 always
correlates with vma!= NULL.  This is true (I checked), and it had
better be true in the future, but it just feels safer and simpler to
test `vma' directly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
