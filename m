Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 35B2E6B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 19:09:27 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBF09O3O018733
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Dec 2010 09:09:25 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A26F545DE5D
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:09:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 77B7545DE58
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:09:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C067E18005
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:09:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BFD7E08002
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 09:09:24 +0900 (JST)
Date: Wed, 15 Dec 2010 09:03:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] set correct numa_zonelist_order string when configured
 on the kernel command line
Message-Id: <20101215090339.167a7eab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4D07467D.7080809@gmail.com>
References: <4D07467D.7080809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Volodymyr G. Lukiianyk" <volodymyrgl@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2010 12:27:09 +0200
"Volodymyr G. Lukiianyk" <volodymyrgl@gmail.com> wrote:

> When numa_zonelist_order parameter is set to "node" or "zone" on the command line
> it's still showing as "default" in sysctl. That's because early_param parsing
> function changes only user_zonelist_order variable. Fix this by copying
> user-provided string to numa_zonelist_order if it was successfully parsed.
> 
> Signed-off-by: Volodymyr G Lukiianyk <volodymyrgl@gmail.com>
> 

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ff7e158..ddb81af 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2585,9 +2585,16 @@ static int __parse_numa_zonelist_order(char *s)
> 
>  static __init int setup_numa_zonelist_order(char *s)
>  {
> -	if (s)
> -		return __parse_numa_zonelist_order(s);
> -	return 0;
> +	int ret;
> +
> +	if (!s)
> +		return 0;
> +
> +	ret = __parse_numa_zonelist_order(s);
> +	if (ret == 0)
> +		strlcpy(numa_zonelist_order, s, NUMA_ZONELIST_ORDER_LEN);
> +
> +	return ret;
>  }
>  early_param("numa_zonelist_order", setup_numa_zonelist_order);
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
