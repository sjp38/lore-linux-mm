Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E8C596B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 23:48:51 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so5987957pdi.2
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 20:48:51 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id c3si14506383pdk.33.2014.11.27.20.48.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 27 Nov 2014 20:48:50 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFQ00IV1G1A6T90@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 28 Nov 2014 13:48:46 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
References: <1417144515812.18416@xiaomi.com>
In-reply-to: <1417144515812.18416@xiaomi.com>
Subject: RE: CMA, isolate: get warning in page_isolation.c:235
 test_pages_isolated
Date: Fri, 28 Nov 2014 12:48:00 +0800
Message-id: <000001d00ac6$97f829d0$c7e87d70$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=gb2312
Content-transfer-encoding: quoted-printable
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?gb2312?B?J9bsu9Qn?= <zhuhui@xiaomi.com>, iamjoonsoo.kim@lge.com
Cc: 'Hui Zhu' <teawater@gmail.com>, linux-mm@kvack.org

> -----Original Message-----
> From: =D6=EC=BB=D4 [mailto:zhuhui@xiaomi.com]
> Sent: Friday, November 28, 2014 11:15 AM
> To: weijie.yang@samsung.com; iamjoonsoo.kim@lge.com
> Cc: Hui Zhu; linux-mm@kvack.org
> Subject: CMA, isolate: get warning in page_isolation.c:235 =
test_pages_isolated
>=20
> Hi guys,
>=20
> After I back porting your patches:
> mm/page_alloc: fix incorrect isolation behavior by rechecking =
migratetype
> mm/page_alloc: add freepage on isolate pageblock to correct buddy list
> mm/page_alloc: move freepage counting logic to __free_one_page()
> mm/page_alloc: restrict max order of merging on isolated pageblock
> mm: page_alloc: store updated page migratetype to avoid misusing stale =
value
> mm: page_isolation: check pfn validity before access

My patch is not proper, it doesn't consider the steal freepages in alloc =
path.
So it should be dropped(I will send a notice email to akpm).

I am now working on its v2 patch and will resend it soon.

Thanks

> to 3.10 linux kernel.
> I also use the CMA_AGGRESSIVE patches in =
https://lkml.org/lkml/2014/10/15/623.
>=20
> I got:
> [68121.770699@2] ------------[ cut here ]------------
> [68121.774592@2] WARNING: at =
/home/teawater/common/mm/page_isolation.c:235 =
test_pages_isolated+0x108/0x208()
> [68121.793911@2] CPU: 2 PID: 2711 Comm: kthread_xxx Tainted: P         =
  O 3.10.33-250644-gcfd93f8-dirty #184
> [68121.803632@2] [<c0016de4>] (unwind_backtrace+0x0/0x128) from =
[<c0013360>] (show_stack+0x20/0x24)
> [68121.812379@2] [<c0013360>] (show_stack+0x20/0x24) from [<c074553c>] =
(dump_stack+0x20/0x28)
> [68121.820612@2] [<c074553c>] (dump_stack+0x20/0x28) from [<c002f2b8>] =
(warn_slowpath_common+0x5c/0x7c)
> [68121.829712@2] [<c002f2b8>] (warn_slowpath_common+0x5c/0x7c) from =
[<c002f304>] (warn_slowpath_null+0x2c/0x34)
> [68121.839508@2] [<c002f304>] (warn_slowpath_null+0x2c/0x34) from =
[<c011f324>] (test_pages_isolated+0x108/0x208)
> [68121.849393@2] [<c011f324>] (test_pages_isolated+0x108/0x208) from =
[<c00e24d8>] (alloc_contig_range+0x208/0x2b0)
> [68121.859447@2] [<c00e24d8>] (alloc_contig_range+0x208/0x2b0) from =
[<c0320d44>] (dma_alloc_from_contiguous+0x15c/0x24c)
>=20
> Looks it has some race issue between page isolation and free path =
after these patches.
> And I checked the free path but found nothing.
>=20
> I worried that it still has some race issue between page isolation and =
something in upstream.  Or I missed some patches?
> If we cannot handle this issue in a short time, I suggest add the =
"move_freepages" code back to __test_page_isolated_in_pageblock.
>=20
> Thanks,
> Hui
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
