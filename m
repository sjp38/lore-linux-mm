Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 937426B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 07:10:49 -0500 (EST)
Date: Wed, 19 Jan 2011 13:10:43 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] memcg: fix USED bit handling at uncharge in THP
Message-ID: <20110119121043.GB2232@cmpxchg.org>
References: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
 <20110118114049.5ffdf5da.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110118114049.5ffdf5da.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello KAMEZAWA-san,

On Tue, Jan 18, 2011 at 11:40:49AM +0900, KAMEZAWA Hiroyuki wrote:
> +void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
> +{
> +	struct page_cgroup *head_pc = lookup_page_cgroup(head);
> +	struct page_cgroup *tail_pc = lookup_page_cgroup(tail);
> +	unsigned long flags;
> +
> +	/*
> +	 * We have no races witch charge/uncharge but will have races with
> +	 * page state accounting.
> +	 */
> +	move_lock_page_cgroup(head_pc, &flags);
> +
> +	tail_pc->mem_cgroup = head_pc->mem_cgroup;
> +	smp_wmb(); /* see __commit_charge() */

I thought the barriers were needed because charging does not hold the
lru lock.  But here we do, and all the 'lockless' read-sides do so as
well.  Am I missing something or can this barrier be removed?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
