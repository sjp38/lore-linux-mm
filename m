Received: by wa-out-1112.google.com with SMTP id m33so26829wag.8
        for <linux-mm@kvack.org>; Tue, 15 Jan 2008 14:16:00 -0800 (PST)
Message-ID: <4df4ef0c0801151415w70549cb8n6563ca3604e34a68@mail.gmail.com>
Date: Wed, 16 Jan 2008 01:15:59 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH 0/2] Updating ctime and mtime for memory-mapped files [try #4]
In-Reply-To: <E1JEsNJ-00026T-7B@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12004129652397-git-send-email-salikhmetov@gmail.com>
	 <E1JEsNJ-00026T-7B@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com
List-ID: <linux-mm.kvack.org>

2008/1/15, Miklos Szeredi <miklos@szeredi.hu>:
> > 1. Introduction
> >
> > This is the fourth version of my solution for the bug #2645:
> >
> > http://bugzilla.kernel.org/show_bug.cgi?id=2645
> >
> > Changes since the previous version:
> >
> > 1) the case of retouching an already-dirty page pointed out
> >   by Miklos Szeredi has been addressed;
>
> I'm a bit sceptical, as we've also pointed out, that this is not
> possible without messing with the page tables.
>
> Did you try my test program on the patched kernel?

I just tried your test program. Alas, my assumption appears to be wrong.

Thank you for your comment!

Now I start thinking that it is better not to care about
the MS_ASYNC case whatsoever.

>
> I've refreshed the patch, where we left this issue last time.  It
> should basically have equivalent functionality to your patch, and is a
> lot simpler.  There might be performance issues with it, but it's a
> good starting point.
>
> Miklos
> ----
>
> Index: linux/mm/memory.c
> ===================================================================
> --- linux.orig/mm/memory.c      2008-01-09 21:16:30.000000000 +0100
> +++ linux/mm/memory.c   2008-01-15 21:16:14.000000000 +0100
> @@ -1680,6 +1680,8 @@ gotten:
>  unlock:
>         pte_unmap_unlock(page_table, ptl);
>         if (dirty_page) {
> +               if (vma->vm_file)
> +                       file_update_time(vma->vm_file);
>                 /*
>                  * Yes, Virginia, this is actually required to prevent a race
>                  * with clear_page_dirty_for_io() from clearing the page dirty
> @@ -2313,6 +2315,8 @@ out_unlocked:
>         if (anon)
>                 page_cache_release(vmf.page);
>         else if (dirty_page) {
> +               if (vma->vm_file)
> +                       file_update_time(vma->vm_file);
>                 set_page_dirty_balance(dirty_page, page_mkwrite);
>                 put_page(dirty_page);
>         }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
