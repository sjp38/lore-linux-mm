Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id A81526B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:12:20 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id b67so120485195qgb.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:12:20 -0800 (PST)
Date: Mon, 29 Feb 2016 18:12:11 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 15/18] uprobes: wait for mmap_sem for write killable
Message-ID: <20160229171211.GA3615@redhat.com>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-16-git-send-email-mhocko@kernel.org>
 <20160229155712.GA1964@redhat.com>
 <20160229162840.GH16930@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229162840.GH16930@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

On 02/29, Michal Hocko wrote:
>
> Ahh, I see. I didn't understand what is the purpose of the warning. Does
> the following work for you?
> ---
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index a79315d0f711..fb4a6bcc88ce 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -1470,7 +1470,8 @@ static void dup_xol_work(struct callback_head *work)
>  	if (current->flags & PF_EXITING)
>  		return;
>
> -	if (!__create_xol_area(current->utask->dup_xol_addr))
> +	if (!__create_xol_area(current->utask->dup_xol_addr) &&
> +			!fatal_signal_pending(current)
>  		uprobe_warn(current, "dup xol area");
>  }

Yes, I think this is fine.

Probably deserves a cleanup, but we can do it later.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
