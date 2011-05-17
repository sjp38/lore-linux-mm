Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BDD976B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 02:38:13 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p4H6c90A006226
	for <linux-mm@kvack.org>; Mon, 16 May 2011 23:38:09 -0700
Received: from qyj19 (qyj19.prod.google.com [10.241.83.83])
	by wpaz1.hot.corp.google.com with ESMTP id p4H6bWoF022767
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 23:38:08 -0700
Received: by qyj19 with SMTP id 19so2270664qyj.2
        for <linux-mm@kvack.org>; Mon, 16 May 2011 23:38:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110512160349.GJ16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-3-git-send-email-hannes@cmpxchg.org>
	<4DCBFDB9.10209@redhat.com>
	<20110512160349.GJ16531@cmpxchg.org>
Date: Mon, 16 May 2011 23:38:07 -0700
Message-ID: <BANLkTi=+hVKx6bkowgiiatPGwSy0m3=2uQ@mail.gmail.com>
Subject: Re: [rfc patch 2/6] vmscan: make distinction between memcg reclaim
 and LRU list selection
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 12, 2011 at 9:03 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Thu, May 12, 2011 at 11:33:13AM -0400, Rik van Riel wrote:
>> On 05/12/2011 10:53 AM, Johannes Weiner wrote:
>> >The reclaim code has a single predicate for whether it currently
>> >reclaims on behalf of a memory cgroup, as well as whether it is
>> >reclaiming from the global LRU list or a memory cgroup LRU list.
>> >
>> >Up to now, both cases always coincide, but subsequent patches will
>> >change things such that global reclaim will scan memory cgroup lists.
>> >
>> >This patch adds a new predicate that tells global reclaim from memory
>> >cgroup reclaim, and then changes all callsites that are actually about
>> >global reclaim heuristics rather than strict LRU list selection.
>> >
>> >Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
>> >---
>> > =A0mm/vmscan.c | =A0 96 ++++++++++++++++++++++++++++++++++------------=
------------
>> > =A01 files changed, 56 insertions(+), 40 deletions(-)
>> >
>> >diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >index f6b435c..ceeb2a5 100644
>> >--- a/mm/vmscan.c
>> >+++ b/mm/vmscan.c
>> >@@ -104,8 +104,12 @@ struct scan_control {
>> > =A0 =A0 =A0*/
>> > =A0 =A0 reclaim_mode_t reclaim_mode;
>> >
>> >- =A0 =A0/* Which cgroup do we reclaim from */
>> >- =A0 =A0struct mem_cgroup *mem_cgroup;
>> >+ =A0 =A0/*
>> >+ =A0 =A0 * The memory cgroup we reclaim on behalf of, and the one we
>> >+ =A0 =A0 * are currently reclaiming from.
>> >+ =A0 =A0 */
>> >+ =A0 =A0struct mem_cgroup *memcg;
>> >+ =A0 =A0struct mem_cgroup *current_memcg;
>>
>> I can't say I'm fond of these names. =A0I had to read the
>> rest of the patch to figure out that the old mem_cgroup
>> got renamed to current_memcg.
>
> To clarify: sc->memcg will be the memcg that hit the hard limit and is
> the main target of this reclaim invocation. =A0current_memcg is the
> iterator over the hierarchy below the target.

I would assume the new variable memcg is a renaming of the
"mem_cgroup" which indicating which cgroup we reclaim on behalf of.
About the "current_memcg", i couldn't find where it is indicating to
be the current cgroup under the hierarchy below the "memcg".

Both mem_cgroup_shrink_node_zone() and try_to_free_mem_cgroup_pages()
are called within mem_cgroup_hierarchical_reclaim(), and the sc->memcg
is initialized w/ the victim passed down which is already the memcg
under hierarchy.

--Ying


> I realize this change in particular was placed a bit unfortunate in
> terms of understanding in the series, I just wanted to keep out the
> mem_cgroup to current_memcg renaming out of the next patch. =A0There is
> probably a better way, I'll fix it up and improve the comment.
>
>> Would it be better to call them my_memcg and reclaim_memcg?
>>
>> Maybe somebody else has better suggestions...
>
> Yes, suggestions welcome. =A0I'm not too fond of the naming, either.
>
>> Other than the naming, no objection.
>
> Thanks, Rik.
>
> =A0 =A0 =A0 =A0Hannes
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
