Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AB1646B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 20:08:12 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3U08Ihw000386
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Apr 2009 09:08:18 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C3B645DE5D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:08:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A724645DE57
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:08:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 83A18E38002
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:08:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 29492E18001
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:08:17 +0900 (JST)
Date: Thu, 30 Apr 2009 09:06:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: fix mem_cgroup_update_mapped_file_stat
 oops
Message-Id: <20090430090646.a1443096.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0904292209550.30874@blonde.anvils>
References: <Pine.LNX.4.64.0904292209550.30874@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Apr 2009 22:13:33 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> CONFIG_SPARSEMEM=y CONFIG_CGROUP_MEM_RES_CTLR=y cgroup_disable=memory
> bootup is oopsing in mem_cgroup_update_mapped_file_stat().  !SPARSEMEM
> is fine because its lookup_page_cgroup() contains an explicit check for
> NULL node_page_cgroup, but the SPARSEMEM version was missing a check for
> NULL section->page_cgroup.
> 
Ouch, it's curious this bug alive now.. thank you.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I think this patch itself is sane but.. Balbir, could you see "caller" ?
It seems strange.

> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> Should go in as a fix to
> memcg-add-file-based-rss-accounting.patch
> but it's curious that's the first thing to suffer from this divergence.
> 
> Perhaps this is the wrong fix, and there should be an explicit
> mem_cgroup_disable() check somewhere else; but it would then seem
> dangerous that SPARSEMEM and !SPARSEMEM diverge in this way,
> and there are lots of lookup_page_cgroup NULL tests around.
> 
>  mm/page_cgroup.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- 2.6.30-rc3-mm1/mm/page_cgroup.c	2009-04-29 21:01:06.000000000 +0100
> +++ mmotm/mm/page_cgroup.c	2009-04-29 21:12:04.000000000 +0100
> @@ -99,6 +99,8 @@ struct page_cgroup *lookup_page_cgroup(s
>  	unsigned long pfn = page_to_pfn(page);
>  	struct mem_section *section = __pfn_to_section(pfn);
>  
> +	if (!section->page_cgroup)
> +		return NULL;
>  	return section->page_cgroup + pfn;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
