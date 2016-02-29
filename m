Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 567A56B0254
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:16:28 -0500 (EST)
Received: by mail-qk0-f169.google.com with SMTP id o6so59779140qkc.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:16:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u92si26916811qge.31.2016.02.29.10.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:16:27 -0800 (PST)
Date: Mon, 29 Feb 2016 19:16:24 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm, proc: make clear_refs killable
Message-ID: <20160229181623.GH3615@redhat.com>
References: <1456752417-9626-8-git-send-email-mhocko@kernel.org>
 <1456768587-24893-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456768587-24893-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Petr Cermak <petrcermak@chromium.org>

On 02/29, Michal Hocko wrote:
>
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1027,11 +1027,15 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		};
>
>  		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
> +			if (down_write_killable(&mm->mmap_sem)) {
> +				count = -EINTR;
> +				goto out_mm;
> +			}
> +

We do not even need to change count, userspace won't see it anyway. But I agree
it look more clean this way.

I believe the patch is fine.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
