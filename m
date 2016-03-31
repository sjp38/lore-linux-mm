Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6DFD16B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:16:14 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id td3so61919997pab.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 02:16:14 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id u11si12912194pas.102.2016.03.31.02.16.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 02:16:13 -0700 (PDT)
Message-ID: <56FCEAD0.9080806@huawei.com>
Date: Thu, 31 Mar 2016 17:16:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] oom, but there is enough memory
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

It triggers a lot of ooms, but there is enough memory(many large blocks).
And at last "Kernel panic - not syncing: Out of memory and no killable processes..."

I find almost the every call trace include "pagefault_out_of_memory" and "gfp_mask=0x0".
If it does oom, why not it triger in mm core path? 
e.g. __alloc_pages_nodemask -> __alloc_pages_slowpath -> __alloc_pages_may_oom ...
And if the allocation from user space, why the gfp_mask=0x0? (usually is GFP_HIGHUSER_MOVABLE, instead of GFP_NOWAIT)

Here is one oom log, the kernel is v3.10 stable.
<4>[63651.040008s][pid:2912,cpu3,sh]sh invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=-1000
<6>[63651.040039s][pid:2912,cpu3,sh]sh cpuset=/ mems_allowed=0
<4>[63651.040039s][pid:2912,cpu3,sh]CPU: 3 PID: 2912 Comm: sh Tainted: G    B        3.10.90-g97d130c #1
<0>[63651.040039s][pid:2912,cpu3,sh]Call trace:
<4>[63651.040069s][pid:2912,cpu3,sh][<ffffffc000088e5c>] dump_backtrace+0x0/0x124
<4>[63651.040069s][pid:2912,cpu3,sh][<ffffffc000088f9c>] show_stack+0x10/0x1c
<4>[63651.040100s][pid:2912,cpu3,sh][<ffffffc000c465d0>] dump_stack+0x1c/0x28
<4>[63651.040100s][pid:2912,cpu3,sh][<ffffffc00014e698>] dump_header.isra.13+0x88/0x1a8
<4>[63651.040100s][pid:2912,cpu3,sh][<ffffffc00014ec18>] oom_kill_process+0x280/0x3f4
<4>[63651.040130s][pid:2912,cpu3,sh][<ffffffc00014f25c>] out_of_memory+0x2c0/0x2fc
<4>[63651.040130s][pid:2912,cpu3,sh][<ffffffc00014f2d0>] pagefault_out_of_memory+0x38/0x54
<4>[63651.040130s][pid:2912,cpu3,sh][<ffffffc000c5376c>] do_page_fault.part.6+0x310/0x33c
<4>[63651.040130s][pid:2912,cpu3,sh][<ffffffc000c537c4>] do_page_fault+0x2c/0xd0
<4>[63651.040161s][pid:2912,cpu3,sh][<ffffffc000081240>] do_mem_abort+0x38/0x9c
<4>[63651.040161s][pid:2912,cpu3,sh]Exception stack(0xffffffc0457e7e30 to 0xffffffc0457e7f50)
<4>[63651.040161s][pid:2912,cpu3,sh]7e20:                                     4e3f5d07 00000000 97c4a3e8 0000007f
<4>[63651.040191s][pid:2912,cpu3,sh]7e40: ffffffff ffffffff 97c16e7c 0000007f 00000000 00000000 97c39f10 0000007f
<4>[63651.040191s][pid:2912,cpu3,sh]7e60: ebe1a7f0 0000007f 000843ac ffffffc0 457e7e90 ffffffc0 00084ff0 ffffffc0
<4>[63651.040191s][pid:2912,cpu3,sh]7e80: 457e7e90 ffffffc0 00084ffc ffffffc0 457e7eb0 ffffffc0 000889c0 ffffffc0
<4>[63651.040222s][pid:2912,cpu3,sh]7ea0: 00000008 00000000 000000a7 00000000 ebe1a7c0 0000007f 0008444c ffffffc0
<4>[63651.040222s][pid:2912,cpu3,sh]7ec0: 4e3f5d07 00000000 000843ac ffffffc0 97c4a3e8 0000007f 979e2620 0000007f
<4>[63651.040222s][pid:2912,cpu3,sh]7ee0: 00000618 00000000 00000000 00000000 00002e40 00000000 00050d63 00000000
<4>[63651.040252s][pid:2912,cpu3,sh]7f00: 00000000 00000000 f23aeec6 0000002a 979edcbc 0000007f 979ed40c 0000007f
<4>[63651.040252s][pid:2912,cpu3,sh]7f20: 979e3848 0000007f 00000041 00000000 00000001 00000000 00000000 00000000
<4>[63651.040252s][pid:2912,cpu3,sh]7f40: 00000002 00000000 00000002 00000000
<4>[63651.040252s][pid:2912,cpu3,sh]Mem-Info:
<4>[63651.040283s][pid:2912,cpu3,sh]DMA per-cpu:
<4>[63651.040283s][pid:2912,cpu3,sh]CPU    0: hi:  186, btch:  31 usd: 156
<4>[63651.040283s][pid:2912,cpu3,sh]CPU    1: hi:  186, btch:  31 usd: 105
<4>[63651.040283s][pid:2912,cpu3,sh]CPU    2: hi:  186, btch:  31 usd: 147
<4>[63651.040313s][pid:2912,cpu3,sh]CPU    3: hi:  186, btch:  31 usd: 159
<4>[63651.040313s][pid:2912,cpu3,sh]CPU    4: hi:  186, btch:  31 usd: 182
<4>[63651.040313s][pid:2912,cpu3,sh]CPU    5: hi:  186, btch:  31 usd: 181
<4>[63651.040313s][pid:2912,cpu3,sh]CPU    6: hi:  186, btch:  31 usd:  59
<4>[63651.040313s][pid:2912,cpu3,sh]CPU    7: hi:  186, btch:  31 usd: 167
<4>[63651.040344s][pid:2912,cpu3,sh]active_anon:85765 inactive_anon:306 isolated_anon:0
<4>[63651.040344s] active_file:26899 inactive_file:116289 isolated_file:0
<4>[63651.040344s] unevictable:260 dirty:10 writeback:0 unstable:0
<4>[63651.040344s] free:137650 slab_reclaimable:6762 slab_unreclaimable:18325
<4>[63651.040344s] mapped:50105 shmem:328 pagetables:3621 bounce:0
<4>[63651.040344s] free_cma:7724
<4>[63651.040374s][pid:2912,cpu3,sh]DMA free:550600kB min:5244kB low:27580kB high:28892kB active_anon:343060kB inactive_anon:1224kB active_file:107596kB inactive_file:465156kB unevictable:1040kB isolated(anon):0kB isolated(file):0kB present:2016252kB managed:1720040kB mlocked:1040kB dirty:40kB writeback:0kB mapped:200420kB shmem:1312kB slab_reclaimable:27048kB slab_unreclaimable:73300kB kernel_stack:15248kB pagetables:14484kB unstable:0kB bounce:0kB free_cma:30896kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
<4>[63651.040374s][pid:2912,cpu3,sh]lowmem_reserve[]: 0 0 0
<4>[63651.040374s][pid:2912,cpu3,sh]DMA: 2883*4kB (UEMC) 1235*8kB (UEMC) 583*16kB (UEM) 309*32kB (UEMC) 117*64kB (UEM) 58*128kB (UEMC) 12*256kB (UEM) 6*512kB (UEM) 6*1024kB (U) 6*2048kB (UMC) 115*4096kB (UMRC) = 551156kB
<4>[63651.040435s][pid:2912,cpu3,sh]152759 total pagecache pages
<4>[63651.040435s][pid:2912,cpu3,sh]0 pages in swap cache
<4>[63651.040435s][pid:2912,cpu3,sh]Swap cache stats: add 0, delete 0, find 0/10
<4>[63651.040435s][pid:2912,cpu3,sh]Free swap  = 524280kB
<4>[63651.040466s][pid:2912,cpu3,sh]Total swap = 524280kB
<4>[63651.067657s][pid:2912,cpu3,sh]504063 pages RAM
<4>[63651.067687s][pid:2912,cpu3,sh]23820 pages reserved
<4>[63651.067687s][pid:2912,cpu3,sh]1420923 pages shared
<4>[63651.067687s][pid:2912,cpu3,sh]261855 pages non-shared
<6>[63651.067718s][pid:2912,cpu3,sh][ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
<6>[63651.067779s][pid:2912,cpu3,sh][  250]     0   250     1084      249       4        0         -1000 ueventd
<6>[63651.067779s][pid:2912,cpu3,sh][  252]     0   252      678       87       4        0         -1000 oeminfo_nvm_ser
<6>[63651.067779s][pid:2912,cpu3,sh][  299]  1036   299     5090     1893      14        0         -1000 logd
<6>[63651.067810s][pid:2912,cpu3,sh][  300]     0   300     3758      771      11        0         -1000 vold
<6>[63651.067810s][pid:2912,cpu3,sh][  313]     0   313     1070      121       5        0         -1000 healthd
<6>[63651.067810s][pid:2912,cpu3,sh][  314]     0   314     1924      606       7        0         -1000 lmkd
<6>[63651.067840s][pid:2912,cpu3,sh][  315]  1000   315     1520      347       6        0         -1000 servicemanager
<6>[63651.067840s][pid:2912,cpu3,sh][  316]  1000   316    90116     4462      86        0         -1000 surfaceflinger
<6>[63651.067871s][pid:2912,cpu3,sh][  317]  1000   317     5109      537      14        0         -1000 perfhub
<6>[63651.067871s][pid:2912,cpu3,sh][  318]     0   318     3182      323       8        0         -1000 teecd
<6>[63651.067871s][pid:2912,cpu3,sh][  361]     0   361     6325      910      16        0         -1000 netd
<6>[63651.067901s][pid:2912,cpu3,sh][  362]     0   362      807      284       4        0         -1000 debuggerd
<6>[63651.067901s][pid:2912,cpu3,sh][  363]     0   363     1998      632       8        0         -1000 debuggerd64
<6>[63651.067901s][pid:2912,cpu3,sh][  364]  1019   364     3968     1395      10        0         -1000 drmserver
<6>[63651.067932s][pid:2912,cpu3,sh][  366]  1013   366     7878     1740      16        0         -1000 mediaserver
<6>[63651.067932s][pid:2912,cpu3,sh][  367]     0   367     1528      349       6        0         -1000 installd
<6>[63651.067932s][pid:2912,cpu3,sh][  368]  1017   368     4402      852      11        0         -1000 keystore
<6>[63651.067962s][pid:2912,cpu3,sh][  369]  1000   369     1383      293       6        0         -1000 hw_ueventd
<6>[63651.067962s][pid:2912,cpu3,sh][  370]     0   370   309570    25514     163        0         -1000 main
<6>[63651.067993s][pid:2912,cpu3,sh][  371]     0   371   233222    20011     140        0         -1000 main
<6>[63651.067993s][pid:2912,cpu3,sh][  372]     0   372     2468      449       7        0         -1000 device_monitor
<6>[63651.067993s][pid:2912,cpu3,sh][  374]     0   374     1760      397       7        0         -1000 hwnffserver
<6>[63651.068023s][pid:2912,cpu3,sh][  375]  1000   375     1459      322       5        0         -1000 thermal-daemon
<6>[63651.068023s][pid:2912,cpu3,sh][  376]  1013   376    19568     2596      40        0         -1000 HwCamCfgSvr
<6>[63651.068023s][pid:2912,cpu3,sh][  377]     0   377     1585      125       5        0         -1000 adbd
<6>[63651.068054s][pid:2912,cpu3,sh][  378]     0   378     1584      126       5        0         -1000 hdbd
<6>[63651.068054s][pid:2912,cpu3,sh][  385]     0   385     1411      290       6        0         -1000 diagserver
<6>[63651.068054s][pid:2912,cpu3,sh][  386]     0   386     4119      829      11        0         -1000 atcmdserver
<6>[63651.068084s][pid:2912,cpu3,sh][  388]  1001   388     9090     1001      21        0         -1000 rild
<6>[63651.068084s][pid:2912,cpu3,sh][  389]     0   389     1361      287       5        0         -1000 pmom_cat
<6>[63651.068084s][pid:2912,cpu3,sh][  391]     0   391     3670      641      10        0         -1000 tlogcat
<6>[63651.068115s][pid:2912,cpu3,sh][  393]     0   393     1742      321       6        0         -1000 shs
<6>[63651.068115s][pid:2912,cpu3,sh][  394]  1000   394     4230      789      10        0         -1000 gatekeeperd
<6>[63651.068115s][pid:2912,cpu3,sh][  395]     0   395     1519      346       6        0         -1000 perfprofd
<6>[63651.068145s][pid:2912,cpu3,sh][  398]  1000   398     5079      838      12        0         -1000 fingerprintd
<6>[63651.068145s][pid:2912,cpu3,sh][  399]     0   399     3409      753      11        0         -1000 jankservice
<6>[63651.068145s][pid:2912,cpu3,sh][  400]     0   400     1431      334       5        0         -1000 chargelogcat
<6>[63651.068176s][pid:2912,cpu3,sh][  401]     0   401     4309     1666      12        0         -1000 hiscoutmanager
<6>[63651.068176s][pid:2912,cpu3,sh][  402]     0   402     1495      299       6        0         -1000 isplogcat
<6>[63651.068176s][pid:2912,cpu3,sh][  403]     0   403     2294      426       8        0         -1000 logserver
<6>[63651.068206s][pid:2912,cpu3,sh][  406]     0   406     1460      354       6        0         -1000 logcat
<6>[63651.068206s][pid:2912,cpu3,sh][  407]     0   407     1452      338       6        0         -1000 dumptool
<6>[63651.068206s][pid:2912,cpu3,sh][  409]     0   409     3177      755       9        0         -1000 chargemonitor
<6>[63651.068237s][pid:2912,cpu3,sh][  411]     0   411     2542      377       8        0         -1000 sleeplogcat
<6>[63651.068237s][pid:2912,cpu3,sh][  413]     0   413     1505      353       6        0         -1000 eventcat
<6>[63651.068267s][pid:2912,cpu3,sh][  414]     0   414     1689      380       6        0         -1000 hilogcat
<6>[63651.068267s][pid:2912,cpu3,sh][  416]     0   416     2409      185       7        0         -1000 factory_log_ser
<6>[63651.068267s][pid:2912,cpu3,sh][  593]  1013   593    41187     3247      45        0         -1000 mediaserver
<6>[63651.068298s][pid:2912,cpu3,sh][  701]  1000   701     1409      301       6        0         -1000 octty
<6>[63651.068298s][pid:2912,cpu3,sh][  702]  1000   702     2252      372       8        0         -1000 oam_hisi
<6>[63651.068298s][pid:2912,cpu3,sh][  703]  1000   703     2263      516       7        0         -1000 gnss_engine_his
<6>[63651.068328s][pid:2912,cpu3,sh][  704]  1000   704     3933      574      10        0         -1000 gnss_control_hi
<6>[63651.068328s][pid:2912,cpu3,sh][  706]  1000   706     5217     1223      14        0         -1000 gnss_supl20clie
<6>[63651.068328s][pid:2912,cpu3,sh][  707]  1000   707     1360      502       5        0         -1000 gnss_watchlssd_
<6>[63651.068359s][pid:2912,cpu3,sh][  717]  1000   717     1424      319       5        0         -1000 lss
<6>[63651.068359s][pid:2912,cpu3,sh][  957]  1000   957   370859    40098     271        0          -941 system_server
<6>[63651.068389s][pid:2912,cpu3,sh][ 1227]  1000  1227   311127    17585     128        0          -705 wei.securitymgr
<6>[63651.068389s][pid:2912,cpu3,sh][ 1236] 10006  1236   438735    36718     219        0          -705 ndroid.systemui
<6>[63651.068389s][pid:2912,cpu3,sh][ 1257] 10006  1257   401625    31013     208        0          -705 ndroid.keyguard
<6>[63651.068420s][pid:2912,cpu3,sh][ 1345] 10002  1345   316182    22367     153        0           294 d.process.acore
<6>[63651.068420s][pid:2912,cpu3,sh][ 1460] 10003  1460   311929    19710     148        0           647 d.process.media
<6>[63651.068420s][pid:2912,cpu3,sh][ 1521]  1000  1521   316677    19249     145        0           529 ndroid.settings
<6>[63651.068450s][pid:2912,cpu3,sh][ 1594] 10019  1594   314871    20932     148        0           117 putmethod.latin
<6>[63651.068450s][pid:2912,cpu3,sh][ 1639]  1000  1639   313224    19145     135        0          -705 om.android.supl
<6>[63651.068450s][pid:2912,cpu3,sh][ 1653]  1001  1653   321115    23914     160        0          -705 m.android.phone
<6>[63651.068481s][pid:2912,cpu3,sh][ 1680] 10018  1680   485086    35356     229        0             0 droid.launcher3
<6>[63651.068481s][pid:2912,cpu3,sh][ 1693] 10016  1693   311750    17748     135        0           764 id.printspooler
<6>[63651.068481s][pid:2912,cpu3,sh][ 1768]  1001  1768   312733    18723     133        0            58 ndroid.incallui
<6>[63651.068511s][pid:2912,cpu3,sh][ 2172]  1050  2172   311737    18111     136        0           470 .service:remote
<6>[63651.068511s][pid:2912,cpu3,sh][ 2725]     0  2725     1387      295       6        0         -1000 dmesgcat
<6>[63651.068542s][pid:2912,cpu3,sh][ 2856]  1000  2856   311451    17196     130        0          -705 i.runningtestii
<6>[63651.068542s][pid:2912,cpu3,sh][ 2912]     0  2912      813       72       5        0         -1000 sh
<3>[63651.068542s][pid:2912,cpu3,sh]Out of memory: Kill process 1693 (id.printspooler) score 792 or sacrifice child
<3>[63651.068572s][pid:2912,cpu3,sh]Killed process 1693 (id.printspooler) total-vm:1247000kB, anon-rss:48032kB, file-rss:22960kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
