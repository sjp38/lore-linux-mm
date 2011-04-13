Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BCF69900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 07:35:36 -0400 (EDT)
Received: by bwz17 with SMTP id 17so719624bwz.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 04:35:33 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 13 Apr 2011 17:05:33 +0530
Message-ID: <BANLkTikHzq90xzK5+imnGKtc6mLNz84G-w@mail.gmail.com>
Subject: [ARM] Issue of memory compaction on kernel 2.6.35.9
From: naveen yadav <yad.naveen@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arm-kernel-request@lists.arm.linux.org.uk, linux newbie <linux.newbie79@gmail.com>

Dear all,

we want to varify compaction on ARM and we are  using 2.6.25.9 kernel
on cortex a9.

Since ARM does not have HUGETLB_PAGE support and compaction is HUGE
PAGE independent so I removed from config file

***************************************************************************=
***************************************************
# support for memory compaction
config COMPACTION
        bool "Allow for memory compaction"
        select MIGRATION
        #depends on EXPERIMENTAL && HUGETLB_PAGE && MMU
        depends on EXPERIMENTAL && MMU
   help
          Allows the compaction of memory for the allocation of huge pages.=
=09
***************************************************************************=
***************************************************
after triggering Memory Compaction by writing any value to
/proc/sys/vm/compact_memory=A0i am getting the SVC=A0mode crash
***************************************************************************=
***************************************************
#echo 1 > /proc/sys/vm/compact_memory
Unable to handle kernel paging request at virtual address ee420be4
pgd =3D d9c6c000
[ee420be4] *pgd=3D00000000
Internal error: Oops: 805 [#1] PREEMPT
last sysfs file:
Modules linked in:
CPU: 0=A0=A0=A0 Not tainted=A0 (2.6.35.9 #16)
PC is at compact_zone+0x178/0x610
LR is at compact_zone+0x138/0x610
pc : [<c009f30c>]=A0=A0=A0 lr : [<c009f2cc>]=A0=A0=A0 psr: 40000093
sp : d9d75e40=A0 ip : c0380978=A0 fp : d9d75e94
r10: d9d74000=A0 r9 : c03806c8=A0 r8 : 00069704
r7 : 00069800=A0 r6 : 00d2e080=A0 r5 : c04ea080=A0 r4 : d9d75e9c
r3 : 60000093=A0 r2 : 00000002=A0 r1 : ee420be4=A0 r0 : ee430b82
Flags: nZcv=A0 IRQs off=A0 FIQs on=A0 Mode SVC_32=A0 ISA ARM=A0 Segment us=
=09
***************************************************************************=
***************************************************


We  tried to narrow down the prob... I found crash is form
=93del_page_from_lru_list(zone, page, page_lru(page)); =94 function
isolate_migratepages

{
-----------
/* Successfully isolated */
		del_page_from_lru_list(zone, page, page_lru(page));

	--------------------------------------------------
}

In my ARM board have only one zone (Node 0, zone=A0=A0=A0Normal)

***************************************************************************=
***************************************************
VDLinux#> cat /proc/buddyinfo
Node 0, zone   Normal      5      4      4      2      1      3      0
     2  =A0=A0=A0=A0=A03=A0=A0=A0=A0=A0=A04=A0=A0=A0=A0=A0=A02=A0=A0=A0=A0=
=A0=A01=A0=A0=A0=A0=A0=A07
***************************************************************************=
***************************************************

Can some one guide why I am geeting the crash and how to debugg this proble=
m


Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
