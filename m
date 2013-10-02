Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B26ED6B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 12:31:56 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so1254064pad.35
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 09:31:56 -0700 (PDT)
Received: by mail-ye0-f174.google.com with SMTP id q4so255538yen.19
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 09:31:53 -0700 (PDT)
Message-ID: <524C4AA1.7000409@gmail.com>
Date: Wed, 02 Oct 2013 12:32:33 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 18/26] mm: Convert process_vm_rw_pages() to use get_user_pages_unlocked()
References: <1380724087-13927-1-git-send-email-jack@suse.cz> <1380724087-13927-19-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-19-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(10/2/13 10:27 AM), Jan Kara wrote:
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>   mm/process_vm_access.c | 8 ++------
>   1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
> index fd26d0433509..c1bc47d8ed90 100644
> --- a/mm/process_vm_access.c
> +++ b/mm/process_vm_access.c
> @@ -64,12 +64,8 @@ static int process_vm_rw_pages(struct task_struct *task,
>   	*bytes_copied = 0;
>   
>   	/* Get the pages we're interested in */
> -	down_read(&mm->mmap_sem);
> -	pages_pinned = get_user_pages(task, mm, pa,
> -				      nr_pages_to_copy,
> -				      vm_write, 0, process_pages, NULL);
> -	up_read(&mm->mmap_sem);
> -
> +	pages_pinned = get_user_pages_unlocked(task, mm, pa, nr_pages_to_copy,
> +					       vm_write, 0, process_pages);
>   	if (pages_pinned != nr_pages_to_copy) {
>   		rc = -EFAULT;
>   		goto end;

This is wrong because original code is wrong. In this function, page may be pointed to 
anon pages. Then, you should keep to take mmap_sem until finish to copying. Otherwise
concurrent fork() makes nasty COW issue.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
