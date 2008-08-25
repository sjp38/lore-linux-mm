Date: Mon, 25 Aug 2008 12:21:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/14] memcg: rewrite force_empty
Message-Id: <20080825122127.31959aac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822203114.bf6f08e4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203114.bf6f08e4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Aug 2008 20:31:14 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Current force_empty of memory resource controller just removes page_cgroup.
> This maans the page is not accounted at all and create an in-use page which
> has no page_cgroup.
> 
> This patch tries to move account to "root" cgroup. By this patch, force_empty
> doesn't leak an account but move account to "root" cgroup. Maybe someone can
> think of other enhancements as
> 
>  1. move account to its parent.
>  2. move account to default-trash-can-cgroup somewhere.
>  3. move account to a cgroup specified by an admin.
> 
> I think a routine this patch adds is an enough generic and can be the base
> patch for supporting above behavior (if someone wants.). But, for now, just
> moves account to root group.
> 
> While moving mem_cgroup, lock_page(page) is held. This helps us for avoiding
> race condition with accessing page_cgroup->mem_cgroup.
> While under lock_page(), page_cgroup->mem_cgroup points to right cgroup.
> 

I decided to divide this patch into 2 pieces.

1. mem_cgroup_move_account() patch
2. rewrite force_empty to use mem_cgroup_move_account() patch.

(1) will add more generic helps for mem_cgroup in future.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
