Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 8173F6B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 05:34:30 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so13491236obb.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 02:34:29 -0700 (PDT)
Date: Mon, 23 Apr 2012 02:33:11 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH RFC] memcg: MEMCG_NR_FILE_MAPPED should update
 _STAT_CACHE as well
Message-ID: <20120423093311.GA17412@lizard>
References: <20120302162753.GA11748@oksana.dev.rtsoft.ru>
 <20120305091934.588c160b.kamezawa.hiroyu@jp.fujitsu.com>
 <20120423082835.GA32359@lizard>
 <4F951440.7040704@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4F951440.7040704@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, John Stultz <john.stultz@linaro.org>, linaro-kernel@lists.linaro.org, patches@linaro.org

On Mon, Apr 23, 2012 at 05:35:12PM +0900, KAMEZAWA Hiroyuki wrote:
[...]
> > For example, looking into this code flow:
> > 
> > -> page_add_file_rmap() (mm/rmap.c)
> >  -> mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED) (include/linux/memcontrol.h)
> >   -> void mem_cgroup_update_page_stat(page, MEMCG_NR_FILE_MAPPED, 1) (mm/memcontrol.c)
> > 
> > And then:
> > 
> > void mem_cgroup_update_page_stat(struct page *page,
> >                                  enum mem_cgroup_page_stat_item idx, int val)
> > {
> >         ...
> >         switch (idx) {
> >         case MEMCG_NR_FILE_MAPPED:
> >                 idx = MEM_CGROUP_STAT_FILE_MAPPED;
> >                 break;
> >         default:
> >                 BUG();
> >         }
> > 
> >         this_cpu_add(memcg->stat->count[idx], val);
> >         ...
> > }
> > 
> > So, clearly, this function only bothers updating _FILE_MAPPED only,
> > leaving _CACHE alone.
[...]
> 
> NACK.
> CACHE is updated at charge()/uncharge()...inserting/removing page cache to radix-tree.

Interesting; true, we have charge/uncharge in __do_fault()/do_wp_page
and friends. So, we seem to update FILE_MAPPED in the rmap via
cgroup_dec/inc_page_stat, and CACHE is updated via charge/uncharge. Hm.

The code in memory.c is full of if/else ifs, and I wonder if there's 
some discrepancy in there, but briefly looking it looks fine. The
code looks correct indeed, but I'm getting the wrong stats. :-/

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
