Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i9QNfXOP020570 for <linux-mm@kvack.org>; Wed, 27 Oct 2004 08:41:33 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i9QNfXfQ010010 for <linux-mm@kvack.org>; Wed, 27 Oct 2004 08:41:33 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D7CCA7D00
	for <linux-mm@kvack.org>; Wed, 27 Oct 2004 08:41:32 +0900 (JST)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id EB133A7CFE
	for <linux-mm@kvack.org>; Wed, 27 Oct 2004 08:41:31 +0900 (JST)
Received: from [10.124.100.187]
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124])
 by fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I6700HG2TT60D@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed, 27 Oct 2004 08:41:31 +0900 (JST)
Date: Wed, 27 Oct 2004 08:47:19 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: migration cache, updated
In-reply-to: <20041026120136.GC27014@logos.cnet>
Message-id: <417EE207.9010508@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <20041025213923.GD23133@logos.cnet>
 <417DA5B8.8000706@jp.fujitsu.com> <20041026120136.GC27014@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, Hirokazu Takahashi <taka@valinux.co.jp>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

> 
> This should do it?
> 
> --- swapfile.c.orig     2004-10-26 11:33:56.734551048 -0200
> +++ swapfile.c  2004-10-26 11:34:03.284555296 -0200
> @@ -1370,6 +1370,13 @@ asmlinkage long sys_swapon(const char __
>                 swap_list_unlock();
>                 goto out;
>         }
> +
> +       /* MAX_SWAPFILES-1 is reserved for migration pages */
> +       if (type > MAX_SWAPFILES-1) {
> +               swap_list_unlock();
> +               goto out;
> +       }
> +
>         if (type >= nr_swapfiles)
>                 nr_swapfiles = type+1;
>         INIT_LIST_HEAD(&p->extent_list);
> 

This looks easier to read than my suggestion :).
But..
=========
if (type >=  MIGRATION_TYPE) { /* MIGRATION_TYPE is set to maximum available swp_type. */
	goto out;
}
=========
Is maybe correct .

Thanks.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
