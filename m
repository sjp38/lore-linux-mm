Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 33E06900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 20:58:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BF2853EE0BC
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:58:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E15745DE64
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:58:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F1D545DE5B
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:58:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E0961DB804F
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:58:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 368341DB8054
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:58:51 +0900 (JST)
Date: Thu, 18 Aug 2011 09:51:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v9 05/13] memcg: add mem_cgroup_mark_inode_dirty()
Message-Id: <20110818095126.0648525b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1313597705-6093-6-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
	<1313597705-6093-6-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>

On Wed, 17 Aug 2011 09:14:57 -0700
Greg Thelen <gthelen@google.com> wrote:

> Create the mem_cgroup_mark_inode_dirty() routine, which is called when
> an inode is marked dirty.  In kernels without memcg, this is an inline
> no-op.
> 
> Add i_memcg field to struct address_space.  When an inode is marked
> dirty with mem_cgroup_mark_inode_dirty(), the css_id of current memcg is
> recorded in i_memcg.  Per-memcg writeback (introduced in a latter
> change) uses this field to isolate inodes associated with a particular
> memcg.
> 
> The type of i_memcg is an 'unsigned short' because it stores the css_id
> of the memcg.  Using a struct mem_cgroup pointer would be larger and
> also create a reference on the memcg which would hang memcg rmdir
> deletion.  Usage of a css_id is not a reference so cgroup deletion is
> not affected.  The memcg can be deleted without cleaning up the i_memcg
> field.  When a memcg is deleted its pages are recharged to the cgroup
> parent, and the related inode(s) are marked as shared thus
> disassociating the inodes from the deleted cgroup.
> 
> A mem_cgroup_mark_inode_dirty() tracepoint is also included to allow for
> easier understanding of memcg writeback operation.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> Changelog since v8:
> - Use I_MEMCG_SHARED when initializing i_memcg.
> 
> - Use 'memcg' rather than 'mem' for local variables.  This is consistent with
>   other memory controller code.
> 
> - The logic in mem_cgroup_update_page_stat() and mem_cgroup_move_account() which
>   marks inodes I_MEMCG_SHARED is now part of this patch.  This makes more sense
>   because this is that patch that introduces that shared-inode concept.
> 
yes, this makes the patch clearer.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
