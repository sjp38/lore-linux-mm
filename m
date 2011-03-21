Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABCD8D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 13:23:00 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p2LHMiBs026511
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 10:22:46 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by wpaz33.hot.corp.google.com with ESMTP id p2LHLpeF019252
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 10:22:43 -0700
Received: by qwj9 with SMTP id 9so5314961qwj.35
        for <linux-mm@kvack.org>; Mon, 21 Mar 2011 10:22:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110321093419.GA26047@tiehlicka.suse.cz>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
	<20110321093419.GA26047@tiehlicka.suse.cz>
Date: Mon, 21 Mar 2011 10:22:41 -0700
Message-ID: <AANLkTimkcYcZVifaq4pH4exkWUVNXpwXA=9oyeAn_EqR@mail.gmail.com>
Subject: Re: cgroup: real meaning of memory.usage_in_bytes
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Mar 21, 2011 at 2:34 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 18-03-11 16:25:32, Michal Hocko wrote:
> [...]
>> According to our documention this is a reasonable test case:
>> Documentation/cgroups/memory.txt:
>> memory.usage_in_bytes =A0 =A0 =A0 =A0 =A0 # show current memory(RSS+Cach=
e) usage.
>>
>> This however doesn't work after your commit:
>> cdec2e4265d (memcg: coalesce charging via percpu storage)
>>
>> because since then we are charging in bulks so we can end up with
>> rss+cache <=3D usage_in_bytes.
> [...]
>> I think we have several options here
>> =A0 =A0 =A0 1) document that the value is actually >=3D rss+cache and it=
 shows
>> =A0 =A0 =A0 =A0 =A0the guaranteed charges for the group
>> =A0 =A0 =A0 2) use rss+cache rather then res->count
>> =A0 =A0 =A0 3) remove the file
>> =A0 =A0 =A0 4) call drain_all_stock_sync before asking for the value in
>> =A0 =A0 =A0 =A0 =A0mem_cgroup_read
>> =A0 =A0 =A0 5) collect the current amount of stock charges and subtract =
it
>> =A0 =A0 =A0 =A0 =A0from the current res->count value
>>
>> 1) and 2) would suggest that the file is actually not very much useful.
>> 3) is basically the interface change as well
>> 4) sounds little bit invasive as we basically lose the advantage of the
>> pool whenever somebody reads the file. Btw. for who is this file
>> intended?
>> 5) sounds like a compromise
>
> I guess that 4) is really too invasive - for no good reason so here we
> go with the 5) solution.
> ---
> From: Michal Hocko <mhocko@suse.cz>
> Subject: Drain memcg_stock before returning res->count value
>
> Since cdec2e4265d (memcg: coalesce charging via percpu storage) commit we
> are charging resource counter in batches. This means that the current
> res->count value doesn't show the real consumed value (rss+cache as we
> describe in the documentation) but rather a promissed charges for future.
> We are pre-charging CHARGE_SIZE bulk at once and subsequent charges are
> satisfied from the per-cpu cgroup_stock pool.
>
> We have seen a report that one of the LTP testcases checks exactly this
> condition so the test fails.
>
> As this exported value is a part of kernel->userspace interface we should
> try to preserve the original (and documented) semantic.
>
> This patch fixes the issue by collecting the current usage of each per-cp=
u
> stock and subtracting it from the current res counter value.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Index: linus_tree/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linus_tree.orig/mm/memcontrol.c =A0 =A0 2011-03-18 16:09:11.000000000=
 +0100
> +++ linus_tree/mm/memcontrol.c =A02011-03-21 10:21:55.000000000 +0100
> @@ -3579,13 +3579,30 @@ static unsigned long mem_cgroup_recursiv
> =A0 =A0 =A0 =A0return val;
> =A0}
>
> +static u64 mem_cgroup_current_usage(struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 u64 val =3D res_counter_read_u64(&mem->res, RES_USAGE);
> + =A0 =A0 =A0 u64 per_cpu_val =3D 0;
> + =A0 =A0 =A0 int cpu;
> +
> + =A0 =A0 =A0 get_online_cpus();
> + =A0 =A0 =A0 for_each_online_cpu(cpu) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct memcg_stock_pcp *stock =3D &per_cpu(=
memcg_stock, cpu);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 per_cpu_val +=3D stock->nr_pages * PAGE_SIZ=
E;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 put_online_cpus();
> +
> + =A0 =A0 =A0 return (val > per_cpu_val)? val - per_cpu_val: 0;
> +}
> +
> =A0static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
> =A0{
> =A0 =A0 =A0 =A0u64 val;
>
> =A0 =A0 =A0 =A0if (!mem_cgroup_is_root(mem)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!swap)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return res_counter_read_u64=
(&mem->res, RES_USAGE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return mem_cgroup_current_u=
sage(mem);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return res_counter_read_u6=
4(&mem->memsw, RES_USAGE);
> =A0 =A0 =A0 =A0}

Michal,

Can you help to post the test result after applying the patch?

--Ying

> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
