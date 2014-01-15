Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A27486B0037
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:13:43 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id z10so402650pdj.3
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:13:43 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id s4si2079141pbg.33.2014.01.14.17.13.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 17:13:42 -0800 (PST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 95CC03EE1D9
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:13:40 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 843E545DE4E
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:13:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 42C8D45DE69
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:13:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 302591DB8042
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:13:40 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D4BB51DB803E
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:13:39 +0900 (JST)
Message-ID: <52D5E08E.4030309@jp.fujitsu.com>
Date: Wed, 15 Jan 2014 10:12:46 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] hotplug, memory: move register_memory_resource out of the
 lock_memory_hotplug
References: <1389723874-32372-1-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1389723874-32372-1-git-send-email-nzimmer@sgi.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Hedi <hedi@sgi.com>, Mike Travis <travis@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2014/01/15 3:24), Nathan Zimmer wrote:
> We don't need to do register_memory_resource() since it has its own lock and
> doesn't make any callbacks.
> 
> Also register_memory_resource return NULL on failure so we don't have anything
> to cleanup at this point.
> 
> 
> The reason for this rfc is I was doing some experiments with hotplugging of
> memory on some of our larger systems.  While it seems to work, it can be quite
> slow.  With some preliminary digging I found that lock_memory_hotplug is
> clearly ripe for breakup.
> 
> It could be broken up per nid or something but it also covers the
> online_page_callback.  The online_page_callback shouldn't be very hard to break
> out.
> 
> Also there is the issue of various structures(wmarks come to mind) that are
> only updated under the lock_memory_hotplug that would need to be dealt with.
> 
> 
> cc: Andrew Morton <akpm@linux-foundation.org>
> cc: Tang Chen <tangchen@cn.fujitsu.com>
> cc: Wen Congyang <wency@cn.fujitsu.com>
> cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
> cc: Hedi <hedi@sgi.com>
> cc: Mike Travis <travis@sgi.com>
> cc: linux-mm@kvack.org
> cc: linux-kernel@vger.kernel.org
> 
> 
> ---

The patch seems good to me.

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>   mm/memory_hotplug.c | 7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 1ad92b4..62a0cd1 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1097,17 +1097,18 @@ int __ref add_memory(int nid, u64 start, u64 size)
>   	struct resource *res;
>   	int ret;
>   
> -	lock_memory_hotplug();
> -
>   	res = register_memory_resource(start, size);
>   	ret = -EEXIST;
>   	if (!res)
> -		goto out;
> +		return ret;
>   
>   	{	/* Stupid hack to suppress address-never-null warning */
>   		void *p = NODE_DATA(nid);
>   		new_pgdat = !p;
>   	}
> +
> +	lock_memory_hotplug();
> +
>   	new_node = !node_online(nid);
>   	if (new_node) {
>   		pgdat = hotadd_new_pgdat(nid, start);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
