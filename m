Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 241816B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 19:02:28 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p7CN2PVf011999
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 16:02:25 -0700
Received: from ywb3 (ywb3.prod.google.com [10.192.2.3])
	by wpaz29.hot.corp.google.com with ESMTP id p7CN1KC6012323
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 16:02:24 -0700
Received: by ywb3 with SMTP id 3so2240225ywb.15
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 16:02:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110812160813.GF2395@linux.vnet.ibm.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
	<CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
	<20110807142532.GC1823@barrios-desktop>
	<CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
	<20110812153616.GH7959@redhat.com>
	<20110812160813.GF2395@linux.vnet.ibm.com>
Date: Fri, 12 Aug 2011 16:02:23 -0700
Message-ID: <CANN689FC7_Jz7xxzOMB-KSxcNL-Um+H00EMNGqbg_zLFFRyZuw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 9:08 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Fri, Aug 12, 2011 at 05:36:16PM +0200, Andrea Arcangeli wrote:
>> On Tue, Aug 09, 2011 at 04:04:21AM -0700, Michel Lespinasse wrote:
>> > - It'd be sweet if one could somehow record the time a THP page was
>> > created, and wait for at least one RCU grace period *starting from the
>> > recorded THP creation time* before splitting huge pages. In practice,
>> > we would be very unlikely to have to wait since the grace period would
>> > be already expired. However, I don't think RCU currently provides such
>> > a mechanism - Paul, is this something that would seem easy to
>> > implement or not ?
>
> It should not be hard. =A0I already have an API for rcutorture testing
> use, but it is not appropriate for your use because it is unsynchronized.

Yay!

> We need to be careful with what I give you and how you interpret it.
> The most effective approach would be for me to give you an API that
> filled in a cookie given a pointer to one, then another API that took
> pointers to a pair of cookies and returned saying whether or not a
> grace period had elapsed. =A0You would do something like the following:
>
> =A0 =A0 =A0 =A0rcu_get_gp_cookie(&pagep->rcucookie);
> =A0 =A0 =A0 =A0. . .
>
> =A0 =A0 =A0 =A0rcu_get_gp_cookie(&autovarcookie);
> =A0 =A0 =A0 =A0if (!rcu_cookie_gp_elapsed(&pagep->rcucookie, &autovarcook=
ie))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0synchronize_rcu();

This would work. The minimal interface I actually need would be:

> So, how much space do I get for ->rcucookie? =A0By default, it is a pair
> of unsigned longs, but I could live with as small as a single byte if
> you didn't mind a high probability of false negatives (me telling you
> to do a grace period despite 16 of them having happened in the meantime
> due to overflow of a 4-bit field in the byte).

Two longs per cookie would work. We could most easily store them in
(page_head+2)->lru. This assumes THP pages will always be at least
order 2, but I don't think that's a problem.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
