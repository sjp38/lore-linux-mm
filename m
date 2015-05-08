Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 04EB66B0032
	for <linux-mm@kvack.org>; Fri,  8 May 2015 04:29:29 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so65127272ied.1
        for <linux-mm@kvack.org>; Fri, 08 May 2015 01:29:28 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id x3si3570550icm.57.2015.05.08.01.29.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 01:29:28 -0700 (PDT)
Received: by igbyr2 with SMTP id yr2so15099672igb.0
        for <linux-mm@kvack.org>; Fri, 08 May 2015 01:29:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2137546797.259031431072097606.JavaMail.weblogic@epmlwas09d>
References: <2137546797.259031431072097606.JavaMail.weblogic@epmlwas09d>
Date: Fri, 8 May 2015 16:29:27 +0800
Message-ID: <CAFP4FLoS9whmao-ufECwf9gqEhc6KV-aZ-K4_RsOnkPrEWoaVg@mail.gmail.com>
Subject: Re: Re: [EDT] oom_killer: find bulkiest task based on pss value
From: yalin wang <yalin.wang2010@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yn.gaur@samsung.com, linux-mm@kvack.org
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, AJEET YADAV <ajeet.y@samsung.com>, Amit Arora <amit.arora@samsung.com>

2015-05-08 16:01 GMT+08:00 Yogesh Narayan Gaur <yn.gaur@samsung.com>:
> EP-2DAD0AFA905A4ACB804C4F82A001242F
>
> ------- Original Message -------
> Sender : yalin wang<yalin.wang2010@gmail.com>
> Date : May 08, 2015 13:17 (GMT+05:30)
> Title : Re: [EDT] oom_killer: find bulkiest task based on pss value
>
> 2015-05-08 13:29 GMT+08:00 Yogesh Narayan Gaur :
>>>
>>> EP-2DAD0AFA905A4ACB804C4F82A001242F
>>> Hi Andrew,
>>>
>>> Presently in oom_kill.c we calculate badness score of the victim task a=
s per the present RSS counter value of the task.
>>> RSS counter value for any task is usually '[Private (Dirty/Clean)] + [S=
hared (Dirty/Clean)]' of the task.
>>> We have encountered a situation where values for Private fields are les=
s but value for Shared fields are more and hence make total RSS counter val=
ue large. Later on oom situation killing task with highest RSS value but as=
 Private field values are not large hence memory gain after killing this pr=
ocess is not as per the expectation.
>>>
>>> For e.g. take below use-case scenario, in which 3 process are running i=
n system.
>>> All these process done mmap for file exist in present directory and the=
n copying data from this file to local allocated pointers in while(1) loop =
with some sleep. Out of 3 process, 2 process has mmaped file with MAP_SHARE=
D setting and one has mapped file with MAP_PRIVATE setting.
>>> I have all 3 processes in background and checks RSS/PSS value from user=
 space utility (utility over cat /proc/pid/smaps)
>>> Before OOM, below is the consumed memory status for these 3 process (al=
l processes run with oom_score_adj =3D 0)
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>>> Comm : 1prg,  Pid : 213 (values in kB)
>>>                       Rss     Shared      Private          Pss
>>>   Process :  375764    194596    181168     278460
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>>> Comm : 3prg,  Pid : 217 (values in kB)
>>>                       Rss    Shared       Private         Pss
>>>   Process :  305760          32     305728    305738
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>>> Comm : 2prg,  Pid : 218 (values in kB)
>>>                       Rss      Shared       Private         Pss
>>>   Process :  389980     194596     195384    292676
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>>>
>>> Thus as per present code design, first it would select process [2prg : =
218] as bulkiest process as its RSS value is highest to kill. But if we kil=
l this process then only ~195MB would be free as compare to expected ~389MB=
.
>>> Thus identifying the task based on RSS value is not accurate design and=
 killing that identified process didn=E2=80=99t release expected memory bac=
k to system.
>>>
>>> We need to calculate victim task based on PSS instead of RSS as PSS val=
ue calculates as
>>> PSS value =3D [Private (Dirty/Clean)] + [Shared (Dirty/Clean) / no. of =
shared task]
>>> For above use-case scenario also, it can be checked that process [3prg =
: 217] is having largest PSS value and by killing this process we can gain =
maximum memory (~305MB) as compare to killing process identified based on R=
SS value.
>>>
>>> --
>>> Regards,
>>> Yogesh Gaur.
>
>>
>>Great,
>>
>> in fact, i also encounter this scenario,
>> I  use USS (page map counter =3D=3D 1) pages
>> to decide which process should be killed,
>> seems have the same result as you use PSS,
>> but PSS is better , it also consider shared pages,
>> in case some process have large shared pages mapping
>> but little Private page mapping
>>
>> BRs,
>> Yalin
>
> I have made patch which identifies bulkiest task on basis of PSS value. P=
lease check below patch.
> This patch is correcting the way victim task gets identified in oom condi=
tion.
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> From 1c3d7f552f696bdbc0126c8e23beabedbd80e423 Mon Sep 17 00:00:00 2001
> From: Yogesh Gaur <yn.gaur@samsung.com>
> Date: Thu, 7 May 2015 01:52:13 +0530
> Subject: [PATCH] oom: find victim task based on pss
>
> This patch is identifying bulkiest task to kill by OOM on the basis of PS=
S value
> instead of present RSS values.
> There can be scenario where task with highest RSS counter is consuming lo=
t of shared
> memory and killing that task didn't release expected amount of memory to =
system.
> PSS value =3D [Private (Dirty/Clean)] + [Shared (Dirty/Clean) / no. of sh=
ared task]
> RSS value =3D [Private (Dirty/Clean)] + [Shared (Dirty/Clean)]
> Thus, using PSS value instead of RSS value as PSS value closely matches w=
ith actual
> memory usage by the task.
> This patch is using smaps_pte_range() interface defined in CONFIG_PROC_PA=
GE_MONITOR.
> For case when CONFIG_PROC_PAGE_MONITOR disabled, this simply returns RSS =
value count.
>
> Signed-off-by: Yogesh Gaur <yn.gaur@samsung.com>
> Signed-off-by: Amit Arora <amit.arora@samsung.com>
> Reviewed-by: Ajeet Yadav <ajeet.y@samsung.com>
> ---
>  fs/proc/task_mmu.c |   47 ++++++++++++++++++++++++++++++++++++++++++++++=
+
>  include/linux/mm.h |    9 +++++++++
>  mm/oom_kill.c      |    9 +++++++--
>  3 files changed, 63 insertions(+), 2 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 956b75d..dd962ff 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -964,6 +964,53 @@ struct pagemapread {
>         bool v2;
>  };
>
> +/**
> + * get_mm_pss - function to determine PSS count of pages being used for =
proc p
> + * PSS value=3D[Private(Dirty/Clean)] + [Shared(Dirty/Clean)/no. of shar=
ed task]
> + * @p: task struct of which task we should calculate
> + * @mm: mm struct of the task.
> + *
> + * This function needs to be called under task_lock for calling task 'p'=
.
> + */
> +long get_mm_pss(struct task_struct *p, struct mm_struct *mm)
> +{
> +       long pss =3D 0;
> +       struct vm_area_struct *vma =3D NULL;
> +       struct mem_size_stats mss;
> +       struct mm_walk smaps_walk =3D {
> +               .pmd_entry =3D smaps_pte_range,
> +               .private =3D &mss,
> +       };
> +
> +       if (mm =3D=3D NULL)
> +               return 0;
> +
> +       /* task_lock held in oom_badness */
> +       smaps_walk.mm =3D mm;
> +
> +       if (!down_read_trylock(&mm->mmap_sem)) {
> +               pr_warn("Skipping task:%s\n", p->comm);
> +           return 0;
> +       }
> +
> +       vma =3D mm->mmap;
> +       if (!vma) {
> +               up_read(&mm->mmap_sem);
> +               return 0;
> +       }
> +
> +       while (vma) {
> +               memset(&mss, 0, sizeof(struct mem_size_stats));
> +               walk_page_vma(vma, &smaps_walk);
> +               pss +=3D (unsigned long) (mss.pss >> (12 + PSS_SHIFT)); /=
*PSS in PAGE */
> +
> +               /* Check next vma in list */
> +               vma =3D vma->vm_next;
> +       }
> +       up_read(&mm->mmap_sem);
> +       return pss;
> +}
> +
>  #define PAGEMAP_WALK_SIZE      (PMD_SIZE)
>  #define PAGEMAP_WALK_MASK      (PMD_MASK)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 47a9392..b6bb521 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1423,6 +1423,15 @@ static inline void setmax_mm_hiwater_rss(unsigned =
long *maxrss,
>                 *maxrss =3D hiwater_rss;
>  }
>
> +#ifdef CONFIG_PROC_PAGE_MONITOR
> +long get_mm_pss(struct task_struct *p, struct mm_struct *mm);
> +#else
> +static inline long get_mm_pss(struct task_struct *p, struct mm_struct *m=
m)
> +{
> +       return 0;
> +}
> +#endif
> +
>  #if defined(SPLIT_RSS_COUNTING)
>  void sync_mm_rss(struct mm_struct *mm);
>  #else
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 642f38c..537eb4c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -151,6 +151,7 @@ unsigned long oom_badness(struct task_struct *p, stru=
ct mem_cgroup *memcg,
>  {
>         long points;
>         long adj;
> +       long pss =3D 0;
>
>         if (oom_unkillable_task(p, memcg, nodemask))
>                 return 0;
> @@ -167,9 +168,13 @@ unsigned long oom_badness(struct task_struct *p, str=
uct mem_cgroup *memcg,
>
>         /*
>          * The baseline for the badness score is the proportion of RAM th=
at each
> -        * task's rss, pagetable and swap space use.
> +        * task's pss, pagetable and swap space use.
>          */
> -       points =3D get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)=
 +
> +       pss =3D get_mm_pss(p, p->mm);
> +       if (pss =3D=3D 0) /* make pss equals to rss, pseudo-pss */
> +               pss =3D get_mm_rss(p->mm);
> +
> +       points =3D pss + get_mm_counter(p->mm, MM_SWAPENTS) +
>                 atomic_long_read(&p->mm->nr_ptes) + mm_nr_pmds(p->mm);
>         task_unlock(p);
>
> --
> 1.7.1
>
>
> --
> BRs
> Yogesh Gaur.
The logic seems ok ,
but i feel the code footprint is too large than the original method,
maybe have some performance problems,
i have add linux-mm mail list for mm expert to review .

BRs
Yalin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
