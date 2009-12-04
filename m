Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FDCE6B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 20:03:25 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB413MaJ009621
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Dec 2009 10:03:23 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A105645DE57
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 10:03:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7621645DE54
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 10:03:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 398E71DB803F
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 10:03:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B145CE18009
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 10:03:21 +0900 (JST)
Date: Fri, 4 Dec 2009 10:00:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][mmotm][PATCH] percpu mm struct counter cache
Message-Id: <20091204100029.b703eaa0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262360912031649o42c9af52r35369fa820ec14f9@mail.gmail.com>
References: <20091203102851.daeb940c.kamezawa.hiroyu@jp.fujitsu.com>
	<4B17D506.7030701@gmail.com>
	<20091204091821.340ddcd5.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360912031649o42c9af52r35369fa820ec14f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 09:49:17 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Dec 4, 2009 at 9:18 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Making read-side of this counter slower means making ps or top slower.
> > IMO, ps or top is too slow now and making them more slow is very bad.
> 
> Also, we don't want to make regression in no-split-ptl lock system.
> Now, tick update cost is zero in no-split-ptl-lock system.
yes.
> but task switching is a little increased since compare instruction.
Ah, 

+#ifdef USE_SPLIT_PTLOCKS
+extern void prepare_mm_switch(struct task_struct *prev,
+				 struct task_struct *next);
+#else
+static inline prepare_mm_switch(struct task_struct *prev,
+				struct task_struct *next)
+{
+}
+#endif

makes costs zero.

> As you know, task-switching is rather costly function.
yes.

> I mind additional overhead in so-split-ptl lock system.
yes. here. 
> I think we can remove the overhead completely.
> 

I have another version of this patch, which switches curr_mmc.mm
lazilu in a page fault. But it requires some complicated rules.
I'll try it again rather than adding hooks in context-switch.

BTW, I'm wondering to export "curr_mmc" to other files. Maybe
there will be some more information nice to be cached per cpu+mm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
