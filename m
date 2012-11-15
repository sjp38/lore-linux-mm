Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id BA84B6B004D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 13:54:04 -0500 (EST)
Message-ID: <50A53A00.5060904@redhat.com>
Date: Thu, 15 Nov 2012 13:52:48 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive affinity"
References: <20121112160451.189715188@chello.nl> <20121112184833.GA17503@gmail.com> <20121115100805.GS8218@suse.de>
In-Reply-To: <20121115100805.GS8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>

On 11/15/2012 05:08 AM, Mel Gorman wrote:
> On Mon, Nov 12, 2012 at 07:48:33PM +0100, Ingo Molnar wrote:
>> Here are some preliminary performance figures, comparing the
>> vanilla kernel against the CONFIG_SCHED_NUMA=y kernel.
>>
>> Java SPEC benchmark, running on a 4 node, 64 GB, 32-way server
>> system (higher numbers are better):
>
> Ok, I used a 4-node, 64G, 48-way server system. We have different CPUs
> but the same number of nodes. In case it makes a difference each of my
> machines nodes are the same size.

Mel, do you have info on exactly what model system you
were running these tests on?

Obviously your results are very different from the ones
that Ingo saw. It would be most helpful if we could find
a similar system in one of the Red Hat labs, so Ingo can
play around with it and see what's going on :)

    ... on Ingo's system:

>> Beyond the +26.7% performance improvement in throughput, the
>> standard deviation of the results is much lower as well with
>> NUMA scheduling enabled, by about an order of magnitude.

   ... on Mel's system:

> I did not see the same results. I used 3.7-rc4 as a baseline as it's what
> I'm developing against currently. For your patches I pulled tip/sched/core
> and then applied the patches you posted to the mailing list on top. It
> means my tree looks different to yours but it was necessary if I was going
> to do a like-with-like comparison. I also rebased Andrea'a autonuma28fast
> branch from his git tree onto 3.7-rc4 (some mess, but nothing very serious).
>
> As before, I'm cutting this report short
>
> SPECJBB BOPS
>                            3.7.0                 3.7.0                 3.7.0
>                  rc4-stats-v2r34    rc4-schednuma-v2r3  rc4-autonuma-v28fast
> Mean   1      25034.25 (  0.00%)     20598.50 (-17.72%)     25192.25 (  0.63%)
> Mean   2      53176.00 (  0.00%)     43906.50 (-17.43%)     55508.25 (  4.39%)
> Mean   3      77350.50 (  0.00%)     60342.75 (-21.99%)     82122.50 (  6.17%)
> Mean   4      99919.50 (  0.00%)     80781.75 (-19.15%)    107233.25 (  7.32%)
> Mean   5     119797.00 (  0.00%)     97870.00 (-18.30%)    131016.00 (  9.37%)
> Mean   6     135858.00 (  0.00%)    123912.50 ( -8.79%)    152444.75 ( 12.21%)
> Mean   7     136074.00 (  0.00%)    126574.25 ( -6.98%)    157372.75 ( 15.65%)
> Mean   8     132426.25 (  0.00%)    121766.00 ( -8.05%)    161655.25 ( 22.07%)
> Mean   9     129432.75 (  0.00%)    114224.25 (-11.75%)    160530.50 ( 24.03%)
> Mean   10    118399.75 (  0.00%)    109040.50 ( -7.90%)    158692.00 ( 34.03%)
> Mean   11    119604.00 (  0.00%)    105566.50 (-11.74%)    154462.00 ( 29.14%)
> Mean   12    112742.25 (  0.00%)    101728.75 ( -9.77%)    149546.00 ( 32.64%)
> Mean   13    109480.75 (  0.00%)    103737.50 ( -5.25%)    144929.25 ( 32.38%)
> Mean   14    109724.00 (  0.00%)    103516.00 ( -5.66%)    143804.50 ( 31.06%)
> Mean   15    109111.75 (  0.00%)    100817.00 ( -7.60%)    141878.00 ( 30.03%)
> Mean   16    105385.75 (  0.00%)     99327.25 ( -5.75%)    140156.75 ( 32.99%)
> Mean   17    101903.50 (  0.00%)     96464.50 ( -5.34%)    138402.00 ( 35.82%)
> Mean   18    103632.50 (  0.00%)     95632.50 ( -7.72%)    137781.50 ( 32.95%)
> Stddev 1       1195.76 (  0.00%)       358.07 ( 70.06%)       861.97 ( 27.91%)
> Stddev 2        883.39 (  0.00%)      1203.29 (-36.21%)       855.08 (  3.20%)
> Stddev 3        997.25 (  0.00%)      3755.67 (-276.60%)       545.50 ( 45.30%)
> Stddev 4       1115.16 (  0.00%)      6390.65 (-473.07%)      1183.49 ( -6.13%)
> Stddev 5       1367.09 (  0.00%)      9710.70 (-610.32%)      1022.09 ( 25.24%)
> Stddev 6       1125.22 (  0.00%)      1097.83 (  2.43%)      1013.52 (  9.93%)
> Stddev 7       3211.72 (  0.00%)      1533.62 ( 52.25%)       512.61 ( 84.04%)
> Stddev 8       4194.96 (  0.00%)      1518.26 ( 63.81%)       493.64 ( 88.23%)
> Stddev 9       6175.10 (  0.00%)      2648.75 ( 57.11%)      2109.83 ( 65.83%)
> Stddev 10      4754.87 (  0.00%)      1941.47 ( 59.17%)      2948.98 ( 37.98%)
> Stddev 11      2706.18 (  0.00%)      1247.95 ( 53.89%)      5907.16 (-118.28%)
> Stddev 12      3607.76 (  0.00%)       663.63 ( 81.61%)      9063.28 (-151.22%)
> Stddev 13      2771.67 (  0.00%)      1447.87 ( 47.76%)      8716.51 (-214.49%)
> Stddev 14      2522.18 (  0.00%)      1510.28 ( 40.12%)      9286.98 (-268.21%)
> Stddev 15      2711.16 (  0.00%)      1719.54 ( 36.58%)      9895.88 (-265.01%)
> Stddev 16      2797.21 (  0.00%)       983.63 ( 64.84%)      9302.92 (-232.58%)
> Stddev 17      4019.85 (  0.00%)      1927.25 ( 52.06%)      9998.34 (-148.72%)
> Stddev 18      3332.20 (  0.00%)      1401.68 ( 57.94%)     12056.08 (-261.80%)
> TPut   1     100137.00 (  0.00%)     82394.00 (-17.72%)    100769.00 (  0.63%)
> TPut   2     212704.00 (  0.00%)    175626.00 (-17.43%)    222033.00 (  4.39%)
> TPut   3     309402.00 (  0.00%)    241371.00 (-21.99%)    328490.00 (  6.17%)
> TPut   4     399678.00 (  0.00%)    323127.00 (-19.15%)    428933.00 (  7.32%)
> TPut   5     479188.00 (  0.00%)    391480.00 (-18.30%)    524064.00 (  9.37%)
> TPut   6     543432.00 (  0.00%)    495650.00 ( -8.79%)    609779.00 ( 12.21%)
> TPut   7     544296.00 (  0.00%)    506297.00 ( -6.98%)    629491.00 ( 15.65%)
> TPut   8     529705.00 (  0.00%)    487064.00 ( -8.05%)    646621.00 ( 22.07%)
> TPut   9     517731.00 (  0.00%)    456897.00 (-11.75%)    642122.00 ( 24.03%)
> TPut   10    473599.00 (  0.00%)    436162.00 ( -7.90%)    634768.00 ( 34.03%)
> TPut   11    478416.00 (  0.00%)    422266.00 (-11.74%)    617848.00 ( 29.14%)
> TPut   12    450969.00 (  0.00%)    406915.00 ( -9.77%)    598184.00 ( 32.64%)
> TPut   13    437923.00 (  0.00%)    414950.00 ( -5.25%)    579717.00 ( 32.38%)
> TPut   14    438896.00 (  0.00%)    414064.00 ( -5.66%)    575218.00 ( 31.06%)
> TPut   15    436447.00 (  0.00%)    403268.00 ( -7.60%)    567512.00 ( 30.03%)
> TPut   16    421543.00 (  0.00%)    397309.00 ( -5.75%)    560627.00 ( 32.99%)
> TPut   17    407614.00 (  0.00%)    385858.00 ( -5.34%)    553608.00 ( 35.82%)
> TPut   18    414530.00 (  0.00%)    382530.00 ( -7.72%)    551126.00 ( 32.95%)
>
> It is important to know how this was configured. I was running one JVM
> per node and the JVMs were sized that they should fit in the node. This
> is a semi-ideal configuration because it could also be hard-bound for
> best performance on the vanilla kernel. You did not say if you ran with
> a single JVM or multiple JVMs and it's important.
>
> The mean values are based on the individual throughput figures reported
> by each JVM. schednuma regresses against mainline quite badly. For low
> numbers of warehouses it also deviates more but it's much steadier for
> higher numbers of warehouses. In terms of overall throughput though,
> it's worse.
>
> autonuma deviates a *lot* with massive variances between the JVMs.
> However, the average and total throughput is very high.
>
> SPECJBB PEAKS
>                                         3.7.0                      3.7.0                      3.7.0
>                               rc4-stats-v2r34         rc4-schednuma-v2r3       rc4-autonuma-v28fast
>   Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)
>   Expctd Peak Bops               450969.00 (  0.00%)               406915.00 ( -9.77%)               598184.00 ( 32.64%)
>   Actual Warehouse                    7.00 (  0.00%)                    7.00 (  0.00%)                    8.00 ( 14.29%)
>   Actual Peak Bops               544296.00 (  0.00%)               506297.00 ( -6.98%)               646621.00 ( 18.80%)
>
> There is no major difference in terms of scalability. They peak at
> around the 7 warehouse mark. autonuma peaked at 8 but you can see from
> the figures that it was not by a whole lot. autonumas actual peak
> operations was very high (18% gain) where schednuma regressed by close
> to 7%.
>
> MMTests Statistics: duration
>                 3.7.0       3.7.0       3.7.0
>          rc4-stats-v2r34rc4-schednuma-v2r3rc4-autonuma-v28fast
> User       101949.84    86817.79   101748.80
> System         66.05    13094.99      191.40
> Elapsed      2456.35     2459.16     2451.96
>
> system CPU time is high for schednuma. autonuma reports low system CPU
> usage but as it is using kernel threads for much of its work, it cannot
> be considered reliable as it would not be captured here.
>
>> I've also tested Andrea's 'autonumabench' benchmark suite
>> against vanilla and the NUMA kernel, because Mel reported that
>> the CONFIG_SCHED_NUMA=y code regressed. It does not regress
>> anymore:
>>
>>    #
>>    # NUMA01
>>    #
>>    perf stat --null --repeat 3 ./numa01
>>
>>     v3.7-vanilla:           340.3 seconds           ( +/- 0.31% )
>>     v3.7-NUMA:              216.9 seconds  [ +56% ] ( +/- 8.32% )
>>     -------------------------------------
>>     v3.7-HARD_BIND:         166.6 seconds
>>
>> Here the new NUMA code is faster than vanilla by 56% - that is
>> because with the vanilla kernel all memory is allocated on
>> node0, overloading that node's memory bandwidth.
>>
>> [ Standard deviation on the vanilla kernel is low, because the
>>    autonuma test causes close to the worst-case placement for the
>>    vanilla kernel - and there's not much space to deviate away
>>    from the worst-case. Despite that, stddev in the NUMA seems a
>>    tad high, suggesting further room for improvement. ]
>>
>
> For machines with more than 2 nodes, numa01 is an adverse workload.
>
>>    #
>>    # NUMA01_THREAD_ALLOC
>>    #
>>    perf stat --null --repeat 3 ./numa01_THREAD_ALLOC
>>
>>     v3.7-vanilla:            425.1 seconds             ( +/- 1.04% )
>>     v3.7-NUMA:               118.7 seconds  [ +250% ]  ( +/- 0.49% )
>>     -------------------------------------
>>     v3.7-HARD_BIND:          200.56 seconds
>>
>> Here the NUMA kernel was able to go beyond the (naive)
>> hard-binding result and achieved 3.5x the performance of the
>> vanilla kernel, with a low stddev.
>>
>>    #
>>    # NUMA02
>>    #
>>    perf stat --null --repeat 3 ./numa02
>>
>>     v3.7-vanilla:           56.1 seconds               ( +/- 0.72% )
>>     v3.7-NUMA:              17.0 seconds    [ +230% ]  ( +/- 0.18% )
>>     -------------------------------------
>>     v3.7-HARD_BIND:         14.9 seconds
>>
>> Here the NUMA kernel runs the test much (3.3x) faster than the
>> vanilla kernel. The workload is able to converge very quickly
>> and approximate the hard-binding ideal number very closely. If
>> runtime was a bit longer it would approximate it even closer.
>>
>> Standard deviation is also 3 times lower than vanilla,
>> suggesting stable NUMA convergence.
>>
>>    #
>>    # NUMA02_SMT
>>    #
>>    perf stat --null --repeat 3 ./numa02_SMT
>>     v3.7-vanilla:            56.1 seconds                 ( +- 0.42% )
>>     v3.7-NUMA:               17.3 seconds     [ +220% ]   ( +- 0.88% )
>>     -------------------------------------
>>     v3.7-HARD_BIND:          14.6 seconds
>>
>> In this test too the NUMA kernel outperforms the vanilla kernel,
>> by a factor of 3.2x. It comes very close to the ideal
>> hard-binding convergence result. Standard deviation is a bit
>> high.
>>
>
> With this benchark, I'm generally seeing very good results in terms of
> elapsed time.
>
> AUTONUMA BENCH
>                                            3.7.0                 3.7.0                 3.7.0
>                                  rc4-stats-v2r34    rc4-schednuma-v2r3  rc4-autonuma-v28fast
> User    NUMA01               67351.66 (  0.00%)    47146.57 ( 30.00%)    30273.64 ( 55.05%)
> User    NUMA01_THEADLOCAL    54788.28 (  0.00%)    17198.99 ( 68.61%)    17039.73 ( 68.90%)
> User    NUMA02                7179.87 (  0.00%)     2096.07 ( 70.81%)     2099.85 ( 70.75%)
> User    NUMA02_SMT            3028.11 (  0.00%)      998.22 ( 67.03%)     1052.97 ( 65.23%)
> System  NUMA01                  45.68 (  0.00%)     3531.04 (-7629.95%)      423.91 (-828.00%)
> System  NUMA01_THEADLOCAL       40.92 (  0.00%)      926.72 (-2164.71%)      188.15 (-359.80%)
> System  NUMA02                   1.72 (  0.00%)       23.64 (-1274.42%)       27.37 (-1491.28%)
> System  NUMA02_SMT               0.92 (  0.00%)        8.18 (-789.13%)       18.43 (-1903.26%)
> Elapsed NUMA01                1514.61 (  0.00%)     1122.78 ( 25.87%)      722.66 ( 52.29%)
> Elapsed NUMA01_THEADLOCAL     1264.08 (  0.00%)      393.79 ( 68.85%)      391.48 ( 69.03%)
> Elapsed NUMA02                 181.88 (  0.00%)       49.44 ( 72.82%)       61.55 ( 66.16%)
> Elapsed NUMA02_SMT             168.41 (  0.00%)       47.49 ( 71.80%)       54.72 ( 67.51%)
> CPU     NUMA01                4449.00 (  0.00%)     4513.00 ( -1.44%)     4247.00 (  4.54%)
> CPU     NUMA01_THEADLOCAL     4337.00 (  0.00%)     4602.00 ( -6.11%)     4400.00 ( -1.45%)
> CPU     NUMA02                3948.00 (  0.00%)     4287.00 ( -8.59%)     3455.00 ( 12.49%)
> CPU     NUMA02_SMT            1798.00 (  0.00%)     2118.00 (-17.80%)     1957.00 ( -8.84%)
>
> On NUMA01, I'm seeing a large gain for schednuma. The test was not run
> multiple times so I do not know how much it deviates by on each run.
> However, the system CPU usage was again very high.
>
> NUMA01_THEADLOCAL figures were comparable with autonuma. The system CPU
> usage was high. As before, autonumas looks low but with the kernel
> threads we cannot be sure.
>
> schednuma was a clear winner on NUMA02 and NUMA02_SMT.
>
> So for the synthetic benchmarks, schednuma looks good in terms of
> elapsed time. On specjbb though, it is not looking great and this may be
> due to differences in how we configured the JVMs.
>
> I would have some comparison data with my own stuff but unfortunately
> the machine crashed when running tests with schednuma. That said, I
> expect the figures to be bad if they had run. With V2, the CPU-follows
> placement policy is broken as is PMD handling. In my current tree I'm
> expecting the system CPU usage to be also high but I won't know for sure
> until later today.
>
> The machine was meant to test all this overnight but unfortunately when
> running a kernel build benchmark on the schednuma patches the machine
> hung while downloading the tarball with this
>
> [   73.863226] BUG: unable to handle kernel NULL pointer dereference at           (null)
> [   73.871062] IP: [<ffffffff8146feaa>] skb_gro_receive+0xaa/0x590
> [   73.876983] PGD 0
> [   73.878998] Oops: 0002 [#1] PREEMPT SMP
> [   73.882938] Modules linked in: af_packet mperf kvm_intel coretemp kvm crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper cryptd sr_mod lrw cdrom aes_x86_64 ses pcspkr xts i7core_edac ata_piix enclosure lpc_ich dcdbas sg gf128mul mfd_core bnx2 edac_core wmi acpi_power_meter button serio_raw joydev microcode autofs4 processor thermal_sys scsi_dh_rdac scsi_dh_hp_sw scsi_dh_alua scsi_dh_emc scsi_dh ata_generic megaraid_sas pata_atiixp [last unloaded: oprofile]
> [   73.924659] CPU 0
> [   73.926493] Pid: 0, comm: swapper/0 Not tainted 3.7.0-rc4-schednuma-v2r3 #1 Dell Inc. PowerEdge R810/0TT6JF
> [   73.936380] RIP: 0010:[<ffffffff8146feaa>]  [<ffffffff8146feaa>] skb_gro_receive+0xaa/0x590
> [   73.944714] RSP: 0018:ffff88047f803b50  EFLAGS: 00010282
> [   73.950004] RAX: 0000000000000000 RBX: ffff88046c2bdbc0 RCX: 0000000000000900
> [   73.957113] RDX: 00000000000005a8 RSI: ffff88046c2bdbc0 RDI: ffff88046eadb800
> [   73.964221] RBP: ffff88047f803bb0 R08: 00000000000005dc R09: ffff88046ddeccc0
> [   73.971328] R10: ffff88086d795d78 R11: 0000000000000001 R12: ffff880462b282c0
> [   73.978436] R13: 0000000000000034 R14: 00000000000005a8 R15: ffff88046eadbec0
> [   73.985543] FS:  0000000000000000(0000) GS:ffff88047f800000(0000) knlGS:0000000000000000
> [   73.993602] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   73.999326] CR2: 0000000000000000 CR3: 0000000001a0c000 CR4: 00000000000007f0
> [   74.006435] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   74.013543] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   74.020651] Process swapper/0 (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a14420)
> [   74.028883] Stack:
> [   74.030885]  0000000000000060 ffff880462b282c0 ffff88086d795d78 ffffffff000005dc
> [   74.038300]  ffff88046e5f46c0 000000606a275ec0 0000000000000000 ffff88046c2bdbc0
> [   74.045715]  00000000000005a8 ffff88086d795d78 00000000000005a8 000000006c001080
> [   74.053131] Call Trace:
> [   74.055567]  <IRQ>
> [   74.057486]  [<ffffffff814b9573>] tcp_gro_receive+0x213/0x2b0
> [   74.063419]  [<ffffffff814cff49>] tcp4_gro_receive+0x99/0x110
> [   74.069150]  [<ffffffff814e096d>] inet_gro_receive+0x1cd/0x200
> [   74.074965]  [<ffffffff8147b30a>] dev_gro_receive+0x1ba/0x2b0
> [   74.080691]  [<ffffffff8147b6e3>] napi_gro_receive+0xe3/0x130
> [   74.086426]  [<ffffffffa009fda8>] bnx2_rx_int+0x3e8/0xf10 [bnx2]
> [   74.092416]  [<ffffffffa00a0cbd>] bnx2_poll_work+0x3ed/0x450 [bnx2]
> [   74.098666]  [<ffffffffa00a0d5e>] bnx2_poll_msix+0x3e/0xc0 [bnx2]
> [   74.104739]  [<ffffffff8147b969>] net_rx_action+0x159/0x290
> [   74.110298]  [<ffffffff8104d148>] __do_softirq+0xc8/0x250
> [   74.115682]  [<ffffffff8107bf9e>] ? sched_clock_idle_wakeup_event+0x1e/0x20
> [   74.122625]  [<ffffffff81577c9c>] call_softirq+0x1c/0x30
> [   74.127922]  [<ffffffff8100470d>] do_softirq+0x6d/0xa0
> [   74.133041]  [<ffffffff8104d44d>] irq_exit+0xad/0xc0
> [   74.137996]  [<ffffffff8107779d>] scheduler_ipi+0x5d/0x110
> [   74.143469]  [<ffffffff8102b7a4>] ? native_apic_msr_eoi_write+0x14/0x20
> [   74.150060]  [<ffffffff810257d5>] smp_reschedule_interrupt+0x25/0x30
> [   74.156394]  [<ffffffff8157785d>] reschedule_interrupt+0x6d/0x80
> [   74.162376]  <EOI>
> [   74.164295]  [<ffffffff81316798>] ? intel_idle+0xe8/0x150
> [   74.169875]  [<ffffffff81316779>] ? intel_idle+0xc9/0x150
> [   74.175259]  [<ffffffff8143de99>] cpuidle_enter+0x19/0x20
> [   74.180642]  [<ffffffff8143e522>] cpuidle_idle_call+0xa2/0x340
> [   74.186458]  [<ffffffff8100baca>] cpu_idle+0x7a/0xf0
> [   74.191410]  [<ffffffff8154b44b>] rest_init+0x7b/0x80
> [   74.196447]  [<ffffffff81ac3be2>] start_kernel+0x38f/0x39c
> [   74.201913]  [<ffffffff81ac3652>] ? repair_env_string+0x5e/0x5e
> [   74.207815]  [<ffffffff81ac3335>] x86_64_start_reservations+0x131/0x135
> [   74.214407]  [<ffffffff81ac3439>] x86_64_start_kernel+0x100/0x10f
> [   74.220475] Code: 8b e8 00 00 00 0f 87 86 00 00 00 8b 53 68 8b 43 6c 44 29 ea 39 d0 89 53 68 0f 87 c7 04 00 00 4c 01 ab e0 00 00 00 49 8b 44 24 08 <48> 89 18 49 89 5c 24 08 0f b6 43 7c a8 10 0f 85 ac 04 00 00 83
> [   74.240051] RIP  [<ffffffff8146feaa>] skb_gro_receive+0xaa/0x590
> [   74.246046]  RSP <ffff88047f803b50>
> [   74.249518] CR2: 0000000000000000
> [   74.252821] ---[ end trace 97cb529523f52c9b ]---
> [   74.258895] Kernel panic - not syncing: Fatal exception in interrupt
> -- 0:console -- time-stamp -- Nov/15/12  3:09:06 --
>
> I've no idea if it is directly related to your patches and I didn't try
> to reproduce it yet.
>
>> generation tool: 'perf bench numa' (I'll post it later in a
>> separate reply).
>>
>> Via 'perf bench numa' we can generate arbitrary process and
>> thread layouts, with arbitrary memory sharing arrangements
>> between them.
>>
>> Here are various comparisons to the vanilla kernel (higher
>> numbers are better):
>>
>>    #
>>    # 4 processes with 4 threads per process, sharing 4x 1GB of
>>    # process-wide memory:
>>    #
>>    # perf bench numa mem -l 100 -zZ0 -p 4 -t 4 -P 1024 -T    0
>>    #
>>             v3.7-vanilla:       14.8 GB/sec
>>             v3.7-NUMA:          32.9 GB/sec    [ +122.3% ]
>>
>> 2.2 times faster.
>>
>>    #
>>    # 4 processes with 4 threads per process, sharing 4x 1GB of
>>    # process-wide memory:
>>    #
>>    # perf bench numa mem -l 100 -zZ0 -p 4 -t 4 -P    0 -T 1024
>>    #
>>
>>             v3.7-vanilla:        17.0 GB/sec
>>             v3.7-NUMA:           36.3 GB/sec    [ +113.5% ]
>>
>> 2.1 times faster.
>>
>
> That is really cool.
>
>> So it's a nice improvement all around. With this version the
>> regressions that Mel Gorman reported a week ago appear to be
>> fixed as well.
>>
>
> Unfortunately I cannot concur. I'm still seeing high system CPU usage in
> places and the specjbb figures are rather unfortunate.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
