Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 2D4546B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 20:20:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 356353EE0BB
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 09:20:30 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E41B45DD78
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 09:20:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 089FA45DD74
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 09:20:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE8BC1DB803C
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 09:20:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A91811DB802C
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 09:20:29 +0900 (JST)
Message-ID: <4F6BC166.80407@jp.fujitsu.com>
Date: Fri, 23 Mar 2012 09:18:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: change behavior of moving charges at task move
References: <4F69A4C4.4080602@jp.fujitsu.com> <20120322143610.e4df49c9.akpm@linux-foundation.org>
In-Reply-To: <20120322143610.e4df49c9.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>

(2012/03/23 6:36), Andrew Morton wrote:

> On Wed, 21 Mar 2012 18:52:04 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>>  static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
>>  			unsigned long addr, pte_t ptent, swp_entry_t *entry)
>>  {
>> -	int usage_count;
>>  	struct page *page = NULL;
>>  	swp_entry_t ent = pte_to_swp_entry(ptent);
>>  
>>  	if (!move_anon() || non_swap_entry(ent))
>>  		return NULL;
>> -	usage_count = mem_cgroup_count_swap_user(ent, &page);
>> -	if (usage_count > 1) { /* we don't move shared anon */
>> -		if (page)
>> -			put_page(page);
>> -		return NULL;
>> -	}
>> +#ifdef CONFIG_SWAP
>> +	/*
>> +	 * Avoid lookup_swap_cache() not to update statistics.
>> +	 */
> 
> I don't understand this comment - what is it trying to tell us?
> 


High Dickins advised me to use find_get_page() rather than lookup_swap_cache()
because lookup_swap_cache() has some statistics with swap.

>> +	page = find_get_page(&swapper_space, ent.val);
> 
> The code won't even compile if CONFIG_SWAP=n?
> 

mm/built-in.o: In function `mc_handle_swap_pte':
/home/kamezawa/Kernel/next/linux/mm/memcontrol.c:5172: undefined reference to `swapper_space'
make: *** [.tmp_vmlinux1] Error 1

Ah...but I think this function (mc_handle_swap_pte) itself should be under CONFIG_SWAP.
I'll post v2.

Thank you for review!
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
