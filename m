Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 16A046B0037
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 02:54:47 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so303872wib.10
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 23:54:47 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id o2si9022684wje.108.2014.07.17.23.54.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 23:54:46 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id x12so3100413wgg.16
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 23:54:46 -0700 (PDT)
Date: Fri, 18 Jul 2014 08:54:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, writeback: prevent race when calculating dirty limits
Message-ID: <20140718065444.GA21453@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1407161733200.23892@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407161733200.23892@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 16-07-14 17:36:49, David Rientjes wrote:
> Setting vm_dirty_bytes and dirty_background_bytes is not protected by any 
> serialization.
> 
> Therefore, it's possible for either variable to change value after the 
> test in global_dirty_limits() to determine whether available_memory needs 
> to be initialized or not.
> 
> Always ensure that available_memory is properly initialized.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: David Rientjes <rientjes@google.com>

Makes sense to me
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page-writeback.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -261,14 +261,11 @@ static unsigned long global_dirtyable_memory(void)
>   */
>  void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>  {
> +	const unsigned long available_memory = global_dirtyable_memory();
>  	unsigned long background;
>  	unsigned long dirty;
> -	unsigned long uninitialized_var(available_memory);
>  	struct task_struct *tsk;
>  
> -	if (!vm_dirty_bytes || !dirty_background_bytes)
> -		available_memory = global_dirtyable_memory();
> -
>  	if (vm_dirty_bytes)
>  		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
>  	else

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
