Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 493216B3C67
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 15:18:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r14-v6so5957947wmh.0
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 12:18:42 -0700 (PDT)
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id q18-v6si11056506wrg.14.2018.08.26.12.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 Aug 2018 12:18:40 -0700 (PDT)
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: kvm / buddyinfo compact_memory and high I/O waits
Message-ID: <dbfba28b-fee4-e4fb-8b9c-557ab33e4b3c@profihost.ag>
Date: Sun, 26 Aug 2018 21:18:39 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

i'm observing i strange situation where i would be happy to get some
help or some hints. I hope mm can point me to the right direction.

On a KVM host i'm seeing very high i/o waits while no local disks are in
use at all. First i thought it is swap related but instead i'm able to
trigger it with echo 1 >/proc/sys/vm/compact_memory . So every time the
kernel things it needs to compact memory a lot of VMs got stalled (no
answer to ping anymore) and i see high i/o waits (40%-70%).

# free -m
              total        used        free      shared  buff/cache
available
Mem:         643641      429948      212067         114        1625
209630
Swap:          7629        3383        4246

Brefore compact:
# cat /proc/buddyinfo
Node 0, zone      DMA      1      1      0      0      2      1      1
   0      1      1      3
Node 0, zone    DMA32    109     93     64     45     37     25      5
   4      1      3    402
Node 0, zone   Normal    526    306     35      3      6   3561   4467
4188   3778   6159  40244
Node 1, zone   Normal 192307  13290   2781    794    209     95    504
 532    511    671   6743

After compact:
# cat /proc/buddyinfo
Node 0, zone      DMA      1      1      0      0      2      1      1
   0      1      1      3
Node 0, zone    DMA32    109     93     64     45     37     25      5
   4      1      3    402
Node 0, zone   Normal   1019    482    117    354     79     43     28
 196    226   3719  43219
Node 1, zone   Normal  24093   1537    627    271    131     79     39
  18    109    707   7009

After 5 min after compact:
# cat /proc/buddyinfo
Node 0, zone      DMA      1      1      0      0      2      1      1
   0      1      1      3
Node 0, zone    DMA32    109     93     64     45     37     25      5
   4      1      3    402
Node 0, zone   Normal    742    319     44     89     44     14     10
  29    220   3604  43302
Node 1, zone   Normal  34186   5735   1363    409    170     91     42
  21    110    597   7033

Not sure if it is related but i'm running ksmd as well.

Thanks a lot!

Greets,
Stefan
