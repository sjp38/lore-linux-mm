Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9LBNqmX001968
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 20:23:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0E002AC029
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 20:23:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C51912C0AE
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 20:23:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B6DB1DB803E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 20:23:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EB4A01DB803B
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 20:23:51 +0900 (JST)
Date: Tue, 21 Oct 2008 20:23:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021202325.938678c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021111951.GB4476@elte.hu>
References: <20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD82E3.9050502@cn.fujitsu.com>
	<20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD943D.5090709@cn.fujitsu.com>
	<20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD9D30.2030500@cn.fujitsu.com>
	<20081021182551.0158a47b.kamezawa.hiroyu@jp.fujitsu.com>
	<48FDA6D4.3090809@cn.fujitsu.com>
	<20081021191417.02ab97cc.kamezawa.hiroyu@jp.fujitsu.com>
	<48FDB584.7080608@cn.fujitsu.com>
	<20081021111951.GB4476@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Li Zefan <lizf@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 13:19:51 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > > Oh! thanks...but it seems pc->page is NULL in the middle of ZONE_NORMAL..
> > > ==
> > >  Normal   0x00001000 -> 0x000373fe
> > > ==
> > > This is appearently in the range of page_cgroup initialization.
> > > (if pgdat->node_page_cgroup is initalized correctly...)
> > > 
> > > I think write to page_cgroup->page happens only at initialization.
> > > Hmm ? not initilization failure but curruption ?
> > > 
> > 
> > Yes, curruption. I didn't find informatation about initialization failure.
> > 
> > > What happens if replacing __alloc_bootmem() with vmalloc() in page_cgroup.c init ?
> > > 
> > 
> > So I did this change, and the box booted up without any problem.
> > 
> > diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> > index 5d86550..82a30b1 100644
> > --- a/mm/page_cgroup.c
> > +++ b/mm/page_cgroup.c
> > @@ -48,8 +48,7 @@ static int __init alloc_node_page_cgroup(int nid)
> >  
> >  	table_size = sizeof(struct page_cgroup) * nr_pages;
> >  
> > -	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
> > -			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> > +	base = vmalloc_node(table_size, nid);
> >  	if (!base)
> >  		return -ENOMEM;
> 
> i have this:
> 
>   CONFIG_FAILSLAB=y
>   CONFIG_FAIL_PAGE_ALLOC=y
>   # CONFIG_FAIL_MAKE_REQUEST is not set
>   CONFIG_FAIL_IO_TIMEOUT=y
> 
> so the bug was perhaps that the __alloc_bootmem_node_nopanic() failed 
> and this code continued silently? vmalloc_node() probably is more 
> agressive about allocating memory.
> 
Sorry. I think I cannot use alloc_bootmem() at this point because
it's too late in init-path. (we can use usual page allocator)
So, just replacing alloc_bootmem() with vmalloc_node() is a fix....

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
