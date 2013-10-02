Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6153E6B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 12:27:37 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1256626pad.2
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 09:27:37 -0700 (PDT)
Received: by mail-ye0-f176.google.com with SMTP id m4so256542yen.35
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 09:27:34 -0700 (PDT)
Message-ID: <524C499B.9090707@gmail.com>
Date: Wed, 02 Oct 2013 12:28:11 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/26] mm: Provide get_user_pages_unlocked()
References: <1380724087-13927-1-git-send-email-jack@suse.cz> <1380724087-13927-17-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-17-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(10/2/13 10:27 AM), Jan Kara wrote:
> Provide a wrapper for get_user_pages() which takes care of acquiring and
> releasing mmap_sem. Using this function reduces amount of places in
> which we deal with mmap_sem.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>   include/linux/mm.h | 14 ++++++++++++++
>   1 file changed, 14 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8b6e55ee8855..70031ead06a5 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1031,6 +1031,20 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>   		    struct vm_area_struct **vmas);
>   int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   			struct page **pages);
> +static inline long
> +get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> +		 	unsigned long start, unsigned long nr_pages,
> +			int write, int force, struct page **pages)
> +{
> +	long ret;
> +
> +	down_read(&mm->mmap_sem);
> +	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
> +			     NULL);
> +	up_read(&mm->mmap_sem);
> +	return ret;
> +}

Hmmm. I like the idea, but I really dislike this name. I don't like xx_unlocked 
function takes a lock. It is a source of confusing, I believe. 







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
