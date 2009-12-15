Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AF4D86B0047
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:38:27 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF1cP2n002903
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 10:38:25 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 08B4D45DE7B
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:38:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB8EB45DE60
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:38:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A15BC1DB8048
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:38:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 026C11DB803F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:38:24 +0900 (JST)
Date: Tue, 15 Dec 2009 10:35:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC v2 3/4] memcg: rework usage of stats by soft limit
Message-Id: <20091215103517.75645536.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <cc557aab0912121146y276a8d26v8baee15be1f83a97@mail.gmail.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	<747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	<20091212125046.14df3134.d-nishimura@mtf.biglobe.ne.jp>
	<cc557aab0912120506x56b9a707ob556035fdcf40a22@mail.gmail.com>
	<20091212233409.60da66fb.d-nishimura@mtf.biglobe.ne.jp>
	<cc557aab0912121146y276a8d26v8baee15be1f83a97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: nishimura@mxp.nes.nec.co.jp, containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 12 Dec 2009 21:46:08 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Sat, Dec 12, 2009 at 4:34 PM, Daisuke Nishimura
> <d-nishimura@mtf.biglobe.ne.jp> wrote:
> > On Sat, 12 Dec 2009 15:06:52 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >
> >> On Sat, Dec 12, 2009 at 5:50 AM, Daisuke Nishimura
> >> <d-nishimura@mtf.biglobe.ne.jp> wrote:
> >> > And IIUC, it's the same for your threshold feature, right ?
> >> > I think it would be better:
> >> >
> >> > - discard this change.
> >> > - in 4/4, rename mem_cgroup_soft_limit_check to mem_cgroup_event_check,
> >> > A and instead of adding a new STAT counter, do like:
> >> >
> >> > A  A  A  A if (mem_cgroup_event_check(mem)) {
> >> > A  A  A  A  A  A  A  A mem_cgroup_update_tree(mem, page);
> >> > A  A  A  A  A  A  A  A mem_cgroup_threshold(mem);
> >> > A  A  A  A }
> >>
> >> I think that mem_cgroup_update_tree() and mem_cgroup_threshold() should be
> >> run with different frequency. How to share MEM_CGROUP_STAT_EVENTS
> >> between soft limits and thresholds in this case?
> >>
> > hmm, both softlimit and your threshold count events at the same place(charge and uncharge).
> > So, I think those events can be shared.
> > Is there any reason they should run in different frequency ?
> 
> SOFTLIMIT_EVENTS_THRESH is 1000. If use the same value for thresholds,
> a threshold can
> be exceed on 1000*nr_cpu_id pages. It's too many. I think, that 100 is
> a reasonable value.
> 

Hmm, then what amount of costs does this code add ?

Do you have benchmark result ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
