Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id D00D36B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 05:08:28 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so8476010wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 02:08:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x8si2094883wiy.50.2015.08.25.02.08.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 02:08:27 -0700 (PDT)
Subject: Re: [PATCH] mm/khugepaged: Allow to interrupt allocation sleep again
References: <1440429203-4039-1-git-send-email-pmladek@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC3088.7050701@suse.cz>
Date: Tue, 25 Aug 2015 11:08:24 +0200
MIME-Version: 1.0
In-Reply-To: <1440429203-4039-1-git-send-email-pmladek@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-pm@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>

On 08/24/2015 05:13 PM, Petr Mladek wrote:
> The commit 1dfb059b9438633b0546 ("thp: reduce khugepaged freezing
> latency") fixed khugepaged to do not block a system suspend. But
> the result is that it could not get interrupted before the given
> timeout because the condition for the wait event is "false".
>
> This patch puts back the original approach but it uses
> freezable_schedule_timeout_interruptible() instead of
> schedule_timeout_interruptible(). It does the right thing.
> I am pretty sure that the freezable variant was not used in
> the original fix only because it was not available at that time.
>
> The regression has been there for ages. It was not critical. It just
> did the allocation throttling a little bit more aggressively.
>
> I found this problem when converting the kthread to kthread worker API
> and trying to understand the code.
>
> Signed-off-by: Petr Mladek <pmladek@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/huge_memory.c | 8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7109330c5911..eb115aaa429c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2368,8 +2368,12 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
>
>   static void khugepaged_alloc_sleep(void)
>   {
> -	wait_event_freezable_timeout(khugepaged_wait, false,
> -			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
> +	DEFINE_WAIT(wait);
> +
> +	add_wait_queue(&khugepaged_wait, &wait);
> +	freezable_schedule_timeout_interruptible(
> +		msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
> +	remove_wait_queue(&khugepaged_wait, &wait);
>   }
>
>   static int khugepaged_node_load[MAX_NUMNODES];
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
