Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 954306B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 15:02:51 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 8 Nov 2011 19:57:56 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pA8JwFMN2154706
	for <linux-mm@kvack.org>; Wed, 9 Nov 2011 06:58:23 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pA8K1CBm007532
	for <linux-mm@kvack.org>; Wed, 9 Nov 2011 07:01:13 +1100
Message-ID: <4EB98A83.3040101@linux.vnet.ibm.com>
Date: Wed, 09 Nov 2011 01:31:07 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
References: <4EB8E969.6010502@suse.cz> <1320766151-2619-1-git-send-email-aarcange@redhat.com> <1320766151-2619-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1320766151-2619-2-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 11/08/2011 08:59 PM, Andrea Arcangeli wrote:
> Lack of set_freezable_with_signal() prevented khugepaged to be waken
> up (and prevented to sleep again) across the
> schedule_timeout_interruptible() calls after freezing() becomes
> true. The tight loop in khugepaged_alloc_hugepage() also missed one
> try_to_freeze() call in case alloc_hugepage() would repeatedly fail in
> turn preventing the loop to break and to reach the try_to_freeze() in
> the khugepaged main loop.
> 
> khugepaged would still freeze just fine by trying again the next
> minute but it's better if it freezes immediately.
> 
> Reported-by: Jiri Slaby <jslaby@suse.cz>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/huge_memory.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4298aba..67311d1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2277,6 +2277,7 @@ static struct page *khugepaged_alloc_hugepage(void)
>  		if (!hpage) {
>  			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>  			khugepaged_alloc_sleep();
> +			try_to_freeze();
>  		} else
>  			count_vm_event(THP_COLLAPSE_ALLOC);
>  	} while (unlikely(!hpage) &&
> @@ -2331,7 +2332,7 @@ static int khugepaged(void *none)
>  {
>  	struct mm_slot *mm_slot;
> 
> -	set_freezable();
> +	set_freezable_with_signal();
>  	set_user_nice(current, 19);
> 
>  	/* serialize with start_khugepaged() */
> 

Why do we need to use both set_freezable_with_signal() and an additional
try_to_freeze()? Won't just using either one of them be good enough?
Or am I missing something here?

Thanks,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
