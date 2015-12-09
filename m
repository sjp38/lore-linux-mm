Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0B76B0258
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 07:49:22 -0500 (EST)
Received: by wmec201 with SMTP id c201so71933940wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 04:49:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c10si11119438wjb.83.2015.12.09.04.49.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 04:49:21 -0800 (PST)
Date: Wed, 9 Dec 2015 13:49:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4] fs: clear file privilege bits when mmap writing
Message-ID: <20151209124918.GG3137@quack.suse.cz>
References: <20151208232818.GA29887@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151208232818.GA29887@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 08-12-15 15:28:18, Kees Cook wrote:
> Normally, when a user can modify a file that has setuid or setgid bits,
> those bits are cleared when they are not the file owner or a member
> of the group. This is enforced when using write and truncate but not
> when writing to a shared mmap on the file. This could allow the file
> writer to gain privileges by changing a binary without losing the
> setuid/setgid/caps bits.
> 
> Changing the bits requires holding inode->i_mutex, so it cannot be done
> during the page fault (due to mmap_sem being held during the fault). We
> could do this during vm_mmap_pgoff, but that would need coverage in
> mprotect as well, but to check for MAP_SHARED, we'd need to hold mmap_sem
> again.
> 
> Instead, detect the need to clear the bits during the page fault, and
> actually remove the bits during final fput. Since the file was open for
> writing, it wouldn't have been possible to execute it yet.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> Here's another way? I wonder which of these will actually work. I
> wish we could reject writes if file_remove_privs() fails.

Yeah, the fact that we cannot do anything with file_remove_privs() failure
is rather unfortunate. So open for writing may be the best choice for
file_remove_privs() in the end? It's not perfect but it looks like the
least problematic solution.

Frankly writeable files that have SUID / SGID bits set are IMHO problems on
its own, with IMA attrs which are handled by file_remove_privs() as well
things may be somewhat different.

> diff --git a/fs/file_table.c b/fs/file_table.c
> index ad17e05ebf95..abb537ef4344 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -191,6 +191,14 @@ static void __fput(struct file *file)
>  
>  	might_sleep();
>  
> +	/*
> +	 * XXX: While avoiding mmap_sem, we've already been written to.
> +	 * We must ignore the return value, since we can't reject the
> +	 * write.
> +	 */
> +	if (unlikely(file->f_remove_privs))
> +		file_remove_privs(file);
> +

You're missing i_mutex locking again ;).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
