Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 757EC6B02F3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 01:51:05 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d15so11221196qta.11
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 22:51:05 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id p31si551340qtp.188.2017.08.07.22.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 22:51:04 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id i19so2439701qte.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 22:51:04 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [lkp-robot] [mm]  7674270022:  will-it-scale.per_process_ops
 -19.3% regression
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <93CA4B47-95C2-43A2-8E92-B142CAB1DAF7@gmail.com>
Date: Mon, 7 Aug 2017 22:51:00 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <970B5DC5-BFC2-461E-AC46-F71B3691D301@gmail.com>
References: <20170802000818.4760-7-namit@vmware.com>
 <20170808011923.GE25554@yexl-desktop> <20170808022830.GA28570@bbox>
 <93CA4B47-95C2-43A2-8E92-B142CAB1DAF7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kernel test robot <xiaolong.ye@intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, lkp@01.org

Nadav Amit <nadav.amit@gmail.com> wrote:

> Minchan Kim <minchan@kernel.org> wrote:
>=20
>> Hi,
>>=20
>> On Tue, Aug 08, 2017 at 09:19:23AM +0800, kernel test robot wrote:
>>> Greeting,
>>>=20
>>> FYI, we noticed a -19.3% regression of will-it-scale.per_process_ops =
due to commit:
>>>=20
>>>=20
>>> commit: 76742700225cad9df49f05399381ac3f1ec3dc60 ("mm: fix =
MADV_[FREE|DONTNEED] TLB flush miss problem")
>>> url: =
https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-migrate-prevent-rac=
y-access-to-tlb_flush_pending/20170802-205715
>>>=20
>>>=20
>>> in testcase: will-it-scale
>>> on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ =
2.20GHz with 64G memory
>>> with following parameters:
>>>=20
>>> 	nr_task: 16
>>> 	mode: process
>>> 	test: brk1
>>> 	cpufreq_governor: performance
>>>=20
>>> test-description: Will It Scale takes a testcase and runs it from 1 =
through to n parallel copies to see if the testcase will scale. It =
builds both a process and threads based test in order to see any =
differences between the two.
>>> test-url: https://github.com/antonblanchard/will-it-scale
>>=20
>> Thanks for the report.
>> Could you explain what kinds of workload you are testing?
>>=20
>> Does it calls frequently madvise(MADV_DONTNEED) in parallel on =
multiple
>> threads?
>=20
> According to the description it is "testcase:brk increase/decrease of =
one
> page=E2=80=9D. According to the mode it spawns multiple processes, not =
threads.
>=20
> Since a single page is unmapped each time, and the iTLB-loads increase
> dramatically, I would suspect that for some reason a full TLB flush is
> caused during do_munmap().
>=20
> If I find some free time, I=E2=80=99ll try to profile the workload - =
but feel free
> to beat me to it.

The root-cause appears to be that tlb_finish_mmu() does not call
dec_tlb_flush_pending() - as it should. Any chance you can take care of =
it?

Having said that it appears that cpumask_any_but() is really inefficient
since it does not have an optimization for the case in which
small_const_nbits(nbits)=3D=3Dtrue. When I find some free time, I=E2=80=99=
ll try to deal
with it.

Thanks,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
