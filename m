Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B35286B006C
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 17:47:10 -0400 (EDT)
Received: by pacwz10 with SMTP id wz10so56008323pac.2
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 14:47:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id jc8si4427306pbd.25.2015.03.27.14.47.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 14:47:09 -0700 (PDT)
Date: Fri, 27 Mar 2015 14:47:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: do not adjust zone water marks if khugepaged is
 not started
Message-Id: <20150327144708.0223cc2e55862655259d2720@linux-foundation.org>
In-Reply-To: <1427456378-214780-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1427456378-214780-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Fri, 27 Mar 2015 13:39:38 +0200 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> set_recommended_min_free_kbytes() adjusts zone water marks to be suitable
> for khugepaged. We avoid doing this if khugepaged is disabled, but don't
> catch the case when khugepaged is failed to start.
> 
> Let's address this by checking khugepaged_thread instead of
> khugepaged_enabled() in set_recommended_min_free_kbytes().
> It's NULL if the kernel thread is stopped or failed to start.
>

hm, why didn't khugepaged start up?  Is this a theoretical
by-code-inspection thing or has the problem been observed in real life?

> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -110,7 +110,8 @@ static int set_recommended_min_free_kbytes(void)
>  	int nr_zones = 0;
>  	unsigned long recommended_min;
>  
> -	if (!khugepaged_enabled())
> +	/* khugepaged thread has stopped to failed to start */
> +	if (!khugepaged_thread)
>  		return 0;
>  
>  	for_each_populated_zone(zone)

Fair enough, but take a look at start_khugepaged():

: static int start_khugepaged(void)
: {
: 	int err = 0;
: 	if (khugepaged_enabled()) {
: 		if (!khugepaged_thread)
: 			khugepaged_thread = kthread_run(khugepaged, NULL,
: 							"khugepaged");
: 		if (unlikely(IS_ERR(khugepaged_thread))) {
: 			pr_err("khugepaged: kthread_run(khugepaged) failed\n");
: 			err = PTR_ERR(khugepaged_thread);
: 			khugepaged_thread = NULL;

-->> stop here 

: 		}
: 
: 		if (!list_empty(&khugepaged_scan.mm_head))
: 			wake_up_interruptible(&khugepaged_wait);
: 
: 		set_recommended_min_free_kbytes();
: 	} else if (khugepaged_thread) {
: 		kthread_stop(khugepaged_thread);
: 		khugepaged_thread = NULL;
: 	}
: 
: 	return err;
: }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
