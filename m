Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id B915F6B00FD
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 12:33:33 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so2003429lbb.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 09:33:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120416151507.GC2014@tiehlicka.suse.cz>
References: <1334181614-26836-1-git-send-email-yinghan@google.com>
	<4F8625AD.6000707@redhat.com>
	<20120412022233.GF1787@cmpxchg.org>
	<20120416151507.GC2014@tiehlicka.suse.cz>
Date: Mon, 16 Apr 2012 09:33:31 -0700
Message-ID: <CALWz4iwdQ7Z+f8Fv2G9T1Ge0Ek3Ce2vhD-bz8qXSNQzkoaOVFQ@mail.gmail.com>
Subject: Re: [PATCH V2 3/5] memcg: set soft_limit_in_bytes to 0 by default
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Mon, Apr 16, 2012 at 8:15 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 12-04-12 04:22:33, Johannes Weiner wrote:
>> On Wed, Apr 11, 2012 at 08:45:33PM -0400, Rik van Riel wrote:
>> > On 04/11/2012 06:00 PM, Ying Han wrote:
>> > >1. If soft_limit are all set to MAX, it wastes first three periority =
iterations
>> > >without scanning anything.
>> > >
>> > >2. By default every memcg is eligibal for softlimit reclaim, and we c=
an also
>> > >set the value to MAX for special memcg which is immune to soft limit =
reclaim.
>> > >
>> > >This idea is based on discussion with Michal and Johannes from LSF.
>> >
>> > Combined with patch 2/5, would this not result in always
>> > returning "reclaim from this memcg" for groups without a
>> > configured softlimit, while groups with a configured
>> > softlimit only get reclaimed from when they are over
>> > their limit?
>> >
>> > Is that the desired behaviour when a system has some
>> > cgroups with a configured softlimit, and some without?
>>
>> Yes, in general I think this new behaviour is welcome.
>>
>> In the past, soft limits were only used to give excess memory a lower
>> priority and there was no particular meaning associated with "being
>> below your soft limit". =A0This change makes it so that soft limits are
>> actually a minimum guarantee, too, so you wouldn't get reclaimed if
>> you behaved (if possible):
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 A-unconfigured =A0 =A0 =A0 =A0 =A0B-below-so=
ftlimit
>> old: =A0 =A0 =A0 =A0 =A0reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim
>> new: =A0 =A0 =A0 =A0 =A0reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 no recla=
im (if possible)
>>
>> The much less obvious change here, however, is that we no longer put
>> extra pressure on groups above their limit compared to unconfigured
>> groups:
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 A-unconfigured =A0 =A0 =A0 =A0 =A0B-above-so=
ftlimit
>> old: =A0 =A0 =A0 =A0 =A0reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim =
twice
>> new: =A0 =A0 =A0 =A0 =A0reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim
>
> Agreed and I guess that the above should be a part of the changelog.
> This is changing previous behavior and we should rather be explicit
> about that.

Ok, I will include it on next post.

Thanks !

--Ying

>
>> I still think that it's a reasonable use case to put a soft limit on a
>> workload to "nice" it memory-wise, without looking at the machine as a
>> whole and configuring EVERY cgroup based on global knowledge and
>> static partitioning of the machine.
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
