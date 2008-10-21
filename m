Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L7Glnp008692
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 16:16:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D959240049
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 16:16:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DF722DC133
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 16:16:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E2071DB803E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 16:16:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 061311DB8037
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 16:16:47 +0900 (JST)
Date: Tue, 21 Oct 2008 16:16:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48FD7EEF.3070803@cn.fujitsu.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD6901.6050301@linux.vnet.ibm.com>
	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD74AB.9010307@cn.fujitsu.com>
	<20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD7EEF.3070803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 15:04:15 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> You mean this ?
> 
> 000881c8 <page_cgroup_zoneinfo>:
>    881c8:       55                      push   %ebp
>    881c9:       8b 50 04                mov    0x4(%eax),%edx
>    881cc:       8b 40 08                mov    0x8(%eax),%eax
>    881cf:       89 e5                   mov    %esp,%ebp
>    881d1:       5d                      pop    %ebp
>    881d2:       8b 00                   mov    (%eax),%eax
>    881d4:       c1 e8 1e                shr    $0x1e,%eax
>    881d7:       6b c0 58                imul   $0x58,%eax,%eax
>    881da:       03 42 48                add    0x48(%edx),%eax
>    881dd:       c3                      ret
> 
Yes. thank you. This is helpful. From this, page_cgroup->page pointer is NULL.
And page_zid() or some kicks it..

Then, it seems problem is in page_cgroup.c::page_cgroup_init() or
page_cgroup()->page is cleared..Hmm..

could you show /var/log/dmesg ?
It may includes following kinds of line

= (this is x86-64)
sizeof(struct page) = 96
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00a40000
Movable zone start PFN for each node
early_node_map[4] active PFN ranges
    0: 0x00000000 -> 0x0000009e
    0: 0x00000100 -> 0x000bfee0
    0: 0x000bff00 -> 0x000bff80
    0: 0x00100000 -> 0x00a40000
On node 0 totalpages: 10485502
  DMA zone: 96 pages used for memmap
  DMA zone: 102 pages reserved
  DMA zone: 3800 pages, LIFO batch:0
  DMA32 zone: 24480 pages used for memmap
  DMA32 zone: 757696 pages, LIFO batch:31
  Normal zone: 227328 pages used for memmap
  Normal zone: 9472000 pages, LIFO batch:31
  Movable zone: 0 pages used for memmap
.....

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
