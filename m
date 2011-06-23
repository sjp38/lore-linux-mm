Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 116E9900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 21:31:24 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D64F83EE0BC
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:31:21 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF18745DE4D
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:31:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A73BF45DE52
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:31:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A5CB1DB8037
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:31:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 671EB1DB803E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:31:21 +0900 (JST)
Message-ID: <4E02975A.3000800@jp.fujitsu.com>
Date: Thu, 23 Jun 2011 10:31:06 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm, hotplug: fix error handling in mem_online_node()
References: <alpine.DEB.2.00.1106221810130.23120@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1106221810130.23120@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2011/06/23 10:13), David Rientjes wrote:
> The error handling in mem_online_node() is incorrect: hotadd_new_pgdat() 
> returns NULL if the new pgdat could not have been allocated and a pointer 
> to it otherwise.
> 
> mem_online_node() should fail if hotadd_new_pgdat() fails, not the 
> inverse.  This fixes an issue when memoryless nodes are not onlined and 
> their sysfs interface is not registered when their first cpu is brought 
> up.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Nice catch.

The fault was introduced by commit cf23422b9d76(cpu/mem hotplug: enable CPUs
online before local memory online) iow v2.6.35.

 Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> ---
>  mm/memory_hotplug.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -521,7 +521,7 @@ int mem_online_node(int nid)
>  
>  	lock_memory_hotplug();
>  	pgdat = hotadd_new_pgdat(nid, 0);
> -	if (pgdat) {
> +	if (!pgdat) {
>  		ret = -ENOMEM;
>  		goto out;
>  	}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
