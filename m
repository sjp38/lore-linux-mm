Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69A8B6B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 01:23:57 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o23-v6so6973950pll.12
        for <linux-mm@kvack.org>; Sun, 27 May 2018 22:23:57 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v11-v6si20497891pgt.114.2018.05.27.22.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 May 2018 22:23:55 -0700 (PDT)
From: "Song, HaiyanX" <haiyanx.song@intel.com>
Subject: RE: [PATCH v11 00/26] Speculative page faults
Date: Mon, 28 May 2018 05:23:48 +0000
Message-ID: <9FE19350E8A7EE45B64D8D63D368C8966B834B67@SHSMSX101.ccr.corp.intel.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
In-Reply-To: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "kirill@shutemov.name" <kirill@shutemov.name>, "ak@linux.intel.com" <ak@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "jack@suse.cz" <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "paulus@samba.org" <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "sergey.senozhatsky.work@gmail.com" <sergey.senozhatsky.work@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, "Wang, Kemi" <kemi.wang@intel.com>, Daniel
 Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit
 Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "haren@linux.vnet.ibm.com" <haren@linux.vnet.ibm.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "x86@kernel.org" <x86@kernel.org>

=0A=
Some regression and improvements is found by LKP-tools(linux kernel perform=
ance) on V9 patch series=0A=
tested on Intel 4s Skylake platform.=0A=
=0A=
The regression result is sorted by the metric will-it-scale.per_thread_ops.=
=0A=
Branch: Laurent-Dufour/Speculative-page-faults/20180316-151833 (V9 patch se=
ries)=0A=
Commit id:=0A=
    base commit: d55f34411b1b126429a823d06c3124c16283231f=0A=
    head commit: 0355322b3577eeab7669066df42c550a56801110=0A=
Benchmark suite: will-it-scale=0A=
Download link:=0A=
https://github.com/antonblanchard/will-it-scale/tree/master/tests=0A=
Metrics:=0A=
    will-it-scale.per_process_ops=3Dprocesses/nr_cpu=0A=
    will-it-scale.per_thread_ops=3Dthreads/nr_cpu=0A=
test box: lkp-skl-4sp1(nr_cpu=3D192,memory=3D768G)=0A=
THP: enable / disable=0A=
nr_task: 100%=0A=
=0A=
1. Regressions:=0A=
a) THP enabled:=0A=
testcase                        base            change          head       =
metric=0A=
page_fault3/ enable THP         10092           -17.5%          8323       =
will-it-scale.per_thread_ops=0A=
page_fault2/ enable THP          8300           -17.2%          6869       =
will-it-scale.per_thread_ops=0A=
brk1/ enable THP                  957.67         -7.6%           885       =
will-it-scale.per_thread_ops=0A=
page_fault3/ enable THP        172821            -5.3%        163692       =
will-it-scale.per_process_ops=0A=
signal1/ enable THP              9125            -3.2%          8834       =
will-it-scale.per_process_ops=0A=
=0A=
b) THP disabled:=0A=
testcase                        base            change          head       =
metric=0A=
page_fault3/ disable THP        10107           -19.1%          8180       =
will-it-scale.per_thread_ops=0A=
page_fault2/ disable THP         8432           -17.8%          6931       =
will-it-scale.per_thread_ops=0A=
context_switch1/ disable THP   215389            -6.8%        200776       =
will-it-scale.per_thread_ops=0A=
brk1/ disable THP                 939.67         -6.6%           877.33    =
will-it-scale.per_thread_ops=0A=
page_fault3/ disable THP       173145            -4.7%        165064       =
will-it-scale.per_process_ops=0A=
signal1/ disable THP             9162            -3.9%          8802       =
will-it-scale.per_process_ops=0A=
=0A=
2. Improvements:=0A=
a) THP enabled:=0A=
testcase                        base            change          head       =
metric=0A=
malloc1/ enable THP               66.33        +469.8%           383.67    =
will-it-scale.per_thread_ops=0A=
writeseek3/ enable THP          2531             +4.5%          2646       =
will-it-scale.per_thread_ops=0A=
signal1/ enable THP              989.33          +2.8%          1016       =
will-it-scale.per_thread_ops=0A=
=0A=
b) THP disabled:=0A=
testcase                        base            change          head       =
metric=0A=
malloc1/ disable THP              90.33        +417.3%           467.33    =
will-it-scale.per_thread_ops=0A=
read2/ disable THP             58934            +39.2%         82060       =
will-it-scale.per_thread_ops=0A=
page_fault1/ disable THP        8607            +36.4%         11736       =
will-it-scale.per_thread_ops=0A=
read1/ disable THP            314063            +12.7%        353934       =
will-it-scale.per_thread_ops=0A=
writeseek3/ disable THP         2452            +12.5%          2759       =
will-it-scale.per_thread_ops=0A=
signal1/ disable THP             971.33          +5.5%          1024       =
will-it-scale.per_thread_ops=0A=
=0A=
Notes: for above values in column "change", the higher value means that the=
 related testcase result=0A=
on head commit is better than that on base commit for this benchmark.=0A=
=0A=
=0A=
Best regards=0A=
Haiyan Song=0A=
=0A=
________________________________________=0A=
From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of Laur=
ent Dufour [ldufour@linux.vnet.ibm.com]=0A=
Sent: Thursday, May 17, 2018 7:06 PM=0A=
To: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org; kir=
ill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz; Mat=
thew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.com; =
benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas Glei=
xner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; sergey.s=
enozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, Kemi=
; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minchan K=
im; Punit Agrawal; vinayak menon; Yang Shi=0A=
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; haren@linux.vnet.ibm.=
com; npiggin@gmail.com; bsingharora@gmail.com; paulmck@linux.vnet.ibm.com; =
Tim Chen; linuxppc-dev@lists.ozlabs.org; x86@kernel.org=0A=
Subject: [PATCH v11 00/26] Speculative page faults=0A=
=0A=
This is a port on kernel 4.17 of the work done by Peter Zijlstra to handle=
=0A=
page fault without holding the mm semaphore [1].=0A=
=0A=
The idea is to try to handle user space page faults without holding the=0A=
mmap_sem. This should allow better concurrency for massively threaded=0A=
process since the page fault handler will not wait for other threads memory=
=0A=
layout change to be done, assuming that this change is done in another part=
=0A=
of the process's memory space. This type page fault is named speculative=0A=
page fault. If the speculative page fault fails because of a concurrency is=
=0A=
detected or because underlying PMD or PTE tables are not yet allocating, it=
=0A=
is failing its processing and a classic page fault is then tried.=0A=
=0A=
The speculative page fault (SPF) has to look for the VMA matching the fault=
=0A=
address without holding the mmap_sem, this is done by introducing a rwlock=
=0A=
which protects the access to the mm_rb tree. Previously this was done using=
=0A=
SRCU but it was introducing a lot of scheduling to process the VMA's=0A=
freeing operation which was hitting the performance by 20% as reported by=
=0A=
Kemi Wang [2]. Using a rwlock to protect access to the mm_rb tree is=0A=
limiting the locking contention to these operations which are expected to=
=0A=
be in a O(log n) order. In addition to ensure that the VMA is not freed in=
=0A=
our back a reference count is added and 2 services (get_vma() and=0A=
put_vma()) are introduced to handle the reference count. Once a VMA is=0A=
fetched from the RB tree using get_vma(), it must be later freed using=0A=
put_vma(). I can't see anymore the overhead I got while will-it-scale=0A=
benchmark anymore.=0A=
=0A=
The VMA's attributes checked during the speculative page fault processing=
=0A=
have to be protected against parallel changes. This is done by using a per=
=0A=
VMA sequence lock. This sequence lock allows the speculative page fault=0A=
handler to fast check for parallel changes in progress and to abort the=0A=
speculative page fault in that case.=0A=
=0A=
Once the VMA has been found, the speculative page fault handler would check=
=0A=
for the VMA's attributes to verify that the page fault has to be handled=0A=
correctly or not. Thus, the VMA is protected through a sequence lock which=
=0A=
allows fast detection of concurrent VMA changes. If such a change is=0A=
detected, the speculative page fault is aborted and a *classic* page fault=
=0A=
is tried.  VMA sequence lockings are added when VMA attributes which are=0A=
checked during the page fault are modified.=0A=
=0A=
When the PTE is fetched, the VMA is checked to see if it has been changed,=
=0A=
so once the page table is locked, the VMA is valid, so any other changes=0A=
leading to touching this PTE will need to lock the page table, so no=0A=
parallel change is possible at this time.=0A=
=0A=
The locking of the PTE is done with interrupts disabled, this allows=0A=
checking for the PMD to ensure that there is not an ongoing collapsing=0A=
operation. Since khugepaged is firstly set the PMD to pmd_none and then is=
=0A=
waiting for the other CPU to have caught the IPI interrupt, if the pmd is=
=0A=
valid at the time the PTE is locked, we have the guarantee that the=0A=
collapsing operation will have to wait on the PTE lock to move forward.=0A=
This allows the SPF handler to map the PTE safely. If the PMD value is=0A=
different from the one recorded at the beginning of the SPF operation, the=
=0A=
classic page fault handler will be called to handle the operation while=0A=
holding the mmap_sem. As the PTE lock is done with the interrupts disabled,=
=0A=
the lock is done using spin_trylock() to avoid dead lock when handling a=0A=
page fault while a TLB invalidate is requested by another CPU holding the=
=0A=
PTE.=0A=
=0A=
In pseudo code, this could be seen as:=0A=
    speculative_page_fault()=0A=
    {=0A=
            vma =3D get_vma()=0A=
            check vma sequence count=0A=
            check vma's support=0A=
            disable interrupt=0A=
                  check pgd,p4d,...,pte=0A=
                  save pmd and pte in vmf=0A=
                  save vma sequence counter in vmf=0A=
            enable interrupt=0A=
            check vma sequence count=0A=
            handle_pte_fault(vma)=0A=
                    ..=0A=
                    page =3D alloc_page()=0A=
                    pte_map_lock()=0A=
                            disable interrupt=0A=
                                    abort if sequence counter has changed=
=0A=
                                    abort if pmd or pte has changed=0A=
                                    pte map and lock=0A=
                            enable interrupt=0A=
                    if abort=0A=
                       free page=0A=
                       abort=0A=
                    ...=0A=
    }=0A=
=0A=
    arch_fault_handler()=0A=
    {=0A=
            if (speculative_page_fault(&vma))=0A=
               goto done=0A=
    again:=0A=
            lock(mmap_sem)=0A=
            vma =3D find_vma();=0A=
            handle_pte_fault(vma);=0A=
            if retry=0A=
               unlock(mmap_sem)=0A=
               goto again;=0A=
    done:=0A=
            handle fault error=0A=
    }=0A=
=0A=
Support for THP is not done because when checking for the PMD, we can be=0A=
confused by an in progress collapsing operation done by khugepaged. The=0A=
issue is that pmd_none() could be true either if the PMD is not already=0A=
populated or if the underlying PTE are in the way to be collapsed. So we=0A=
cannot safely allocate a PMD if pmd_none() is true.=0A=
=0A=
This series add a new software performance event named 'speculative-faults'=
=0A=
or 'spf'. It counts the number of successful page fault event handled=0A=
speculatively. When recording 'faults,spf' events, the faults one is=0A=
counting the total number of page fault events while 'spf' is only counting=
=0A=
the part of the faults processed speculatively.=0A=
=0A=
There are some trace events introduced by this series. They allow=0A=
identifying why the page faults were not processed speculatively. This=0A=
doesn't take in account the faults generated by a monothreaded process=0A=
which directly processed while holding the mmap_sem. This trace events are=
=0A=
grouped in a system named 'pagefault', they are:=0A=
 - pagefault:spf_vma_changed : if the VMA has been changed in our back=0A=
 - pagefault:spf_vma_noanon : the vma->anon_vma field was not yet set.=0A=
 - pagefault:spf_vma_notsup : the VMA's type is not supported=0A=
 - pagefault:spf_vma_access : the VMA's access right are not respected=0A=
 - pagefault:spf_pmd_changed : the upper PMD pointer has changed in our=0A=
   back.=0A=
=0A=
To record all the related events, the easier is to run perf with the=0A=
following arguments :=0A=
$ perf stat -e 'faults,spf,pagefault:*' <command>=0A=
=0A=
There is also a dedicated vmstat counter showing the number of successful=
=0A=
page fault handled speculatively. I can be seen this way:=0A=
$ grep speculative_pgfault /proc/vmstat=0A=
=0A=
This series builds on top of v4.16-mmotm-2018-04-13-17-28 and is functional=
=0A=
on x86, PowerPC and arm64.=0A=
=0A=
---------------------=0A=
Real Workload results=0A=
=0A=
As mentioned in previous email, we did non official runs using a "popular=
=0A=
in memory multithreaded database product" on 176 cores SMT8 Power system=0A=
which showed a 30% improvements in the number of transaction processed per=
=0A=
second. This run has been done on the v6 series, but changes introduced in=
=0A=
this new version should not impact the performance boost seen.=0A=
=0A=
Here are the perf data captured during 2 of these runs on top of the v8=0A=
series:=0A=
                vanilla         spf=0A=
faults          89.418          101.364         +13%=0A=
spf                n/a           97.989=0A=
=0A=
With the SPF kernel, most of the page fault were processed in a speculative=
=0A=
way.=0A=
=0A=
Ganesh Mahendran had backported the series on top of a 4.9 kernel and gave=
=0A=
it a try on an android device. He reported that the application launch time=
=0A=
was improved in average by 6%, and for large applications (~100 threads) by=
=0A=
20%.=0A=
=0A=
Here are the launch time Ganesh mesured on Android 8.0 on top of a Qcom=0A=
MSM845 (8 cores) with 6GB (the less is better):=0A=
=0A=
Application                             4.9     4.9+spf delta=0A=
com.tencent.mm                          416     389     -7%=0A=
com.eg.android.AlipayGphone             1135    986     -13%=0A=
com.tencent.mtt                         455     454     0%=0A=
com.qqgame.hlddz                        1497    1409    -6%=0A=
com.autonavi.minimap                    711     701     -1%=0A=
com.tencent.tmgp.sgame                  788     748     -5%=0A=
com.immomo.momo                         501     487     -3%=0A=
com.tencent.peng                        2145    2112    -2%=0A=
com.smile.gifmaker                      491     461     -6%=0A=
com.baidu.BaiduMap                      479     366     -23%=0A=
com.taobao.taobao                       1341    1198    -11%=0A=
com.baidu.searchbox                     333     314     -6%=0A=
com.tencent.mobileqq                    394     384     -3%=0A=
com.sina.weibo                          907     906     0%=0A=
com.youku.phone                         816     731     -11%=0A=
com.happyelements.AndroidAnimal.qq      763     717     -6%=0A=
com.UCMobile                            415     411     -1%=0A=
com.tencent.tmgp.ak                     1464    1431    -2%=0A=
com.tencent.qqmusic                     336     329     -2%=0A=
com.sankuai.meituan                     1661    1302    -22%=0A=
com.netease.cloudmusic                  1193    1200    1%=0A=
air.tv.douyu.android                    4257    4152    -2%=0A=
=0A=
------------------=0A=
Benchmarks results=0A=
=0A=
Base kernel is v4.17.0-rc4-mm1=0A=
SPF is BASE + this series=0A=
=0A=
Kernbench:=0A=
----------=0A=
Here are the results on a 16 CPUs X86 guest using kernbench on a 4.15=0A=
kernel (kernel is build 5 times):=0A=
=0A=
Average Half load -j 8=0A=
                 Run    (std deviation)=0A=
                 BASE                   SPF=0A=
Elapsed Time     1448.65 (5.72312)      1455.84 (4.84951)       0.50%=0A=
User    Time     10135.4 (30.3699)      10148.8 (31.1252)       0.13%=0A=
System  Time     900.47  (2.81131)      923.28  (7.52779)       2.53%=0A=
Percent CPU      761.4   (1.14018)      760.2   (0.447214)      -0.16%=0A=
Context Switches 85380   (3419.52)      84748   (1904.44)       -0.74%=0A=
Sleeps           105064  (1240.96)      105074  (337.612)       0.01%=0A=
=0A=
Average Optimal load -j 16=0A=
                 Run    (std deviation)=0A=
                 BASE                   SPF=0A=
Elapsed Time     920.528 (10.1212)      927.404 (8.91789)       0.75%=0A=
User    Time     11064.8 (981.142)      11085   (990.897)       0.18%=0A=
System  Time     979.904 (84.0615)      1001.14 (82.5523)       2.17%=0A=
Percent CPU      1089.5  (345.894)      1086.1  (343.545)       -0.31%=0A=
Context Switches 159488  (78156.4)      158223  (77472.1)       -0.79%=0A=
Sleeps           110566  (5877.49)      110388  (5617.75)       -0.16%=0A=
=0A=
=0A=
During a run on the SPF, perf events were captured:=0A=
 Performance counter stats for '../kernbench -M':=0A=
         526743764      faults=0A=
               210      spf=0A=
                 3      pagefault:spf_vma_changed=0A=
                 0      pagefault:spf_vma_noanon=0A=
              2278      pagefault:spf_vma_notsup=0A=
                 0      pagefault:spf_vma_access=0A=
                 0      pagefault:spf_pmd_changed=0A=
=0A=
Very few speculative page faults were recorded as most of the processes=0A=
involved are monothreaded (sounds that on this architecture some threads=0A=
were created during the kernel build processing).=0A=
=0A=
Here are the kerbench results on a 80 CPUs Power8 system:=0A=
=0A=
Average Half load -j 40=0A=
                 Run    (std deviation)=0A=
                 BASE                   SPF=0A=
Elapsed Time     117.152 (0.774642)     117.166 (0.476057)      0.01%=0A=
User    Time     4478.52 (24.7688)      4479.76 (9.08555)       0.03%=0A=
System  Time     131.104 (0.720056)     134.04  (0.708414)      2.24%=0A=
Percent CPU      3934    (19.7104)      3937.2  (19.0184)       0.08%=0A=
Context Switches 92125.4 (576.787)      92581.6 (198.622)       0.50%=0A=
Sleeps           317923  (652.499)      318469  (1255.59)       0.17%=0A=
=0A=
Average Optimal load -j 80=0A=
                 Run    (std deviation)=0A=
                 BASE                   SPF=0A=
Elapsed Time     107.73  (0.632416)     107.31  (0.584936)      -0.39%=0A=
User    Time     5869.86 (1466.72)      5871.71 (1467.27)       0.03%=0A=
System  Time     153.728 (23.8573)      157.153 (24.3704)       2.23%=0A=
Percent CPU      5418.6  (1565.17)      5436.7  (1580.91)       0.33%=0A=
Context Switches 223861  (138865)       225032  (139632)        0.52%=0A=
Sleeps           330529  (13495.1)      332001  (14746.2)       0.45%=0A=
=0A=
During a run on the SPF, perf events were captured:=0A=
 Performance counter stats for '../kernbench -M':=0A=
         116730856      faults=0A=
                 0      spf=0A=
                 3      pagefault:spf_vma_changed=0A=
                 0      pagefault:spf_vma_noanon=0A=
               476      pagefault:spf_vma_notsup=0A=
                 0      pagefault:spf_vma_access=0A=
                 0      pagefault:spf_pmd_changed=0A=
=0A=
Most of the processes involved are monothreaded so SPF is not activated but=
=0A=
there is no impact on the performance.=0A=
=0A=
Ebizzy:=0A=
-------=0A=
The test is counting the number of records per second it can manage, the=0A=
higher is the best. I run it like this 'ebizzy -mTt <nrcpus>'. To get=0A=
consistent result I repeated the test 100 times and measure the average=0A=
result. The number is the record processes per second, the higher is the=0A=
best.=0A=
=0A=
                BASE            SPF             delta=0A=
16 CPUs x86 VM  742.57          1490.24         100.69%=0A=
80 CPUs P8 node 13105.4         24174.23        84.46%=0A=
=0A=
Here are the performance counter read during a run on a 16 CPUs x86 VM:=0A=
 Performance counter stats for './ebizzy -mTt 16':=0A=
           1706379      faults=0A=
           1674599      spf=0A=
             30588      pagefault:spf_vma_changed=0A=
                 0      pagefault:spf_vma_noanon=0A=
               363      pagefault:spf_vma_notsup=0A=
                 0      pagefault:spf_vma_access=0A=
                 0      pagefault:spf_pmd_changed=0A=
=0A=
And the ones captured during a run on a 80 CPUs Power node:=0A=
 Performance counter stats for './ebizzy -mTt 80':=0A=
           1874773      faults=0A=
           1461153      spf=0A=
            413293      pagefault:spf_vma_changed=0A=
                 0      pagefault:spf_vma_noanon=0A=
               200      pagefault:spf_vma_notsup=0A=
                 0      pagefault:spf_vma_access=0A=
                 0      pagefault:spf_pmd_changed=0A=
=0A=
In ebizzy's case most of the page fault were handled in a speculative way,=
=0A=
leading the ebizzy performance boost.=0A=
=0A=
------------------=0A=
Changes since v10 (https://lkml.org/lkml/2018/4/17/572):=0A=
 - Accounted for all review feedbacks from Punit Agrawal, Ganesh Mahendran=
=0A=
   and Minchan Kim, hopefully.=0A=
 - Remove unneeded check on CONFIG_SPECULATIVE_PAGE_FAULT in=0A=
   __do_page_fault().=0A=
 - Loop in pte_spinlock() and pte_map_lock() when pte try lock fails=0A=
   instead=0A=
   of aborting the speculative page fault handling. Dropping the now=0A=
useless=0A=
   trace event pagefault:spf_pte_lock.=0A=
 - No more try to reuse the fetched VMA during the speculative page fault=
=0A=
   handling when retrying is needed. This adds a lot of complexity and=0A=
   additional tests done didn't show a significant performance improvement.=
=0A=
 - Convert IS_ENABLED(CONFIG_NUMA) back to #ifdef due to build error.=0A=
=0A=
[1] http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-spec=
ulative-page-faults-tt965642.html#none=0A=
[2] https://patchwork.kernel.org/patch/9999687/=0A=
=0A=
=0A=
Laurent Dufour (20):=0A=
  mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT=0A=
  x86/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
  powerpc/mm: set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
  mm: introduce pte_spinlock for FAULT_FLAG_SPECULATIVE=0A=
  mm: make pte_unmap_same compatible with SPF=0A=
  mm: introduce INIT_VMA()=0A=
  mm: protect VMA modifications using VMA sequence count=0A=
  mm: protect mremap() against SPF hanlder=0A=
  mm: protect SPF handler against anon_vma changes=0A=
  mm: cache some VMA fields in the vm_fault structure=0A=
  mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()=0A=
  mm: introduce __lru_cache_add_active_or_unevictable=0A=
  mm: introduce __vm_normal_page()=0A=
  mm: introduce __page_add_new_anon_rmap()=0A=
  mm: protect mm_rb tree with a rwlock=0A=
  mm: adding speculative page fault failure trace events=0A=
  perf: add a speculative page fault sw event=0A=
  perf tools: add support for the SPF perf event=0A=
  mm: add speculative page fault vmstats=0A=
  powerpc/mm: add speculative page fault=0A=
=0A=
Mahendran Ganesh (2):=0A=
  arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT=0A=
  arm64/mm: add speculative page fault=0A=
=0A=
Peter Zijlstra (4):=0A=
  mm: prepare for FAULT_FLAG_SPECULATIVE=0A=
  mm: VMA sequence count=0A=
  mm: provide speculative fault infrastructure=0A=
  x86/mm: add speculative pagefault handling=0A=
=0A=
 arch/arm64/Kconfig                    |   1 +=0A=
 arch/arm64/mm/fault.c                 |  12 +=0A=
 arch/powerpc/Kconfig                  |   1 +=0A=
 arch/powerpc/mm/fault.c               |  16 +=0A=
 arch/x86/Kconfig                      |   1 +=0A=
 arch/x86/mm/fault.c                   |  27 +-=0A=
 fs/exec.c                             |   2 +-=0A=
 fs/proc/task_mmu.c                    |   5 +-=0A=
 fs/userfaultfd.c                      |  17 +-=0A=
 include/linux/hugetlb_inline.h        |   2 +-=0A=
 include/linux/migrate.h               |   4 +-=0A=
 include/linux/mm.h                    | 136 +++++++-=0A=
 include/linux/mm_types.h              |   7 +=0A=
 include/linux/pagemap.h               |   4 +-=0A=
 include/linux/rmap.h                  |  12 +-=0A=
 include/linux/swap.h                  |  10 +-=0A=
 include/linux/vm_event_item.h         |   3 +=0A=
 include/trace/events/pagefault.h      |  80 +++++=0A=
 include/uapi/linux/perf_event.h       |   1 +=0A=
 kernel/fork.c                         |   5 +-=0A=
 mm/Kconfig                            |  22 ++=0A=
 mm/huge_memory.c                      |   6 +-=0A=
 mm/hugetlb.c                          |   2 +=0A=
 mm/init-mm.c                          |   3 +=0A=
 mm/internal.h                         |  20 ++=0A=
 mm/khugepaged.c                       |   5 +=0A=
 mm/madvise.c                          |   6 +-=0A=
 mm/memory.c                           | 612 +++++++++++++++++++++++++++++-=
----=0A=
 mm/mempolicy.c                        |  51 ++-=0A=
 mm/migrate.c                          |   6 +-=0A=
 mm/mlock.c                            |  13 +-=0A=
 mm/mmap.c                             | 229 ++++++++++---=0A=
 mm/mprotect.c                         |   4 +-=0A=
 mm/mremap.c                           |  13 +=0A=
 mm/nommu.c                            |   2 +-=0A=
 mm/rmap.c                             |   5 +-=0A=
 mm/swap.c                             |   6 +-=0A=
 mm/swap_state.c                       |   8 +-=0A=
 mm/vmstat.c                           |   5 +-=0A=
 tools/include/uapi/linux/perf_event.h |   1 +=0A=
 tools/perf/util/evsel.c               |   1 +=0A=
 tools/perf/util/parse-events.c        |   4 +=0A=
 tools/perf/util/parse-events.l        |   1 +=0A=
 tools/perf/util/python.c              |   1 +=0A=
 44 files changed, 1161 insertions(+), 211 deletions(-)=0A=
 create mode 100644 include/trace/events/pagefault.h=0A=
=0A=
--=0A=
2.7.4=0A=
=0A=
