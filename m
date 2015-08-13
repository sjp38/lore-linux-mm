Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1F76B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 19:49:00 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so47123039pac.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 16:49:00 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id bz4si5936419pbd.70.2015.08.13.16.48.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Aug 2015 16:48:59 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [mmotm:master 301/497] mm/hugetlb.c:2812:4: warning: format
 '%d' expects argument of type 'int', but argument 4 has type 'long unsigned
 int'
Date: Thu, 13 Aug 2015 23:47:09 +0000
Message-ID: <20150813234708.GA1747@hori1.linux.bs1.fc.nec.co.jp>
References: <201508140738.rYMKweKI%fengguang.wu@intel.com>
In-Reply-To: <201508140738.rYMKweKI%fengguang.wu@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9A8E426732338D4A8591C3A890FB3B7A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Aug 14, 2015 at 07:37:39AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   f6a6014bf6b3c724cff30194681f219ac230c898
> commit: b1e17e02f94bd2dec7547553e3cc5330f497193c [301/497] mm: hugetlb: p=
roc: add HugetlbPages field to /proc/PID/status
> config: i386-randconfig-i1-201532 (attached as .config)
> reproduce:
>   git checkout b1e17e02f94bd2dec7547553e3cc5330f497193c
>   # save the attached .config to linux build tree
>   make ARCH=3Di386=20
>=20
> All warnings (new ones prefixed by >>):
>=20
>    mm/hugetlb.c: In function 'hugetlb_report_usage':
> >> mm/hugetlb.c:2812:4: warning: format '%d' expects argument of type 'in=
t', but argument 4 has type 'long unsigned int' [-Wformat=3D]
>        huge_page_size(&hstates[i]) >> 10);
>        ^
>=20
> vim +2812 mm/hugetlb.c
>=20
>   2796		unsigned long total_usage =3D 0;
>   2797=09
>   2798		for (i =3D 0; i < HUGE_MAX_HSTATE; i++) {
>   2799			total_usage +=3D atomic_long_read(&mm->hugetlb_usage.count[i]) *
>   2800				(huge_page_size(&hstates[i]) >> 10);
>   2801		}
>   2802=09
>   2803		seq_printf(m, "HugetlbPages:\t%8lu kB (", total_usage);
>   2804		for (i =3D 0; i < HUGE_MAX_HSTATE; i++) {
>   2805			if (huge_page_order(&hstates[i]) =3D=3D 0)
>   2806				break;
>   2807			if (i > 0)
>   2808				seq_puts(m, " ");
>   2809=09
>   2810			seq_printf(m, "%ldx%dkB",
>   2811				atomic_long_read(&mm->hugetlb_usage.count[i]),
> > 2812				huge_page_size(&hstates[i]) >> 10);

huge_page_size() return type unsigned long, so I should've used "%lu".

Thanks,
Naoya Horiguchi
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2338c9713b7a..92ecd41c5e5a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2579,7 +2579,7 @@ void hugetlb_report_usage(struct seq_file *m, struct =
mm_struct *mm)
 		if (i > 0)
 			seq_puts(m, " ");
=20
-		seq_printf(m, "%ld*%dkB",
+		seq_printf(m, "%ld*%lukB",
 			atomic_long_read(&mm->hugetlb_usage.count[i]),
 			huge_page_size(&hstates[i]) >> 10);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
