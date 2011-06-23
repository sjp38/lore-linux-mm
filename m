Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 178E8900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 21:35:08 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B69543EE0BC
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:35:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A6DD45DE72
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:35:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DC9345DE6F
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:35:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B3751DB8041
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:35:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5B811DB803F
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:35:03 +0900 (JST)
Message-ID: <4E02983F.4020408@jp.fujitsu.com>
Date: Thu, 23 Jun 2011 10:34:55 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm, hotplug: protect zonelist building with zonelists_mutex
References: <alpine.DEB.2.00.1106221810130.23120@chino.kir.corp.google.com> <alpine.DEB.2.00.1106221811500.23120@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1106221811500.23120@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2011/06/23 10:13), David Rientjes wrote:
> 959ecc48fc75 ("mm/memory_hotplug.c: fix building of node hotplug 
> zonelist") does not protect the build_all_zonelists() call with 
> zonelists_mutex as needed.  This can lead to races in constructing 
> zonelist ordering if a concurrent build is underway.  Protecting this with 
> lock_memory_hotplug() is insufficient since zonelists can be rebuild 
> though sysfs as well.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Indeed.

 Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> ---
>  mm/memory_hotplug.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -498,7 +498,9 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  	 * The node we allocated has no zone fallback lists. For avoiding
>  	 * to access not-initialized zonelist, build here.
>  	 */
> +	mutex_lock(&zonelists_mutex);
>  	build_all_zonelists(NULL);
> +	mutex_unlock(&zonelists_mutex);
>  
>  	return pgdat;
>  }
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
