Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9LAEibC021341
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 19:14:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4473F2AC026
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 19:14:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B7B112C044
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 19:14:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05F011DB8037
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 19:14:44 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B9C2F1DB803B
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 19:14:43 +0900 (JST)
Date: Tue, 21 Oct 2008 19:14:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021191417.02ab97cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48FDA6D4.3090809@cn.fujitsu.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD6901.6050301@linux.vnet.ibm.com>
	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD74AB.9010307@cn.fujitsu.com>
	<20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD7EEF.3070803@cn.fujitsu.com>
	<20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD82E3.9050502@cn.fujitsu.com>
	<20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD943D.5090709@cn.fujitsu.com>
	<20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD9D30.2030500@cn.fujitsu.com>
	<20081021182551.0158a47b.kamezawa.hiroyu@jp.fujitsu.com>
	<48FDA6D4.3090809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 17:54:28 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Tue, 21 Oct 2008 17:13:20 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> >> KAMEZAWA Hiroyuki wrote:
> >>> On Tue, 21 Oct 2008 16:35:09 +0800
> >>> Li Zefan <lizf@cn.fujitsu.com> wrote:
> >>>
> >>>> KAMEZAWA Hiroyuki wrote:
> >>>>> On Tue, 21 Oct 2008 15:21:07 +0800
> >>>>> Li Zefan <lizf@cn.fujitsu.com> wrote:
> >>>>>> dmesg is attached.
> >>>>>>
> >>>>> Thanks....I think I caught some. (added Mel Gorman to CC:)
> >>>>>
> >>>>> NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
> >>>>>
> >>>>> So, If there is a hole between zone, node->spanned_pages doesn't mean
> >>>>> length of node's memmap....(then, some hole can be skipped.)
> >>>>>
> >>>>> OMG....Could you try this ? 
> >>>>>
> >>>> No luck, the same bug still exists. :(
> >>>>
> >>> This is a little fixed one..
> >>>
> >> I tried the patch, but it doesn't solve the problem..
> >>
> > Hmm.. Can you catch "pfn" of troublesome page_cgroup ?
> > By patch like this ?
> > 
> 
> I got what you want:
> 
> pc c1d589dc pc->page 00000000 page c105f67c pfn 1d5b
> ...
> pc c1d589f0 pc->page 00000000 page c105f6b0 pfn 1d5c
>
Oh! thanks...but it seems pc->page is NULL in the middle of ZONE_NORMAL..
==
 Normal   0x00001000 -> 0x000373fe
==
This is appearently in the range of page_cgroup initialization.
(if pgdat->node_page_cgroup is initalized correctly...)

I think write to page_cgroup->page happens only at initialization.
Hmm ? not initilization failure but curruption ?

What happens if replacing __alloc_bootmem() with vmalloc() in page_cgroup.c init ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
