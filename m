Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 477FA6B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 11:18:19 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] memcg: change behavior of moving charges at task move
Date: Thu, 22 Mar 2012 11:17:20 -0400
Message-Id: <1332429440-7167-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <4F69A4C4.4080602@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Mar 21, 2012 at 06:52:04PM +0900, KAMEZAWA Hiroyuki wrote:
> As discussed before, I post this to fix the spec and implementation of task moving.
> Then, do you think what target kernel version should be ? 3.4/3.5 ?
> but yes, it may be late for 3.4....
> 
> ==
> In documentation, it's said that 'shared anon are not moved'.
> But in implementation, the check was wrong.
> 
>   if (!move_anon() || page_mapcount(page) > 2)
> 
> Ah, memcg has been moving shared anon pages for a long time.
> 
> Then, here is a discussion about handling of shared anon pages.
> 
>  - It's complex
>  - Now, shared file caches are moved in force.
>  - It adds unclear check as page_mapcount(). To do correct check,
>    we should check swap users, etc.
>  - No one notice this implementation behavior. So, no one get benefit
>    from the design.
>  - In general, once task is moved to a cgroup for running, it will not
>    be moved....
>  - Finally, we have control knob as memory.move_charge_at_immigrate.
> 
> Here is a patch to allow moving shared pages, completely. This makes
> memcg simpler and fix current broken code.
> 
> Note:
>  IIUC, libcgroup's cgroup daemon moves tasks after exec().
>  So, it's not affected.
>  libcgroup's command "cgexec" does move itsef to a memcg and call exec()
>  without fork(). it's not affected.
> 
> Changelog:
>  - fixed PageAnon() check.
>  - remove call of lookup_swap_cache()
>  - fixed Documentation.
> 
> Suggested-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

It looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
