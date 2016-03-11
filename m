Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8D06B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:58:47 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p65so20999073wmp.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:58:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c1si3115767wmh.112.2016.03.11.06.58.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 06:58:45 -0800 (PST)
Subject: Re: [PATCH] uprobes: wait for mmap_sem for write killable
References: <1456752417-9626-16-git-send-email-mhocko@kernel.org>
 <1456767743-18665-1-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E2DD23.5070703@suse.cz>
Date: Fri, 11 Mar 2016 15:58:43 +0100
MIME-Version: 1.0
In-Reply-To: <1456767743-18665-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 02/29/2016 06:42 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> xol_add_vma needs mmap_sem for write. If the waiting task gets killed by
> the oom killer it would block oom_reaper from asynchronous address space
> reclaim and reduce the chances of timely OOM resolving. Wait for the
> lock in the killable mode and return with EINTR if the task got killed
> while waiting.
>
> Do not warn in dup_xol_work if __create_xol_area failed due to fatal
> signal pending because this is usually considered a kernel issue.
>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   kernel/events/uprobes.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index 8eef5f55d3f0..fb4a6bcc88ce 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -1130,7 +1130,9 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
>   	struct vm_area_struct *vma;
>   	int ret;
>
> -	down_write(&mm->mmap_sem);
> +	if (down_write_killable(&mm->mmap_sem))
> +		return -EINTR;
> +
>   	if (mm->uprobes_state.xol_area) {
>   		ret = -EALREADY;
>   		goto fail;
> @@ -1468,7 +1470,8 @@ static void dup_xol_work(struct callback_head *work)
>   	if (current->flags & PF_EXITING)
>   		return;
>
> -	if (!__create_xol_area(current->utask->dup_xol_addr))
> +	if (!__create_xol_area(current->utask->dup_xol_addr) &&
> +			!fatal_signal_pending(current)
                                                       ^ missing ")"

Other than that,
Acked-by: Vlastimil Babka <vbabka@suse.cz>

>   		uprobe_warn(current, "dup xol area");
>   }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
