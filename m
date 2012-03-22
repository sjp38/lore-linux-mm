Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 5CA096B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:29:43 -0400 (EDT)
Date: Thu, 22 Mar 2012 14:29:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: change behavior of moving charges at task move
Message-Id: <20120322142941.01e601c0.akpm@linux-foundation.org>
In-Reply-To: <4F69A4C4.4080602@jp.fujitsu.com>
References: <4F69A4C4.4080602@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>

On Wed, 21 Mar 2012 18:52:04 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> As discussed before, I post this to fix the spec and implementation of task moving.
> Then, do you think what target kernel version should be ? 3.4/3.5 ?
> but yes, it may be late for 3.4....

Well, the key information here is "what effect does the bug have upon
users".

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

But you forgot to tell us :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
