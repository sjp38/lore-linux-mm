Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 84AD16B0038
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 10:59:59 -0500 (EST)
Received: by iouu10 with SMTP id u10so94988082iou.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 07:59:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s18si9735314ioe.176.2015.11.19.07.59.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 07:59:58 -0800 (PST)
Subject: Re: memory reclaim problems on fs usage
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201511102313.36685.arekm@maven.pl>
	<201511151549.35299.arekm@maven.pl>
	<20151116161518.GI14116@dhcp22.suse.cz>
	<201511182336.18231.arekm@maven.pl>
In-Reply-To: <201511182336.18231.arekm@maven.pl>
Message-Id: <201511200059.CFI00514.OLFJtMFFHSOOQV@I-love.SAKURA.ne.jp>
Date: Fri, 20 Nov 2015 00:59:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arekm@maven.pl, mhocko@suse.cz
Cc: htejun@gmail.com, cl@linux.com, linux-mm@kvack.org, xfs@oss.sgi.com

Arkadiusz Miskiewicz wrote:
> Ok. In mean time I've tried 4.3.0 kernel + patches (the same as before + one 
> more) on second server which runs even more rsnapshot processes and also uses 
> xfs on md raid 6.
> 
> Patches:
> http://sprunge.us/DfIQ (debug patch from Tetsuo)
> http://sprunge.us/LQPF (backport of things from git + one from ml)
> 
> The problem is now with high order allocations probably:
> http://ixion.pld-linux.org/~arekm/log-mm-2srv-1.txt.gz

This seems to be stall upon allocating transparent huge pages.
(page fault -> try to allocate 2MB page -> reclaim -> waiting)

----------
[ 1166.110205] Node 0 Normal: 4801*4kB (UE) 1461*8kB (UMEC) 290*16kB (UMEC) 715*32kB (UM) 67*64kB (UME) 7*128kB (UMEC) 3*256kB (MEC) 6*512kB (UMEC) 3*1024kB (MEC) 10*2048kB (UME) 219*4096kB (M) = 988012kB
[ 1178.250751] Node 0 Normal: 4917*4kB (UME) 2622*8kB (UMEC) 530*16kB (UMC) 713*32kB (UME) 68*64kB (UM) 8*128kB (UMC) 5*256kB (MEC) 5*512kB (UMC) 8*1024kB (MEC) 4*2048kB (UME) 207*4096kB (M) = 945412kB
[ 1190.108587] Node 0 Normal: 4301*4kB (UME) 3132*8kB (UMEC) 670*16kB (UMEC) 766*32kB (UME) 74*64kB (UME) 11*128kB (UMC) 8*256kB (UMEC) 4*512kB (UMEC) 3*1024kB (MEC) 2*2048kB (UM) 206*4096kB (M) = 938676kB
[ 1202.014434] Node 0 Normal: 3971*4kB (UM) 2704*8kB (UMC) 650*16kB (UMEC) 754*32kB (UE) 68*64kB (UME) 6*128kB (UMC) 3*256kB (UEC) 3*512kB (UEC) 6*1024kB (MEC) 5*2048kB (UM) 206*4096kB (M) = 939628kB
[ 1212.438969] Node 0 Normal: 5307*4kB (UE) 4976*8kB (UEC) 1095*16kB (UC) 702*32kB (UM) 67*64kB (UM) 6*128kB (UMC) 2*256kB (UC) 37*512kB (UMC) 36*1024kB (MC) 29*2048kB (UME) 324*4096kB (M) = 1548892kB
[ 1222.840549] Node 0 Normal: 0*4kB 5*8kB (UMEC) 711*16kB (UC) 490*32kB (UME) 66*64kB (U) 6*128kB (UEC) 3*256kB (UMC) 3*512kB (UEC) 2*1024kB (MC) 1*2048kB (U) 303*4096kB (M) = 1279576kB
[ 1243.941537] Node 0 Normal: 28825*4kB (UE) 26405*8kB (UMEC) 12409*16kB (UMC) 3351*32kB (UME) 408*64kB (UM) 19*128kB (UMC) 3*256kB (UC) 4*512kB (UMC) 2*1024kB (UC) 3*2048kB (UME) 65*4096kB (M) = 938108kB
[ 1256.006097] Node 0 Normal: 40219*4kB (UME) 34873*8kB (UE) 17232*16kB (UME) 5633*32kB (UME) 598*64kB (UM) 1*128kB (M) 0*256kB 2*512kB (M) 0*1024kB 0*2048kB 0*4096kB = 935252kB
[ 1268.951714] Node 0 Normal: 36607*4kB (UME) 37875*8kB (UME) 17450*16kB (UME) 5497*32kB (UME) 485*64kB (U) 0*128kB 0*256kB 1*512kB (M) 0*1024kB 0*2048kB 0*4096kB = 936084kB
[ 1279.263718] Node 0 Normal: 39565*4kB (UME) 39229*8kB (UME) 17553*16kB (UME) 5174*32kB (UME) 279*64kB (UM) 2*128kB (ME) 4*256kB (ME) 3*512kB (M) 0*1024kB 0*2048kB 0*4096kB = 939180kB
[ 1300.454484] Node 0 Normal: 37945*4kB (U) 52089*8kB (U) 24197*16kB (UE) 7420*32kB (UME) 493*64kB (UM) 10*128kB (UME) 1*256kB (M) 1*512kB (E) 2*1024kB (ME) 1*2048kB (E) 39*4096kB (M) = 1390524kB
[ 1310.761624] Node 0 Normal: 18034*4kB (U) 44842*8kB (UE) 19948*16kB (UE) 5383*32kB (UME) 162*64kB (UME) 2*128kB (ME) 3*256kB (ME) 5*512kB (ME) 1*1024kB (M) 0*2048kB 0*4096kB = 937272kB
[ 1320.848763] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=4574
[ 1321.988480] Node 0 Normal: 19294*4kB (UME) 45490*8kB (UE) 20125*16kB (UME) 5229*32kB (UM) 93*64kB (UM) 4*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 936888kB
[ 1342.042799] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=10944
[ 1352.791917] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=14172
[ 1364.143762] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=17581
[ 1374.499973] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=20691
[ 1384.842838] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=23797
[ 1395.192348] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=26905
[ 1405.525243] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=30008
[ 1415.831459] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=33103
[ 1427.113385] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=36491
[ 1437.416290] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=39585
[ 1437.428716] MemAlloc: rsnapshot(3639) gfp=0x4f52ca order=9 delay=3389
(...snipped...)
[30084.882928] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=3654551
[30085.744771] Node 0 Normal: 212267*4kB (UME) 10914*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 936380kB
[30084.889563] MemAlloc: syslog-ng(1671) gfp=0x4f52ca order=9 delay=324074
[30106.734724] MemAlloc: cp(2795) gfp=0x4f52ca order=9 delay=3698251
[30106.747497] MemAlloc: syslog-ng(1671) gfp=0x4f52ca order=9 delay=330638
[30117.713596] MemAlloc: cp(2795) gfp=0x4f52ca order=9 delay=3701548
[30117.719721] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=3664412
[30117.726356] MemAlloc: syslog-ng(1671) gfp=0x4f52ca order=9 delay=333935
[30139.904472] MemAlloc: cp(2795) gfp=0x4f52ca order=9 delay=3708212
[30139.910594] MemAlloc: khugepaged(32) gfp=0xcf52ca order=9 delay=3671076
[30139.917237] MemAlloc: syslog-ng(1671) gfp=0x4f52ca order=9 delay=340599
[30172.684553] MemAlloc: cp(2795) gfp=0x4f52ca order=9 delay=3718056
[30173.749694] Node 0 Normal: 234069*4kB (UE) 148*8kB (UE) 113*16kB (UE) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 939268kB
----------

So many 4kB pages but no 2048kB pages.

> System is doing very slow progress and for example depmod run took 2 hours
> http://sprunge.us/HGbE
> Sometimes I was able to ssh-in, dmesg took 10-15 minutes but sometimes it 
> worked fast for short period.
> 
> Ideas?

Memory fragmentation is out of my understanding.
Maybe disabling THP can help.

> 
> ps. I also had one problem with low order allocation but only once and wasn't 
> able to reproduce so far. I was running kernel with backport patches but no 
> debug patch, so got only this in logs:
> http://sprunge.us/WPXi

Unfortunately 16kB pages was not available at that moment.
But it was GFP_ATOMIC and infrequent failure should not become a problem.

----------
[ 8513.740326] swapper/3: page allocation failure: order:2, mode:0xc020
(...snipped...)
[ 8514.247719] Node 0 Normal: 207920*4kB (UE) 18052*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 976096kB
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
