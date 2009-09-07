Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6D70D6B0089
	for <linux-mm@kvack.org>; Sun,  6 Sep 2009 20:51:08 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n870pCwa019014
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 7 Sep 2009 09:51:12 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2328D45DE80
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 09:51:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B7BA45DE7B
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 09:51:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC3B31DB8041
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 09:51:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 79974E18005
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 09:51:10 +0900 (JST)
Date: Mon, 7 Sep 2009 09:49:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][BUGFIX][PATCH] memcg: fix softlimit css refcnt
 handling(yet another one)
Message-Id: <20090907094912.5cbbbaa5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090907080403.5e4510b3.d-nishimura@mtf.biglobe.ne.jp>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090903141727.ccde7e91.nishimura@mxp.nes.nec.co.jp>
	<20090904131835.ac2b8cc8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904141157.4640ec1e.nishimura@mxp.nes.nec.co.jp>
	<20090904142143.15ffcb53.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904142654.08dd159f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904154050.25873aa5.nishimura@mxp.nes.nec.co.jp>
	<20090904163758.a5604fee.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904190726.6442f3df.d-nishimura@mtf.biglobe.ne.jp>
	<20090907080403.5e4510b3.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Sep 2009 08:04:03 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> On Fri, 4 Sep 2009 19:07:26 +0900
> Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:
> 
> > On Fri, 4 Sep 2009 16:37:58 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Fri, 4 Sep 2009 15:40:50 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > Ah, one more question. What memory.usage_in_bytes shows in that case ?
> > > > > If not zero, charge/uncharge coalescing is guilty.
> > > > > 
> > > > usage_in_bytes is 0.
> > > > I've confirmed by crash command that the mem_cgroup has extra ref counts.
> > > > 
> > > > I'll dig more..
> > > > 
> > > BTW, do you use softlimit ? I found this but...Hmm
> > > 
> > No.
> > I'm sorry I can't access my machine, so can't test this.
> > 
> > 
> > But I think this patch itself is needed and looks good.
> > 
> I've found the cause of the issue.
> 
> Andrew, could you add this one after KAMEZAWA-san's
> memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling.patch ?
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> refcount of the "victim" should be decremented before exiting the loop.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Nice!

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memcontrol.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ac51294..011aba6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1133,8 +1133,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  				 * anything, it might because there are
>  				 * no reclaimable pages under this hierarchy
>  				 */
> -				if (!check_soft || !total)
> +				if (!check_soft || !total) {
> +					css_put(&victim->css);
>  					break;
> +				}
>  				/*
>  				 * We want to do more targetted reclaim.
>  				 * excess >> 2 is not to excessive so as to
> @@ -1142,8 +1144,10 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  				 * coming back to reclaim from this cgroup
>  				 */
>  				if (total >= (excess >> 2) ||
> -					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> +					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
> +					css_put(&victim->css);
>  					break;
> +				}
>  			}
>  		}
>  		if (!mem_cgroup_local_usage(&victim->stat)) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
