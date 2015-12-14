Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id CB3606B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:19:30 -0500 (EST)
Received: by lbpu9 with SMTP id u9so107320538lbp.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:19:30 -0800 (PST)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id b66si17884565lfe.249.2015.12.14.12.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 12:19:29 -0800 (PST)
Received: by lbbkw15 with SMTP id kw15so114014820lbb.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:19:29 -0800 (PST)
MIME-Version: 1.0
From: Martin Tippmann <martin.tippmann@gmail.com>
Date: Mon, 14 Dec 2015 21:19:09 +0100
Message-ID: <CABL_Pd8xJny4h01TZ05Cd0qeWHfeAz1Eaqoz2ceWCbr2wFTdUA@mail.gmail.com>
Subject: Bug Report: BUG: Bad rss-counter state mm:ffff88101705f800 idx:1
 val:512 / application segfaults / thp
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I'm seeing random application crashes (SIGSEV) and after a few minutes
this appears in the logfiles:

[133933.729199]
/build/linux-lts-wily-4x6IId/linux-lts-wily-4.2.0/mm/pgtable-generic.c:33:
bad pmd ffff880fd06d6200(000000018da009e2)
[133933.763015] BUG: Bad rss-counter state mm:ffff88101705f800 idx:1 val:512
[133933.763039] BUG: non-zero nr_ptes on freeing mm: 1

I'm quite certain that it's not a hardware error. The problems appears
regularly on random machines of a 100+ machine cluster of Dell
PowerEdge R720 servers with 2xXeon E5 (NUMA) and 64GB ECC Memory.

The workload is mostly Hadoop YARN with MapReduce and Spark, the JVM
(mostly from the DataNodes) crashes randomly under load with SIGSEV.

The problems appears with Kernel 4.3.0 and 4.2.7 from Ubuntu Kernel
Mainline PPA[1] and with the current 4.2 Ubuntu Wily Kernel - all of
these kernels already have a related patch[2].

However I'm still seeing the problem. The bug disappears when I
disable transparent hugepages and reboot the machines!

Before disabling transparent hugepages completely I ran this config:

   echo always > /sys/kernel/mm/transparent_hugepage/enabled
   echo never > /sys/kernel/mm/transparent_hugepage/defrag

Unfortunately I can't provide any more data at the moment. Maybe I'm
able to compile a kernel with debug options turned on over the
holidays - if you have any hints where I can help to pin this down
please tell me. On IRC
CONFIG_DEBUG_VM was recommend.

regards and thanks
Martin

1: http://kernel.ubuntu.com/~kernel-ppa/mainline/?C=M;O=D
2: https://kernel.googlesource.com/pub/scm/linux/kernel/git/stable/linux-stable.git/+/47aee4d8e314384807e98b67ade07f6da476aa75

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
