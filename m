Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1376B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 04:06:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EBCC93EE0C1
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:06:20 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D05BA45DEB5
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:06:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B47D645DEAD
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:06:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 950B21DB8047
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:06:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41A561DB803F
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 17:06:20 +0900 (JST)
Date: Fri, 7 Oct 2011 17:05:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 0/8] per-cgroup tcp buffer pressure settings
Message-Id: <20111007170522.624fab3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E8C067E.6040203@parallels.com>
References: <1317730680-24352-1-git-send-email-glommer@parallels.com>
	<20111005092954.718a0c29.kamezawa.hiroyu@jp.fujitsu.com>
	<4E8C067E.6040203@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org



Sorry for lazy answer.

On Wed, 5 Oct 2011 11:25:50 +0400
Glauber Costa <glommer@parallels.com> wrote:

> On 10/05/2011 04:29 AM, KAMEZAWA Hiroyuki wrote:
> > On Tue,  4 Oct 2011 16:17:52 +0400
> > Glauber Costa<glommer@parallels.com>  wrote:
> >

> > At this stage, my concern is view of interfaces and documenation, and future plans.
> 
> Okay. I will try to address them as well as I can.
> 
> > * memory.independent_kmem_limit
> >   If 1, kmem_limit_in_bytes/kmem_usage_in_bytes works.
> >   If 0, kmem_limit_in_bytes/kmem_usage_in_bytes doesn't work and all kmem
> >      usages are controlled under memory.limit_in_bytes.
> 
> Correct. For the questions below, I won't even look at the code not to 
> get misguided. Let's settle on the desired behavior, and everything that 
> deviates from it, is a bug.
> 
> > Question:
> >   - What happens when parent/chidlren cgroup has different indepedent_kmem_limit ?
> I think it should be forbidden. It was raised by Kirill before, and 
> IIRC, he specifically requested it to be. (Okay: Saying it now, makes me 
> realizes that the child can have set it to 1 while parent was 1. But 
> then parent sets it to 0... I don't think I am handling this case).
> 

ok, please put it into TODO list ;)



> >   In future plan, kmem.usage_in_bytes should includes tcp.kmem_usage_in_bytes.
> >   And kmem.limit_in_bytes should be the limiation of sum of all kmem.xxxx.limit_in_bytes.
> 
> I am not sure there will be others xxx.limit_in_bytes. (see below)
> 

ok.


> >
> > Question:
> >   - Why this integration is difficult ?
> It is not that it is difficult.
> What happens is that there are two things taking place here:
> One of them is allocation.
> The other, is tcp-specific pressure thresholds. Bear with me with the 
> following example code: (from sk_stream_alloc_skb, net/ipv4/tcp.c)
> 
> 1:      skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
>          if (skb) {
> 3:              if (sk_wmem_schedule(sk, skb->truesize)) {
>                          /*
>                           * Make sure that we have exactly size bytes
>                           * available to the caller, no more, no less.
>                           */
>                          skb_reserve(skb, skb_tailroom(skb) - size);
>                          return skb;
>                  }
>                  __kfree_skb(skb);
>          } else {
>                  sk->sk_prot->enter_memory_pressure(sk);
>                  sk_stream_moderate_sndbuf(sk);
>          }
> 
> In line 1, an allocation takes place. This allocs memory from the skbuff 
> slab cache.
> But then, pressure thresholds are applied in 3. If it fails, we drop the 
> memory buffer even if the allocation succeeded.
> 

Sure.


> So this patchset, as I've stated already, cares about pressure 
> conditions only. It is enough to guarantee that no more memory will be 
> pinned that we specified, because we'll free the allocation in case 
> pressure is reached.
> 
> There is work in progress from guys at google (and I have my very own 
> PoCs as well), to include all slab allocations in kmem.usage_in_bytes.
> 

ok.


> So what I really mean here with "will integrate later", is that I think 
> that we'd be better off tracking the allocations themselves at the slab 
> level.
> 
> >     Can't tcp-limit-code borrows some amount of charges in batch from kmem_limit
> >     and use it ?
> Sorry, I don't know what exactly do you mean. Can you clarify?
> 
Now, tcp-usage is independent from kmem-usage.

My idea is
  
  1. when you account tcp usage, charge kmem, too.

  Now, your work is
     a) tcp use new xxxx bytes.
     b) account it to tcp.uage and check tcp limit
 
  To ingegrate kmem,
     a) tcp use new xxxx bytes.
     b) account it to tcp.usage and check tcp limit
     c) account it to kmem.usage

? 2 counters may be slow ?


> >   - Don't you need a stat file to indicate "tcp memory pressure works!" ?
> >     It can be obtained already ?
> 
> Not 100 % clear as well. We can query the amount of buffer used, and the 
> amount of buffer allowed. What else do we need?
> 

IIUC, we can see the fact tcp.usage is near to tcp.limit but never can see it
got memory pressure and how many numbers of failure happens.
I'm sorry if I don't read codes correctly. 

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
