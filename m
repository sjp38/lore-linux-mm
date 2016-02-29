Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5EDC56B0259
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:38:55 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id d32so65296369qgd.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:38:55 -0800 (PST)
Date: Mon, 29 Feb 2016 18:38:45 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 07/18] mm, proc: make clear_refs killable
Message-ID: <20160229173845.GC3615@redhat.com>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-8-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456752417-9626-8-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

On 02/29, Michal Hocko wrote:
>
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1027,11 +1027,15 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		};
>
>  		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
> +			if (down_write_killable(&mm->mmap_sem)) {
> +				put_task_struct(task);
> +				return -EINTR;
> +			}
> +
>  			/*
>  			 * Writing 5 to /proc/pid/clear_refs resets the peak
>  			 * resident set size to this mm's current rss value.
>  			 */
> -			down_write(&mm->mmap_sem);
>  			reset_mm_hiwater_rss(mm);
>  			up_write(&mm->mmap_sem);
>  			goto out_mm;
> @@ -1043,7 +1047,10 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  				if (!(vma->vm_flags & VM_SOFTDIRTY))
>  					continue;
>  				up_read(&mm->mmap_sem);
> -				down_write(&mm->mmap_sem);
> +				if (down_write_killable(&mm->mmap_sem)) {
> +					put_task_struct(task);
> +					return -EINTR;
> +				}

Both lack mmput() afaics. Don't you need "goto out_mm" rather then "return" ? In
this case you do not need put_task_struct().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
