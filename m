Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CD3226B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 08:38:25 -0500 (EST)
Message-ID: <4B2B85C3.5040409@redhat.com>
Date: Fri, 18 Dec 2009 15:38:11 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091211164651.036f5340@annuminas.surriel.com>
In-Reply-To: <20091211164651.036f5340@annuminas.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/11/2009 11:46 PM, Rik van Riel wrote:
> Under very heavy multi-process workloads, like AIM7, the VM can
> get into trouble in a variety of ways.  The trouble start when
> there are hundreds, or even thousands of processes active in the
> page reclaim code.
>
> Not only can the system suffer enormous slowdowns because of
> lock contention (and conditional reschedules) between thousands
> of processes in the page reclaim code, but each process will try
> to free up to SWAP_CLUSTER_MAX pages, even when the system already
> has lots of memory free.
>
> It should be possible to avoid both of those issues at once, by
> simply limiting how many processes are active in the page reclaim
> code simultaneously.
>
> If too many processes are active doing page reclaim in one zone,
> simply go to sleep in shrink_zone().
>
> On wakeup, check whether enough memory has been freed already
> before jumping into the page reclaim code ourselves.  We want
> to use the same threshold here that is used in the page allocator
> for deciding whether or not to call the page reclaim code in the
> first place, otherwise some unlucky processes could end up freeing
> memory for the rest of the system.
>
>
>
>   Control how to kill processes when uncorrected memory error (typically
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 30fe668..ed614b8 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -345,6 +345,10 @@ struct zone {
>   	/* Zone statistics */
>   	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
>
> +	/* Number of processes running page reclaim code on this zone. */
> +	atomic_t		concurrent_reclaimers;
> +	wait_queue_head_t	reclaim_wait;
> +
>    

Counting semaphore?

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
