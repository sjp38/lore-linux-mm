Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E0DD86B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 15:51:05 -0500 (EST)
Date: Wed, 6 Feb 2013 12:51:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: don't overwrite mm->def_flags in do_mlockall()
Message-Id: <20130206125103.61748ed0.akpm@linux-foundation.org>
In-Reply-To: <1360165774-55458-1-git-send-email-gerald.schaefer@de.ibm.com>
References: <1360165774-55458-1-git-send-email-gerald.schaefer@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michel Lespinasse <walken@google.com>

On Wed,  6 Feb 2013 16:49:34 +0100
Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:

> With commit 8e72033 "thp: make MADV_HUGEPAGE check for mm->def_flags"
> the VM_NOHUGEPAGE flag may be set on s390 in mm->def_flags for certain
> processes, to prevent future thp mappings. This would be overwritten
> by do_mlockall(), which sets it back to 0 with an optional VM_LOCKED
> flag set.
> 
> To fix this, instead of overwriting mm->def_flags in do_mlockall(),
> only the VM_LOCKED flag should be set or cleared.

What are the user-visible effects here?  Looking at the 274023da1e8
changelog, I'm guessing that it might be pretty nasty - kvm breakage?

> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -517,11 +517,11 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
>  static int do_mlockall(int flags)
>  {
>  	struct vm_area_struct * vma, * prev = NULL;
> -	unsigned int def_flags = 0;
>  
>  	if (flags & MCL_FUTURE)
> -		def_flags = VM_LOCKED;
> -	current->mm->def_flags = def_flags;
> +		current->mm->def_flags |= VM_LOCKED;
> +	else
> +		current->mm->def_flags &= ~VM_LOCKED;
>  	if (flags == MCL_FUTURE)
>  		goto out;

Michal sent an equivalent patch last month:
http://ozlabs.org/~akpm/mmotm/broken-out/mm-make-mlockall-preserve-flags-other-than-vm_locked-in-def_flags.patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
