Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7ACD96B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 19:34:18 -0400 (EDT)
Received: by yhr47 with SMTP id 47so3905625yhr.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:34:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335214564-17619-1-git-send-email-yinghan@google.com>
References: <1335214564-17619-1-git-send-email-yinghan@google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 11 Jun 2012 19:33:57 -0400
Message-ID: <CAHGf_=qn_f5Vm4S=X99siuQzAJcHe8vSLJzU48GXTZXLZgGuWQ@mail.gmail.com>
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Apr 23, 2012 at 4:56 PM, Ying Han <yinghan@google.com> wrote:
> This is not a patch targeted to be merged at all, but trying to understan=
d
> a logic in global direct reclaim.
>
> There is a logic in global direct reclaim where reclaim fails on priority=
 0
> and zone->all_unreclaimable is not set, it will cause the direct to start=
 over
> from DEF_PRIORITY. In some extreme cases, we've seen the system hang whic=
h is
> very likely caused by direct reclaim enters infinite loop.
>
> There have been serious patches trying to fix similar issue and the lates=
t
> patch has good summary of all the efforts:
>
> commit 929bea7c714220fc76ce3f75bef9056477c28e74
> Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: =A0 Thu Apr 14 15:22:12 2011 -0700
>
> =A0 =A0vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
>
> Kosaki explained the problem triggered by async zone->all_unreclaimable a=
nd
> zone->pages_scanned where the later one was being checked by direct recla=
im.
> However, after the patch, the problem remains where the setting of
> zone->all_unreclaimable is asynchronous with zone is actually reclaimable=
 or not.
>
> The zone->all_unreclaimable flag is set by kswapd by checking zone->pages=
_scanned in
> zone_reclaimable(). Is that possible to have zone->all_unreclaimable =3D=
=3D false while
> the zone is actually unreclaimable?

I'm backed very old threads. :-(
I could reproduce this issue by using memory hotplug. Can anyone
review following patch?
