Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 342296B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:14:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r133so84654757pgr.6
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 21:14:56 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id x8si3428461pgc.689.2017.08.09.21.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 21:14:55 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 83so7492004pgb.4
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 21:14:54 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [lkp-robot] [mm]  7674270022:  will-it-scale.per_process_ops
 -19.3% regression
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170810041353.GB2042@bbox>
Date: Wed, 9 Aug 2017 21:14:50 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <80589593-6F0E-4421-9279-681D5B388100@gmail.com>
References: <20170802000818.4760-7-namit@vmware.com>
 <20170808011923.GE25554@yexl-desktop> <20170808022830.GA28570@bbox>
 <93CA4B47-95C2-43A2-8E92-B142CAB1DAF7@gmail.com>
 <970B5DC5-BFC2-461E-AC46-F71B3691D301@gmail.com>
 <20170808080821.GA31730@bbox> <20170809025902.GA17616@yexl-desktop>
 <20170810041353.GB2042@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ye Xiaolong <xiaolong.ye@intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, lkp@01.org

Minchan Kim <minchan@kernel.org> wrote:

> On Wed, Aug 09, 2017 at 10:59:02AM +0800, Ye Xiaolong wrote:
>> On 08/08, Minchan Kim wrote:
>>> On Mon, Aug 07, 2017 at 10:51:00PM -0700, Nadav Amit wrote:
>>>> Nadav Amit <nadav.amit@gmail.com> wrote:
>>>>=20
>>>>> Minchan Kim <minchan@kernel.org> wrote:
>>>>>=20
>>>>>> Hi,
>>>>>>=20
>>>>>> On Tue, Aug 08, 2017 at 09:19:23AM +0800, kernel test robot =
wrote:
>>>>>>> Greeting,
>>>>>>>=20
>>>>>>> FYI, we noticed a -19.3% regression of =
will-it-scale.per_process_ops due to commit:
>>>>>>>=20
>>>>>>>=20
>>>>>>> commit: 76742700225cad9df49f05399381ac3f1ec3dc60 ("mm: fix =
MADV_[FREE|DONTNEED] TLB flush miss problem")
>>>>>>> url: =
https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-migrate-prevent-rac=
y-access-to-tlb_flush_pending/20170802-205715
>>>>>>>=20
>>>>>>>=20
>>>>>>> in testcase: will-it-scale
>>>>>>> on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ =
2.20GHz with 64G memory
>>>>>>> with following parameters:
>>>>>>>=20
>>>>>>> 	nr_task: 16
>>>>>>> 	mode: process
>>>>>>> 	test: brk1
>>>>>>> 	cpufreq_governor: performance
>>>>>>>=20
>>>>>>> test-description: Will It Scale takes a testcase and runs it =
from 1 through to n parallel copies to see if the testcase will scale. =
It builds both a process and threads based test in order to see any =
differences between the two.
>>>>>>> test-url: https://github.com/antonblanchard/will-it-scale
>>>>>>=20
>>>>>> Thanks for the report.
>>>>>> Could you explain what kinds of workload you are testing?
>>>>>>=20
>>>>>> Does it calls frequently madvise(MADV_DONTNEED) in parallel on =
multiple
>>>>>> threads?
>>>>>=20
>>>>> According to the description it is "testcase:brk increase/decrease =
of one
>>>>> page=E2=80=9D. According to the mode it spawns multiple processes, =
not threads.
>>>>>=20
>>>>> Since a single page is unmapped each time, and the iTLB-loads =
increase
>>>>> dramatically, I would suspect that for some reason a full TLB =
flush is
>>>>> caused during do_munmap().
>>>>>=20
>>>>> If I find some free time, I=E2=80=99ll try to profile the workload =
- but feel free
>>>>> to beat me to it.
>>>>=20
>>>> The root-cause appears to be that tlb_finish_mmu() does not call
>>>> dec_tlb_flush_pending() - as it should. Any chance you can take =
care of it?
>>>=20
>>> Oops, but with second looking, it seems it's not my fault. ;-)
>>> https://marc.info/?l=3Dlinux-mm&m=3D150156699114088&w=3D2
>>>=20
>>> Anyway, thanks for the pointing out.
>>> xiaolong.ye, could you retest with this fix?
>>=20
>> I've queued tests for 5 times and results show this patch =
(e8f682574e4 "mm:
>> decrease tlb flush pending count in tlb_finish_mmu") does help =
recover the
>> performance back.
>>=20
>> 378005bdbac0a2ec  76742700225cad9df49f053993  =
e8f682574e45b6406dadfffeb4 =20
>> ----------------  --------------------------  =
-------------------------- =20
>>         %stddev      change         %stddev      change         =
%stddev
>>             \          |                \          |                \ =
=20
>>   3405093             -19%    2747088              -2%    3348752     =
   will-it-scale.per_process_ops
>>      1280 =C2=B1  3%        -2%       1257 =C2=B1  3%        -6%      =
 1207        vmstat.system.cs
>>      2702 =C2=B1 18%        11%       3002 =C2=B1 19%        17%      =
 3156 =C2=B1 18%  numa-vmstat.node0.nr_mapped
>>     10765 =C2=B1 18%        11%      11964 =C2=B1 19%        17%      =
12588 =C2=B1 18%  numa-meminfo.node0.Mapped
>>      0.00 =C2=B1 47%       -40%       0.00 =C2=B1 45%       -84%      =
 0.00 =C2=B1 42%  mpstat.cpu.soft%
>>=20
>> Thanks,
>> Xiaolong
>=20
> Thanks for the testing!

Sorry again for screwing your patch, Minchan.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
