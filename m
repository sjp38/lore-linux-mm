Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3766B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 02:55:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CC71B3EE0C0
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 15:55:39 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A819B45DEBB
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 15:55:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8959945DEA6
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 15:55:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78AE91DB8046
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 15:55:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EADA1DB803F
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 15:55:39 +0900 (JST)
Date: Thu, 1 Sep 2011 15:48:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFMC] per-container tcp buffer limitation
Message-Id: <20110901154810.cdda1d94.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E5EF14F.3040300@parallels.com>
References: <4E5EF14F.3040300@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: netdev@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, "Eric W. Biederman" <ebiederm@xmission.com>, David Miller <davem@davemloft.net>, Stephen Hemminger <shemminger@vyatta.com>, penberg@kernel.org

On Wed, 31 Aug 2011 23:43:27 -0300
Glauber Costa <glommer@parallels.com> wrote:

> Hello People,
> 
> [ For the ones in linux-mm that are receiving this for the first time,
>    this is a follow up of
>    http://thread.gmane.org/gmane.linux.kernel.containers/21295 ]
> 
> Here is a new, a bit more mature version of my previous RFC. Now I 
> Request For More Comments from you guys in this new version of the patch.
> 
> Highlights:
> 
> * Although I do intend to experiment with more scenarios (suggestions 
> welcome), there does not seem to be a (huge) performance hit with this 
> patch applied, at least in a basic latency benchmark. That indicates 
> that even if we can demonstrate a performance hit, it won't be too hard 
> to optimize it away (famous last words?)
> 
> Since the patch touches both rcv and snd sides, I benchmarked it with 
> netperf against localhost. Command line: netperf -t TCP_RR -H localhost.
> 
> Without the patch
> =================
> 
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
> 
> 16384  87380  1        1       10.00    26996.35
> 16384  87380
> 
> With the patch
> ===============
> 
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
> 
> 16384  87380  1        1       10.00    27291.86
> 16384  87380
> 
> 
> As you can see, rate is a bit higher, but still under an one percent 
> range, meaning it is basically unchanged. I will benchmark it with 
> various levels of cgroup nesting on my next submission so we can have a 
> better idea of the impact of it when enabled.
> 
seems nice.

> * As nicely pointed out by Kamezawa, I dropped the sockets cgroup, and 
> introduced a kmem cgroup. After careful consideration, I decided not to 
> reuse the memcg. Basically, my impression is that memcg is concerned 
> with user objects, with page granularity and its swap attributes. 
> Because kernel objects are entirely different, I prefer to group them here.
> 

I myself has no objection to this direction. Other guys ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
