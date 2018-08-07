Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16A886B0003
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 23:23:14 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w23-v6so6523120pgv.1
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 20:23:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id be1-v6sor49060plb.91.2018.08.06.20.23.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 20:23:12 -0700 (PDT)
Date: Mon, 6 Aug 2018 20:23:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Re: [PATCH] [PATCH] mm: disable preemption before
 swapcache_free
In-Reply-To: <20180807101540612373235@wingtech.com>
Message-ID: <alpine.LSU.2.11.1808061936080.1570@eggly.anvils>
References: <2018072514375722198958@wingtech.com>, <20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>, <2018072610214038358990@wingtech.com>, <20180726060640.GQ28386@dhcp22.suse.cz>, <20180726150323057627100@wingtech.com>,
 <20180726151118.db0cf8016e79bed849e549f9@linux-foundation.org>, <20180727140749669129112@wingtech.com>, <alpine.LSU.2.11.1808041332410.1120@eggly.anvils> <20180807101540612373235@wingtech.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-1084447320-1533612190=:1570"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: Hugh Dickins <hughd@google.com>, akpm <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-1084447320-1533612190=:1570
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 7 Aug 2018, zhaowuyun@wingtech.com wrote:
>=20
> Thanks for affirming the modification of disabling preemption and=20
> pointing out the incompleteness, delete_from_swap_cache() needs the same =
protection.
> I'm curious about that why don't put=C2=A0swapcache_free(swap) under prot=
ection of=C2=A0mapping->tree_lock ??

That would violate the long-established lock ordering (see not-always-
kept-up-to-date comments at the head of mm/rmap.c). In particular,
swap_lock (and its more recent descendants, such as swap_info->lock)
can be held with interrupts enabled, whereas taking tree_lock (later
called i_pages lock) involves disabling interrupts. So: there would
be quite a lot of modifications required to do swapcache_free(swap)
under mapping->tree_lock.

Generally easier would be to take tree_lock under swap lock: that fits
the establishd lock ordering, and is already done in just a few places
- or am I thinking of free_swap_and_cache() in the old days before
find_get_page() did lockless lookup? But you didn't suggest that way,
because it's more awkward in the __remove_mapping() case: I expect
that could be worked around with an initial PageSwapCache check,
taking swap locks there first (not inside swapcache_free()) -
__remove_mapping()'s BUG_ON(!PageLocked) implies that won't be racy.

But either way round, why? What would be the advantage in doing so?
A more conventional nesting of locks, easier to describe and understand,
yes. But from a performance point of view, thinking of lock contention,
nothing but disadvantage. And don't forget the get_swap_page() end:
there it would be harder to deal with both locks together (at least
in the shmem case).

Hugh
--0-1084447320-1533612190=:1570--
