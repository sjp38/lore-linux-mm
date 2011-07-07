Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A8D9F9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 04:35:22 -0400 (EDT)
Received: by iwn8 with SMTP id 8so851476iwn.14
        for <linux-mm@kvack.org>; Thu, 07 Jul 2011 01:35:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110707155217.909c429a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110707155217.909c429a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 7 Jul 2011 14:05:19 +0530
Message-ID: <CAKTCnzkFnsWmg_7zbqN4GfxTtCMZ4FW94NxOP0AG+UKp=xSepA@mail.gmail.com>
Subject: Re: [PATCH][Cleanup] memcg: consolidates memory cgroup lru stat functions
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Thu, Jul 7, 2011 at 12:22 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> In mm/memcontrol.c, there are many lru stat functions as..
>
> mem_cgroup_zone_nr_lru_pages
> mem_cgroup_node_nr_file_lru_pages
> mem_cgroup_nr_file_lru_pages
> mem_cgroup_node_nr_anon_lru_pages
> mem_cgroup_nr_anon_lru_pages
> mem_cgroup_node_nr_unevictable_lru_pages
> mem_cgroup_nr_unevictable_lru_pages
> mem_cgroup_node_nr_lru_pages
> mem_cgroup_nr_lru_pages
> mem_cgroup_get_local_zonestat
>
> Some of them are under #ifdef MAX_NUMNODES >1 and others are not.
> This seems bad. This patch consolidates all functions into
>
> mem_cgroup_zone_nr_lru_pages()
> mem_cgroup_node_nr_lru_pages()
> mem_cgroup_nr_lru_pages()
>
> For these functions, "which LRU?" information is passed by a mask.
>
> example)
> mem_cgroup_nr_lru_pages(mem, BIT(LRU_ACTIVE_ANON))
>
> And I added some macro as ALL_LRU, ALL_LRU_FILE, ALL_LRU_ANON.
> example)
> mem_cgroup_nr_lru_pages(mem, ALL_LRU)
>
> BTW, considering layout of NUMA memory placement of counters, this patch =
seems
> to be better.
>
> Now, when we gather all LRU information, we scan in following orer
> =A0 =A0for_each_lru -> for_each_node -> for_each_zone.
>
> This means we'll touch cache lines in different node in turn.
>
> After patch, we'll scan
> =A0 =A0for_each_node -> for_each_zone -> for_each_lru(mask)
>
> Then, we'll gather information in the same cacheline at once.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks like a good cleanup, but unfortunately I won't be able to test
any patches till the end of next week or so

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
