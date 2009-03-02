Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5472B6B00BF
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 00:34:10 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n225Y7m7006394
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Mar 2009 14:34:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5742945DD74
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 14:34:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DF4045DD70
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 14:34:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FF1BE08004
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 14:34:07 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B986C1DB803C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 14:34:06 +0900 (JST)
Date: Mon, 2 Mar 2009 14:32:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090302044043.GC11421@balbir.in.ibm.com>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
	<20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302044043.GC11421@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 2009 10:10:43 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 09:24:04]:
> 
> > On Sun, 01 Mar 2009 11:59:59 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>

> > 
> > At first, it's said "When cgroup people adds something, the kernel gets slow".
> > This is my start point of reviewing. Below is comments to this version of patch.
> > 
> >  1. I think it's bad to add more hooks to res_counter. It's enough slow to give up
> >     adding more fancy things..
> 
> res_counters was desgined to be extensible, why is adding anything to
> it going to make it slow, unless we turn on soft_limits?
> 
You inserted new "if" logic in the core loop.
(What I want to say here is not that this is definitely bad but that "isn't there
 any alternatives which is less overhead.)


> > 
> >  2. please avoid to add hooks to hot-path. In your patch, especially a hook to
> >     mem_cgroup_uncharge_common() is annoying me.
> 
> If soft limits are not enabled, the function does a small check and
> leaves. 
> 
&soft_fail_res is passed always even if memory.soft_limit==ULONG_MAX
res_counter_soft_limit_excess() adds one more function call and spinlock, and irq-off.

> > 
> >  3. please avoid to use global spinlock more. 
> >     no lock is best. mutex is better, maybe.
> > 
> 
> No lock to update a tree which is update concurrently?
> 
Using tree/sort itself is nonsense, I believe.


> >  4. RB-tree seems broken. Following is example. (please note you do all ops
> >     in lazy manner (once in HZ/4.)
> > 
> >    i). while running, the tree is constructed as following
> > 
> >              R           R=exceed=300M
> >             / \ 
> >            A   B      A=exceed=200M  B=exceed=400M
> >    ii) A process B exits, but and usage goes down.
> 
> That is why we have the hook in uncharge. Even if we update and the
> usage goes down, the tree is ordered by usage_in_excess which is
> updated only when the tree is updated. So what you show below does not
> occur. I think I should document the design better.
> 

time_check==true. So, update-tree at uncharge() only happens once in HZ/4
==
@@ -1422,6 +1520,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
+	mem_cgroup_check_and_update_tree(mem, true);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
 		css_put(&mem->css);
==
Then, not-sorted RB-tree can be there.

BTW,
   time_after(jiffies, 0)
is buggy (see definition). If you want make this true always,
   time_after(jiffies, jiffies +1)

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
