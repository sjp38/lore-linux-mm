Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E133E6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 19:41:18 -0500 (EST)
Received: by wmww144 with SMTP id w144so1115570wmw.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 16:41:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n10si14841058wja.51.2015.11.19.16.41.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 16:41:17 -0800 (PST)
Date: Thu, 19 Nov 2015 16:41:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs: clear file set[ug]id when writing via mmap
Message-Id: <20151119164114.6b55662050922bfa45de3a94@linux-foundation.org>
In-Reply-To: <20151120001043.GA28204@www.outflux.net>
References: <20151120001043.GA28204@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Willy Tarreau <w@1wt.eu>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, linux-mm@kvack.org

On Thu, 19 Nov 2015 16:10:43 -0800 Kees Cook <keescook@chromium.org> wrote:

> Normally, when a user can modify a file that has setuid or setgid bits,
> those bits are cleared when they are not the file owner or a member of the
> group. This is enforced when using write() directly but not when writing
> to a shared mmap on the file. This could allow the file writer to gain
> privileges by changing the binary without losing the setuid/setgid bits.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Cc: stable@vger.kernel.org
> ---
>  mm/memory.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index deb679c31f2a..4c970a4e0057 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
>  
>  		if (!page_mkwrite)
>  			file_update_time(vma->vm_file);
> +		file_remove_privs(vma->vm_file);
>  	}
>  
>  	return VM_FAULT_WRITE;

file_remove_privs() is depressingly heavyweight.  You'd think there was
some more lightweight way of caching the fact that we've already done
this.

Dumb question: can we run file_remove_privs() once, when the file is
opened writably, rather than for each and every write into each page?


Also, the proposed patch drops the file_remove_privs() return value on
the floor and we just go ahead with the modification.  How come?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
