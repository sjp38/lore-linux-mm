Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 9C09B6B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 17:03:17 -0400 (EDT)
Date: Tue, 1 May 2012 14:03:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] memcg: Free spare array to avoid memory leak
Message-Id: <20120501140314.1d7312fb.akpm@linux-foundation.org>
In-Reply-To: <1334825690-9065-1-git-send-email-handai.szj@taobao.com>
References: <1334825690-9065-1-git-send-email-handai.szj@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Thu, 19 Apr 2012 16:54:50 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
> 
> When the last event is unregistered, there is no need to keep the spare
> array anymore. So free it to avoid memory leak.

How serious is this leak?  Is there any way in which it can be used to
consume unbounded amounts of memory?

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4412,6 +4412,12 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
>  swap_buffers:
>  	/* Swap primary and spare array */
>  	thresholds->spare = thresholds->primary;
> +	/* If all events are unregistered, free the spare array */
> +	if (!new) {
> +		kfree(thresholds->spare);
> +		thresholds->spare = NULL;
> +	}
> +
>  	rcu_assign_pointer(thresholds->primary, new);
>  

The resulting code is really quite convoluted.  Try to read through it
and follow the handling of ->primary and ->spare.  Head spins.

What is the protocol here?  If ->primary is NULL then ->spare must also
be NULL?


I'll apply the patch, although I don't (yet) have sufficient info to
know which kernels it should be applied to.  Perhaps someone could
revisit this code and see if it can be made more straightforward.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
