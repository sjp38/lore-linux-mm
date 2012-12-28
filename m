Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id DAE5B6B0062
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 20:04:42 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E0F343EE0AE
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:04:40 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C720745DE5B
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:04:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AED4F45DE59
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:04:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F715E38002
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:04:40 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 575AC1DB8046
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:04:40 +0900 (JST)
Message-ID: <50DCF00B.5040100@jp.fujitsu.com>
Date: Fri, 28 Dec 2012 10:04:11 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 6/8] memcg: Don't account root_mem_cgroup page statistics
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456447-14740-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356456447-14740-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

(2012/12/26 2:27), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> If memcg is enabled and no non-root memcg exists, all allocated pages
> belongs to root_mem_cgroup and go through root memcg statistics routines
> which brings some overheads. So for the sake of performance, we can give
> up accounting stats of root memcg for MEM_CGROUP_STAT_FILE_MAPPED/FILE_DIRTY
> /WRITEBACK and instead we pay special attention while showing root
> memcg numbers in memcg_stat_show(): as we don't account root memcg stats
> anymore, the root_mem_cgroup->stat numbers are actually 0. But because of
> hierachy, figures of root_mem_cgroup may just represent numbers of pages
> used by its own tasks(not belonging to any other child cgroup). So here we
> fake these root numbers by using stats of global state and all other memcg.
> That is for root memcg:
> 	nr(MEM_CGROUP_STAT_FILE_MAPPED) = global_page_state(NR_FILE_MAPPED) -
>                                sum_of_all_memcg(MEM_CGROUP_STAT_FILE_MAPPED);
> Dirty/Writeback pages accounting are in the similar way.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

isn't it better to use mem_cgroup_is_root() call rather than
direct comparison (memcg == root_mem_cgroup) ?

Anyway, Ack to this approach. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
