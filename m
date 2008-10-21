Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9LBEFuw030606
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 20:14:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB9CE2AC025
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 20:14:14 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C3F4512C046
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 20:14:14 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id A979E1DB803A
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 20:14:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C5FD1DB803F
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 20:14:11 +0900 (JST)
Date: Tue, 21 Oct 2008 20:13:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021201345.b5eed04b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48FDB584.7080608@cn.fujitsu.com>
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
	<20081021191417.02ab97cc.kamezawa.hiroyu@jp.fujitsu.com>
	<48FDB584.7080608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 18:57:08 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> So I did this change, and the box booted up without any problem.

Li-san, could use send this patch as a fix ?
It seems alloc_node_page_cgrop() is too late in init-path to call alloc_bootmem().

Thanks,
-kame

> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5d86550..82a30b1 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -48,8 +48,7 @@ static int __init alloc_node_page_cgroup(int nid)
>  
>  	table_size = sizeof(struct page_cgroup) * nr_pages;
>  
> -	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
> -			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> +	base = vmalloc_node(table_size, nid);
>  	if (!base)
>  		return -ENOMEM;
>  	for (index = 0; index < nr_pages; index++) {
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
