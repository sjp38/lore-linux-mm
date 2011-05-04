Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9BD7F6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 00:00:27 -0400 (EDT)
Date: Wed, 4 May 2011 12:00:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110504040018.GB6500@localhost>
References: <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <BANLkTimpT-N5--3QjcNg8CyNNwfEWxFyKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="qMm9M+Fa2AknHoGS"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTimpT-N5--3QjcNg8CyNNwfEWxFyKA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

> > CAL: A  A  220449 A  A  220246 A  A  220372 A  A  220558 A  A  220251 A  A  219740 A  A  220043 A  A  219968 A  Function call interrupts
> >
> > LOC: A  A  536274 A  A  532529 A  A  531734 A  A  536801 A  A  536510 A  A  533676 A  A  534853 A  A  532038 A  Local timer interrupts
> > RES: A  A  A  3032 A  A  A  2128 A  A  A  1792 A  A  A  1765 A  A  A  2184 A  A  A  1703 A  A  A  1754 A  A  A  1865 A  Rescheduling interrupts
> > TLB: A  A  A  A 189 A  A  A  A  15 A  A  A  A  13 A  A  A  A  17 A  A  A  A  64 A  A  A  A 294 A  A  A  A  97 A  A  A  A  63 A  TLB shootdowns
> 
> Could you tell how to get above info?

It's /proc/interrupts.

I have two lines at the end of the attached script to collect the
information, and another script to call getdelays on every 10s. The
posted reclaim delays are the last successful getdelays output. 

I've automated the test process, so that with one single command line
a new kernel will be built and the test box will rerun tests on the
new kernel :)

Thanks,
Fengguang

--qMm9M+Fa2AknHoGS
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-alloc-fails.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A=0Aver=3D`date +'%F-%T'`=0A=0Aln -fs alloc-fails-$ver /log/allo=
c-fails=0Aln -fs alloc-delays-$ver /log/alloc-delays=0A=0A/home/wfg/test-dd=
-sparse.sh > /log/alloc-fails-$ver &=0A=0Asleep 10=0A=0A(=0Awhile /usr/loca=
l/bin/getdelays -dip `pidof dd`;=0Ado=0A	sleep 10;=0Adone=0A) > /log/alloc-=
delays-$ver=0A
--qMm9M+Fa2AknHoGS
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-dd-sparse.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A=0Amount /dev/sda7 /fs=0A=0A# echo 80000 > /proc/sys/vm/min_fre=
e_kbytes=0A=0Atic=3D$(date +'%s')=0A=0Afor i in `seq 1000`=0Ado=0A	truncate=
 -s 1G /fs/sparse-$i=0A	dd if=3D/fs/sparse-$i of=3D/dev/null &>/dev/null &=
=0Adone=0A=0Atac=3D$(date +'%s')=0Aecho start time: $((tac-tic))=0A=0Await=
=0A=0Atac=3D$(date +'%s')=0Aecho total time: $((tac-tic))=0A=0Aegrep '(nr_a=
lloc_fail|allocstall)' /proc/vmstat=0Aegrep '(CAL|RES|LOC|TLB)' /proc/inter=
rupts=0A
--qMm9M+Fa2AknHoGS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
