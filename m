Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C8BB3828E1
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:54:26 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id y9so122946037qgd.3
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:54:26 -0800 (PST)
Date: Mon, 29 Feb 2016 18:54:18 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 08/18] mm, fork: make dup_mmap wait for mmap_sem for
 write killable
Message-ID: <20160229175418.GD3615@redhat.com>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-9-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456752417-9626-9-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

On 02/29, Michal Hocko wrote:
>
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -413,7 +413,10 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>  	unsigned long charge;
>  
>  	uprobe_start_dup_mmap();
> -	down_write(&oldmm->mmap_sem);
> +	if (down_write_killable(&oldmm->mmap_sem)) {
> +		uprobe_end_dup_mmap();
> +		return -EINTR;
> +	}

This is really cosmetic and subjective, I won't insist if you prefer it this way.

But perhaps it makes sense to add another "fail" label above uprobe_end_dup_mmap()
we already have... IMO it is always better to avoid duplicating when it comes to
"unlock".

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
