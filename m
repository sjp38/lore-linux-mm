Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 46C586B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:07:25 -0500 (EST)
Received: by qcsf14 with SMTP id f14so219036qcs.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 12:07:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120118130102.GC31112@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113173227.df2baae3.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117151619.GA21348@tiehlicka.suse.cz>
	<20120118085558.6ed1a988.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118130102.GC31112@tiehlicka.suse.cz>
Date: Thu, 19 Jan 2012 12:07:22 -0800
Message-ID: <CALWz4iy=hpEbXgjdkD+OH69MHjBorSELB3RZ8BxWNFjk=5yRNw@mail.gmail.com>
Subject: Re: [RFC] [PATCH 1/7 v2] memcg: remove unnecessary check in mem_cgroup_update_page_stat()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Wed, Jan 18, 2012 at 5:01 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Wed 18-01-12 08:55:58, KAMEZAWA Hiroyuki wrote:
>> On Tue, 17 Jan 2012 16:16:20 +0100
>> Michal Hocko <mhocko@suse.cz> wrote:
>>
>> > On Fri 13-01-12 17:32:27, KAMEZAWA Hiroyuki wrote:
>> > >
>> > > From 788aebf15f3fa37940e0745cab72547e20683bf2 Mon Sep 17 00:00:00 20=
01
>> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > > Date: Thu, 12 Jan 2012 16:08:33 +0900
>> > > Subject: [PATCH 1/7] memcg: remove unnecessary check in mem_cgroup_u=
pdate_page_stat()
>> > >
>> > > commit 10ea69f1182b removes move_lock_page_cgroup() in thp-split pat=
h.
>> > > So, this PageTransHuge() check is unnecessary, too.
>> >
>> > I do not see commit like that in the tree. I guess you meant
>> > memcg: make mem_cgroup_split_huge_fixup() more efficient which is not
>> > merged yet, right?
>> >
>>
>> This commit in the linux-next.
>
> Referring to commits from linux-next is tricky as it changes all the
> time. I guess that the full commit subject should be sufficient.
>
>> > > Note:
>> > > =A0- considering when mem_cgroup_update_page_stat() is called,
>> > > =A0 =A0there will be no race between split_huge_page() and update_pa=
ge_stat().
>> > > =A0 =A0All required locks are held in higher level.
>> >
>> > We should never have THP page in this path in the first place. So why
>> > not changing this to VM_BUG_ON(PageTransHuge).
>> >
>>
>> Ying Han considers to support mlock stat.
>
> OK, got it. What about the following updated changelog instead?
>
> =3D=3D=3D
> We do not have to check PageTransHuge in mem_cgroup_update_page_stat
> and fallback into the locked accounting because both move charge and thp

one nitpick. Should it be "move account" instead of "move charge"?

--Ying

> split up are done with compound_lock so they cannot race. update vs.
> move is protected by the mem_cgroup_stealed sufficiently.
>
> PageTransHuge pages shouldn't appear in this code path currently because
> we are tracking only file pages at the moment but later we are planning
> to track also other pages (e.g. mlocked ones).
> =3D=3D=3D
>
>>
>> Thanks,
>> -Kame
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe cgroups" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
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
