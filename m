Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 4F5B66B00E7
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 22:41:54 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D4EF03EE0B6
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 12:41:52 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B35F945DE5D
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 12:41:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 99C3F45DE59
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 12:41:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 80C641DB804B
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 12:41:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 215F61DB8050
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 12:41:52 +0900 (JST)
Date: Fri, 9 Mar 2012 12:40:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: Free spare array to avoid memory leak
Message-Id: <20120309124021.810f5267.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1331036004-7550-1-git-send-email-handai.szj@taobao.com>
References: <1331036004-7550-1-git-send-email-handai.szj@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

On Tue,  6 Mar 2012 20:13:24 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
> 
> When the last event is unregistered, there is no need to keep the spare
> array anymore. So free it to avoid memory leak.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> 
> ---
>  mm/memcontrol.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 22d94f5..3c09a84 100644
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

Could you clear thresholds->primary ? I don't like a pointer points to freed memory.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
