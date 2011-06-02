Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC6786B007B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 11:54:43 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1659563bwz.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 08:54:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602142408.GB28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
	<BANLkTinHs7OCkpRf8=dYO0ObH5sndZ4__g@mail.gmail.com>
	<20110602142408.GB28684@cmpxchg.org>
Date: Fri, 3 Jun 2011 00:54:39 +0900
Message-ID: <BANLkTikjjH3vCiwpKrs=+vbaaACC67H7Og@mail.gmail.com>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011/6/2 Johannes Weiner <hannes@cmpxchg.org>:
> On Thu, Jun 02, 2011 at 10:16:59PM +0900, Hiroyuki Kamezawa wrote:
>> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
>> > All lru list walkers have been converted to operate on per-memcg
>> > lists, the global per-zone lists are no longer required.
>> >
>> > This patch makes the per-memcg lists exclusive and removes the global
>> > lists from memcg-enabled kernels.
>> >
>> > The per-memcg lists now string up page descriptors directly, which
>> > unifies/simplifies the list isolation code of page reclaim as well as
>> > it saves a full double-linked list head for each page in the system.
>> >
>> > At the core of this change is the introduction of the lruvec
>> > structure, an array of all lru list heads. =A0It exists for each zone
>> > globally, and for each zone per memcg. =A0All lru list operations are
>> > now done in generic code against lruvecs, with the memcg lru list
>> > primitives only doing accounting and returning the proper lruvec for
>> > the currently scanned memcg on isolation, or for the respective page
>> > on putback.
>> >
>> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>>
>>
>> could you divide this into
>> =A0 - introduce lruvec
>> =A0 - don't record section? information into pc->flags because we see
>> "page" on memcg LRU
>> =A0 =A0 and there is no requirement to get page from "pc".
>> =A0 - remove pc->lru completely
>
> Yes, that makes sense. =A0It shall be fixed in the next version.
>

BTW, IIUC, Transparent hugepage has a code to link a page to the
page->lru directly.
And recent Minchan's work does the same kind of trick.

But it may put a page onto wrong memcgs if we do link a page to
another page's page->lru
because 2 pages may be in different cgroup each other.

Could you check there are more codes which does link page->lru to nearby pa=
ge's
page->lru ? Now, I'm not sure there are other codes....but we need care.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
