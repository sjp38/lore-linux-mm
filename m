Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 873676B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 22:09:15 -0400 (EDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp [192.51.44.35])
	by fgwmail9.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8C0pc1C016533
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 12 Sep 2009 09:51:38 +0900
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8C0p3W3001192
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 12 Sep 2009 09:51:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3215745DE52
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 09:51:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E1AAB45DE4F
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 09:51:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C21D8E38006
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 09:51:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C826E38004
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 09:51:02 +0900 (JST)
Message-ID: <7c7a5bbcd7ad21ea1cee1b6df3a28494.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090911112259.GA20988@localhost>
References: <20090911112221.GA20629@localhost>
    <20090911112259.GA20988@localhost>
Date: Sat, 12 Sep 2009 09:51:01 +0900 (JST)
Subject: Re: [PATCH 2/2] memcg: add accessor to mem_cgroup.css
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> So that an outside user can free the reference count grabbed by
> try_get_mem_cgroup_from_page().
>
While no heavy caller for this, I(we) would like to hide mem_cgroup
under memcontrol.c
Personally, I like no #ifdef for this easy code ;)

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Hugh Dickins <hugh@veritas.com>
> CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/memcontrol.h |    7 +++++++
>  mm/memcontrol.c            |    8 ++++++++
>  2 files changed, 15 insertions(+)
>
> --- linux-mm.orig/include/linux/memcontrol.h	2009-09-11 18:16:55.000000000
> +0800
> +++ linux-mm/include/linux/memcontrol.h	2009-09-11 18:16:56.000000000
> +0800
> @@ -81,6 +81,8 @@ int mm_match_cgroup(const struct mm_stru
>  	return cgroup == mem;
>  }
>
> +extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup
> *mem);
> +
>  extern int
>  mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr);
>  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
> @@ -206,6 +208,11 @@ static inline int task_in_mem_cgroup(str
>  	return 1;
>  }
>
> +static inline struct cgroup_subsys_state *mem_cgroup_css(struct
> mem_cgroup *mem)
> +{
> +	return NULL;
> +}
> +
>  static inline int
>  mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
>  {
> --- linux-mm.orig/mm/memcontrol.c	2009-09-11 18:16:55.000000000 +0800
> +++ linux-mm/mm/memcontrol.c	2009-09-11 18:18:11.000000000 +0800
> @@ -282,6 +282,14 @@ mem_cgroup_zoneinfo(struct mem_cgroup *m
>  	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
>  }
>
> +#ifdef CONFIG_HWPOISON_INJECT /* for now, only user is hwpoison injector
> */
> +struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
> +{
> +	return &mem->css;
> +}
> +EXPORT_SYMBOL(mem_cgroup_css);
> +#endif
> +
>  static struct mem_cgroup_per_zone *
>  page_cgroup_zoneinfo(struct page_cgroup *pc)
>  {
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
