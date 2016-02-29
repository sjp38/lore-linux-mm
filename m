Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 811886B0256
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:23:43 -0500 (EST)
Received: by mail-qk0-f180.google.com with SMTP id o6so59107668qkc.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:23:43 -0800 (PST)
Date: Mon, 29 Feb 2016 18:23:34 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 13/18] exec: make exec path waiting for mmap_sem killable
Message-ID: <20160229172333.GB3615@redhat.com>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-14-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456752417-9626-14-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On 02/29, Michal Hocko wrote:
>
> @@ -267,7 +267,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
>  	if (!vma)
>  		return -ENOMEM;
>  
> -	down_write(&mm->mmap_sem);
> +	if (down_write_killable(&mm->mmap_sem)) {
> +		err = -EINTR;
> +		goto err_free;
> +	}
>  	vma->vm_mm = mm;

I won't argue, but this looks unnecessary. Nobody else can see this new mm,
down_write() can't block.

In fact I think we can just remove down_write/up_write here. Except perhaps
there is lockdep_assert_held() somewhere in these paths.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
