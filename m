Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 330DA6B00ED
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 19:27:50 -0400 (EDT)
Received: by lagz14 with SMTP id z14so10222889lag.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 16:27:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120420231501.GE2536@cmpxchg.org>
References: <1334680682-12430-1-git-send-email-yinghan@google.com>
	<20120420091731.GE4191@tiehlicka.suse.cz>
	<CALWz4iyTH8a77w2bOkSXiODiNEn+L7SFv8Njp1_fRwi8aFVZHw@mail.gmail.com>
	<20120420231501.GE2536@cmpxchg.org>
Date: Fri, 20 Apr 2012 16:27:47 -0700
Message-ID: <CALWz4izU+=LtLQwd0daeJvBy0HVRdwDLjncFCmA2TnTny+cRXA@mail.gmail.com>
Subject: Re: [PATCH V3 1/2] memcg: softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Fri, Apr 20, 2012 at 11:22:14AM -0700, Ying Han wrote:
>> On Fri, Apr 20, 2012 at 2:17 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> > On Tue 17-04-12 09:38:02, Ying Han wrote:
>> >> This patch reverts all the existing softlimit reclaim implementations=
 and
>> >> instead integrates the softlimit reclaim into existing global reclaim=
 logic.
>> >>
>> >> The new softlimit reclaim includes the following changes:
>> >>
>> >> 1. add function should_reclaim_mem_cgroup()
>> >>
>> >> Add the filter function should_reclaim_mem_cgroup() under the common =
function
>> >> shrink_zone(). The later one is being called both from per-memcg recl=
aim as
>> >> well as global reclaim.
>> >>
>> >> Today the softlimit takes effect only under global memory pressure. T=
he memcgs
>> >> get free run above their softlimit until there is a global memory con=
tention.
>> >> This patch doesn't change the semantics.
>> >
>> > I am not sure I understand but I think it does change the semantics.
>> > Previously we looked at a group with the biggest excess and reclaim th=
at
>> > group _hierarchically_.
>>
>> yes, we don't do _hierarchically_ reclaim reclaim in this patch. Hmm,
>> that might be what Johannes insists to preserve on the other
>> thread.... ?
>
> Yes, that is exactly what I was talking about all along :-)
>
> To reiterate, in the case of
>
> A (soft =3D 10G)
> =A0A1
> =A0A2
> =A0A3
> =A0...
>
> global reclaim should go for A, A1, A2, A3, ... when their sum usage
> goes above 10G. =A0Regardless of any setting in those subgroups, for
> reasons I outlined in the other subthread (basically, allowing
> children to override parental settings assumes you trust all children
> and their settings to be 'cooperative', which is unprecedented cgroup
> semantics, afaics, and we can already see this will make problems in
> the future)

I understand your concern here. Having children to override the
parental setting is not what we want, but I think this is a
mis-configuration. If admin chose to use soft_limit, we need to lay
out the ground rule.

I gave some details on the other thread, maybe we can move the
conversation there :)

>
> Meanwhile, if you don't want a hierarchical limit, don't set a
> hierarchical limit. =A0It's possible to organize the tree such that you
> don't need to, and it should not be an unreasonable amount of work to
> do so).

Not setting it won't work either way.

1. unlimited: it will never get the pages under A being reclaimed
2. 0: it will get everything being reclaimed under A based on your logic.

Have a nice weekend !

--Ying

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
