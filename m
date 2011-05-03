Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2AE7D6B0011
	for <linux-mm@kvack.org>; Tue,  3 May 2011 15:50:46 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Eliminate task stack trace duplication.
References: <1304444135-14128-1-git-send-email-yinghan@google.com>
Date: Tue, 03 May 2011 12:50:35 -0700
In-Reply-To: <1304444135-14128-1-git-send-email-yinghan@google.com> (Ying
	Han's message of "Tue, 3 May 2011 10:35:34 -0700")
Message-ID: <m2iptref78.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

Ying Han <yinghan@google.com> writes:

> The problem with small dmesg ring buffer like 512k is that only limited number
> of task traces will be logged. Sometimes we lose important information only
> because of too many duplicated stack traces.
>
> This patch tries to reduce the duplication of task stack trace in the dump
> message by hashing the task stack. The hashtable is a 32k pre-allocated buffer
> during bootup.

Nice idea!  This makes it a lot more readable too.

Can we compress the register values too? (e.g. by not printing that many
0s and replacing ffff8 with <k> or so)

In fact I don't remember needing the register values for anything.
Maybe they could be just not printed by default?

>  #endif
>  	read_lock(&tasklist_lock);
> +
> +	spin_lock(&stack_hash_lock);

The long hold lock scares me a little bit for a unstable system. 
Could you only hold it while hashing/unhashing? 

Also when you can't get it fall back to something else.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
