Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 8934F6B007E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 20:26:45 -0400 (EDT)
Date: Thu, 22 Mar 2012 17:30:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: change behavior of moving charges at task move
Message-Id: <20120322173000.f078a43f.akpm@linux-foundation.org>
In-Reply-To: <4F6BC166.80407@jp.fujitsu.com>
References: <4F69A4C4.4080602@jp.fujitsu.com>
	<20120322143610.e4df49c9.akpm@linux-foundation.org>
	<4F6BC166.80407@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>

On Fri, 23 Mar 2012 09:18:46 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >> +#ifdef CONFIG_SWAP
> >> +	/*
> >> +	 * Avoid lookup_swap_cache() not to update statistics.
> >> +	 */
> > 
> > I don't understand this comment - what is it trying to tell us?
> > 
> 
> 
> High Dickins advised me to use find_get_page() rather than lookup_swap_cache()
> because lookup_swap_cache() has some statistics with swap.

ah.

--- a/mm/memcontrol.c~memcg-change-behavior-of-moving-charges-at-task-move-fix
+++ a/mm/memcontrol.c
@@ -5137,7 +5137,8 @@ static struct page *mc_handle_swap_pte(s
 		return NULL;
 #ifdef CONFIG_SWAP
 	/*
-	 * Avoid lookup_swap_cache() not to update statistics.
+	 * Use find_get_page() rather than lookup_swap_cache() because the
+	 * latter alters statistics.
 	 */
 	page = find_get_page(&swapper_space, ent.val);
 #endif

> >> +	page = find_get_page(&swapper_space, ent.val);
> > 
> > The code won't even compile if CONFIG_SWAP=n?
> > 
> 
> mm/built-in.o: In function `mc_handle_swap_pte':
> /home/kamezawa/Kernel/next/linux/mm/memcontrol.c:5172: undefined reference to `swapper_space'
> make: *** [.tmp_vmlinux1] Error 1
> 
> Ah...but I think this function (mc_handle_swap_pte) itself should be under CONFIG_SWAP.
> I'll post v2.

Confused.  The new reference to swapper_space is already inside #ifdef
CONFIG_SWAP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
