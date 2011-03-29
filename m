Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 253378D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 17:36:47 -0400 (EDT)
Received: by iwg8 with SMTP id 8so802412iwg.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 14:36:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1301379384-17568-1-git-send-email-yinghan@google.com>
References: <1301379384-17568-1-git-send-email-yinghan@google.com>
Date: Wed, 30 Mar 2011 06:36:44 +0900
Message-ID: <BANLkTinNnOS5JethdjiCrTwpKuW+apEwQQ@mail.gmail.com>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Mar 29, 2011 at 3:16 PM, Ying Han <yinghan@google.com> wrote:
> Two new stats in per-memcg memory.stat which tracks the number of
> page faults and number of major page faults.
>
> "pgfault"
> "pgmajfault"
>
> They are different from "pgpgin"/"pgpgout" stat which count number of
> pages charged/discharged to the cgroup and have no meaning of reading/
> writing page to disk.
>
> It is valuable to track the two stats for both measuring application's
> performance as well as the efficiency of the kernel page reclaim path.
> Counting pagefaults per process is useful, but we also need the aggregate=
d
> value since processes are monitored and controlled in cgroup basis in mem=
cg.
>
> Functional test: check the total number of pgfault/pgmajfault of all
> memcgs and compare with global vmstat value:
>
> $ cat /proc/vmstat | grep fault
> pgfault 1070751
> pgmajfault 553
>
> $ cat /dev/cgroup/memory.stat | grep fault
> pgfault 1071138
> pgmajfault 553
> total_pgfault 1071142
> total_pgmajfault 553
>
> $ cat /dev/cgroup/A/memory.stat | grep fault
> pgfault 199
> pgmajfault 0
> total_pgfault 199
> total_pgmajfault 0
>
> Performance test: run page fault test(pft) wit 16 thread on faulting in 1=
5G
> anon pages in 16G container. There is no regression noticed on the "flt/c=
pu/s"
>
> Sample output from pft:
> TAG pft:anon-sys-default:
> =C2=A0Gb =C2=A0Thr CLine =C2=A0 User =C2=A0 =C2=A0 System =C2=A0 =C2=A0 W=
all =C2=A0 =C2=A0flt/cpu/s fault/wsec
> =C2=A015 =C2=A0 16 =C2=A0 1 =C2=A0 =C2=A0 0.67s =C2=A0 233.41s =C2=A0 =C2=
=A014.76s =C2=A0 16798.546 266356.260
>
> +------------------------------------------------------------------------=
-+
> =C2=A0 =C2=A0N =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Min =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 Max =C2=A0 =C2=A0 =C2=A0 =C2=A0Median =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 Avg =C2=A0 =C2=A0 =C2=A0 =C2=A0Stddev
> x =C2=A010 =C2=A0 =C2=A0 16682.962 =C2=A0 =C2=A0 17344.027 =C2=A0 =C2=A0 =
16913.524 =C2=A0 =C2=A0 16928.812 =C2=A0 =C2=A0 =C2=A0166.5362
> + =C2=A010 =C2=A0 =C2=A0 16695.568 =C2=A0 =C2=A0 16923.896 =C2=A0 =C2=A0 =
16820.604 =C2=A0 =C2=A0 16824.652 =C2=A0 =C2=A0 84.816568
> No difference proven at 95.0% confidence
>
> Change V3..v2
> 1. removed the unnecessary function definition in memcontrol.h
>
> Signed-off-by: Ying Han <yinghan@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
