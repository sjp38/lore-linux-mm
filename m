Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 817886B006A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 06:12:42 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBFBCaet012089
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 20:12:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 71BE145DE51
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 20:12:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 47EF945DE4E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 20:12:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E646E18009
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 20:12:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DA9211DB8038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 20:12:35 +0900 (JST)
Date: Tue, 15 Dec 2009 20:09:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC v2 4/4] memcg: implement memory thresholds
Message-Id: <20091215200927.68126d96.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab0912150246k476aa85m6c1b61045fb0b26e@mail.gmail.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	<747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	<9e6e8d687224c6cbc54281f7c3d07983f701f93d.1260571675.git.kirill@shutemov.name>
	<20091215105850.87203454.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab0912150246k476aa85m6c1b61045fb0b26e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009 12:46:32 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Dec 15, 2009 at 3:58 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Sat, 12 Dec 2009 00:59:19 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > If you use have to use spinlock here, this is a system-wide spinlock,
> > threshold as "100" is too small, I think.
> 
> What is reasonable value for THRESHOLDS_EVENTS_THRESH for you?
> 
> In most cases spinlock taken only for two checks. Is it significant time?
> 
I tend to think about "bad case" when I see spinlock. 

And...I'm not sure but, recently, there are many VM users.
spinlock can be a big pitfall in some enviroment if not para-virtualized.
(I'm sorry I misunderstand somehing and VM handle this well...)

> Unfortunately, I can't test it on a big box. I have only dual-core system.
> It's not enough to test scalability.
> 

please leave it as 100 for now. But there is a chance to do simple optimization
for reducing the number of checks.

example)
static void mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
{
	/* For handle memory allocation in rush, check jiffies */
	*/
	smp_rmb();
	if (memcg->last_checkpoint_jiffies == jiffies)
		return;   /* reset event to half value ..*/
	memcg->last_checkpoint_jiffies = jiffies;
	smp_wmb();
	.....

I think this kind of check is necessary for handle "Rushing" memory allocation
in scalable way. Above one is just an example, 1 tick may be too long.

Other simple plan is

	/* Allow only one thread to do scan the list at the same time. */
	if (atomic_inc_not_zero(&memcg->threahold_scan_count) {
		atomic_dec(&memcg->threshold_scan_count);
		return;
	}
	...
	atomic_dec(&memcg->threahold_scan_count)

Some easy logic (as above) for taking care of scalability and commenary for that
is enough at 1st stage. Then, if there seems to be a trouble/concern, someone
(me?) will do some work later.




Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
