Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A74626B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 20:12:59 -0500 (EST)
Received: by pwi1 with SMTP id 1so337982pwi.6
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:12:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091210170137.8031e4cf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091210170137.8031e4cf.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 11 Dec 2009 10:12:57 +0900
Message-ID: <28c262360912101712g1c78396die769fe6a5cc3df82@mail.gmail.com>
Subject: Re: [RFC mm][PATCH 5/5] counting lowmem rss per mm
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, Dec 10, 2009 at 5:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Some case of OOM-Kill is caused by memory shortage in lowmem area. For ex=
ample,
> NORMAL_ZONE is exhausted on x86-32/HIGHMEM kernel.
>
> Now, oom-killer doesn't have no lowmem usage information of processes and
> selects victim processes based on global memory usage information.
> In bad case, this can cause chains of kills of innocent processes without
> progress, oom-serial-killer.
>
> For making oom-killer lowmem aware, this patch adds counters for accounti=
ng
> lowmem usage per process. (patches for oom-killer is not included in this=
.)
>
> Adding counter is easy but one of concern is the cost for new counter.
>
> Following is the test result of micro-benchmark of parallel page faults.
> Bigger page fault number indicates better scalability.
> (measured under USE_SPLIT_PTLOCKS environemt)
> [Before lowmem counter]
> =C2=A0Performance counter stats for './multi-fault 2' (5 runs):
>
> =C2=A0 =C2=A0 =C2=A0 46997471 =C2=A0page-faults =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0( +- =C2=A0 0.720% )
> =C2=A0 =C2=A0 1004100076 =C2=A0cache-references =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 ( +- =C2=A0 0.734% )
> =C2=A0 =C2=A0 =C2=A0180959964 =C2=A0cache-misses =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.374% )
> =C2=A029263437363580464 =C2=A0bus-cycles =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.002% )
>
> =C2=A0 60.003315683 =C2=A0seconds time elapsed =C2=A0 ( +- =C2=A0 0.004% =
)
>
> 3.85 miss/faults
> [After lowmem counter]
> =C2=A0Performance counter stats for './multi-fault 2' (5 runs):
>
> =C2=A0 =C2=A0 =C2=A0 45976947 =C2=A0page-faults =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0( +- =C2=A0 0.405% )
> =C2=A0 =C2=A0 =C2=A0992296954 =C2=A0cache-references =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 ( +- =C2=A0 0.860% )
> =C2=A0 =C2=A0 =C2=A0183961537 =C2=A0cache-misses =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.473% )
> =C2=A029261902069414016 =C2=A0bus-cycles =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.002% )
>
> =C2=A0 60.001403261 =C2=A0seconds time elapsed =C2=A0 ( +- =C2=A0 0.000% =
)
>
> 4.0 miss/faults.
>
> Then, small cost is added. But I think this is within reasonable
> range.
>
> If you have good idea for improve this number, it's welcome.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
