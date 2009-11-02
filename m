Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 778B96B006A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 03:41:49 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA28fkS5031072
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Nov 2009 17:41:46 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5822945DE51
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 17:41:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 345AE45DE4D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 17:41:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DA741DB803F
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 17:41:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C5AC41DB803A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 17:41:45 +0900 (JST)
Date: Mon, 2 Nov 2009 17:39:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm][PATCH 4/6] oom-killer: fork bomb detector
Message-Id: <20091102173912.601790b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091102162716.e7803741.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091102162716.e7803741.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009 16:27:16 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> -
> -	/* Try to kill a child first */
> +	if (fork_bomb) {
> +		printk(KERN_ERR "possible fork-bomb is detected. kill them\n");
> +		/* We need to kill the youngest one, at least */
> +		rcu_read_lock();
> +		for_each_process_reverse(c) {
> +			if (c == p)
> +				break;
> +			if (is_forkbomb_family(c, p)) {
> +				oom_kill_task(c);
> +				break;
> +			}
> +		}
> +		rcu_read_unlock();
> +	}

Kosaki said we should kill all under tree and "break" is unnecessay here.
I nearly agree with him..after some experiments.

But it seems the biggest problem is latecy by swap-out...before deciding OOM
....

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
