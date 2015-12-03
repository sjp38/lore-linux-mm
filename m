Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C29336B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 19:18:54 -0500 (EST)
Received: by wmec201 with SMTP id c201so3514733wme.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:18:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m139si46770865wma.54.2015.12.02.16.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 16:18:53 -0800 (PST)
Date: Wed, 2 Dec 2015 16:18:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] fs: clear file privilege bits when mmap writing
Message-Id: <20151202161851.95d8fe811705c038e3fe2d33@linux-foundation.org>
In-Reply-To: <20151203000342.GA30015@www.outflux.net>
References: <20151203000342.GA30015@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jan Kara <jack@suse.cz>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Dec 2015 16:03:42 -0800 Kees Cook <keescook@chromium.org> wrote:

> Normally, when a user can modify a file that has setuid or setgid bits,
> those bits are cleared when they are not the file owner or a member
> of the group. This is enforced when using write and truncate but not
> when writing to a shared mmap on the file. This could allow the file
> writer to gain privileges by changing a binary without losing the
> setuid/setgid/caps bits.
> 
> Changing the bits requires holding inode->i_mutex, so it cannot be done
> during the page fault (due to mmap_sem being held during the fault).
> Instead, clear the bits if PROT_WRITE is being used at mmap time.
> 
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1340,6 +1340,17 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  			if (locks_verify_locked(file))
>  				return -EAGAIN;
>  
> +			/*
> +			 * If we must remove privs, we do it here since
> +			 * doing it during page COW is expensive and
> +			 * cannot hold inode->i_mutex.
> +			 */
> +			if (prot & PROT_WRITE && !IS_NOSEC(inode)) {
> +				mutex_lock(&inode->i_mutex);
> +				file_remove_privs(file);
> +				mutex_unlock(&inode->i_mutex);
> +			}
> +

Still ignoring the file_remove_privs() return value.  If this is
deliberate then a description of the reasons should be included?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
