Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 07E7F6B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 23:12:09 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o244C7o1026434
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Mar 2010 13:12:07 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B5A5745DE54
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:12:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6547C45DE52
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:12:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F7B9E18009
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:12:06 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B7EB9E18001
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:12:05 +0900 (JST)
Date: Thu, 4 Mar 2010 13:08:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom kill behavior v3
Message-Id: <20100304130834.f2843b79.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100304130406.95789929.nishimura@mxp.nes.nec.co.jp>
References: <20100302115834.c0045175.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302135524.afe2f7ab.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302143738.5cd42026.nishimura@mxp.nes.nec.co.jp>
	<20100302145644.0f8fbcca.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302151544.59c23678.nishimura@mxp.nes.nec.co.jp>
	<20100303092606.2e2152fc.nishimura@mxp.nes.nec.co.jp>
	<20100303093844.cf768ea4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303162304.eaf49099.kamezawa.hiroyu@jp.fujitsu.com>
	<20100304130406.95789929.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Mar 2010 13:04:06 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 3 Mar 2010 16:23:04 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 3 Mar 2010 09:38:44 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Wed, 3 Mar 2010 09:26:06 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > > I'll test this patch all through this night, and check whether it doesn't trigger
> > > > > global oom after memcg's oom.
> > > > > 
> > > > O.K. It works well.
> > > > Feel free to add my signs.
> > > > 
> > > > 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > > 	Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > > 
> > > 
> > > Thank you !
> > > 
> > > I'll apply Balbir's comment and post v3.
> > > 
> > 
> > rebased onto mmotm-Mar2.
> > tested on x86-64.
> > 
> I found a small race problem. This is the fix for it.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> We must avoid making oom_lock of a newly created child be negative.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3ce8c5b..9e25400 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1272,7 +1272,12 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
>  
>  static int mem_cgroup_oom_unlock_cb(struct mem_cgroup *mem, void *data)
>  {
> -	atomic_dec(&mem->oom_lock);
> +	/*
> +	 * There is a small race window where a new child can be created after
> +	 * we called mem_cgroup_oom_lock(). Use atomic_add_unless() to avoid
> +	 * making oom_lock of such a child be negative.
> +	 */
> +	atomic_add_unless(&mem->oom_lock, -1, 0);
>  	return 0;
>  }
>  


Thank you!. I'll merge this to v4.

-Kame


> -- 
> 1.6.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
