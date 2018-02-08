Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BC6A6B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 01:30:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t14so1882593wmc.5
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 22:30:05 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id a141si2230927wma.13.2018.02.07.22.30.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Feb 2018 22:30:04 -0800 (PST)
Received: from mail-pl0-f72.google.com ([209.85.160.72])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <kai.heng.feng@canonical.com>)
	id 1ejfid-0003Ao-6L
	for linux-mm@kvack.org; Thu, 08 Feb 2018 06:30:03 +0000
Received: by mail-pl0-f72.google.com with SMTP id l3-v6so1211627pld.8
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 22:30:03 -0800 (PST)
From: Kai Heng Feng <kai.heng.feng@canonical.com>
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.9\))
Subject: Regression after commit 19809c2da28a ("mm, vmalloc: use __GFP_HIGHMEM
 implicitly")
Message-Id: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
Date: Thu, 8 Feb 2018 14:29:57 +0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Laura Abbott <labbott@redhat.com>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

A user with i386 instead of AMD64 machine reports [1] that commit =
19809c2da28a ("mm, vmalloc: use __GFP_HIGHMEM implicitly=E2=80=9D) =
causes a regression.
BUG_ON(PageHighMem(pg)) in drivers/media/common/saa7146/saa7146_core.c =
always gets triggered after that commit.

Commit 704b862f9efd ("mm/vmalloc.c: don't unconditonally use =
__GFP_HIGHMEM=E2=80=9D) adjusts the mask logic, now the __GFP_HIGHMEM =
only gets applied when there is no GFP_DMA or GFP_DMA32.

So I tried to adjust its malloc to "__vmalloc(nr_pages * sizeof(struct =
scatterlist), GFP_KERNEL | GFP_DMA | __GFP_ZERO, PAGE_KERNEL)=E2=80=9D, =
but both GFP_DMA or GFP_DMA32 still trigger the BUG_ON(PageHighMem()) =
macro.

Also there are other BUG_ON(PageHighMem()) in drivers/media, I think =
they will get hit by same regression in 32bit machine too.

[1] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1742316

Kai-Heng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
