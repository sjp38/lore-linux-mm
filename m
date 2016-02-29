Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 79E596B0257
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:11:09 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id y89so121982971qge.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:11:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i64si26804523qhc.61.2016.02.29.10.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:11:08 -0800 (PST)
Date: Mon, 29 Feb 2016 19:11:06 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] uprobes: wait for mmap_sem for write killable
Message-ID: <20160229181105.GG3615@redhat.com>
References: <1456752417-9626-16-git-send-email-mhocko@kernel.org>
 <1456767743-18665-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456767743-18665-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 02/29, Michal Hocko wrote:
>
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -1130,7 +1130,9 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
>  	struct vm_area_struct *vma;
>  	int ret;
>  
> -	down_write(&mm->mmap_sem);
> +	if (down_write_killable(&mm->mmap_sem))
> +		return -EINTR;
> +
>  	if (mm->uprobes_state.xol_area) {
>  		ret = -EALREADY;
>  		goto fail;
> @@ -1468,7 +1470,8 @@ static void dup_xol_work(struct callback_head *work)
>  	if (current->flags & PF_EXITING)
>  		return;
>  
> -	if (!__create_xol_area(current->utask->dup_xol_addr))
> +	if (!__create_xol_area(current->utask->dup_xol_addr) &&
> +			!fatal_signal_pending(current)
>  		uprobe_warn(current, "dup xol area");
>  }

Looks good, thanks.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
