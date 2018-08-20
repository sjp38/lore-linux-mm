Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D22506B19BF
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 11:24:12 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j11-v6so13847835qtp.0
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 08:24:12 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id e20-v6si3945625wmh.0.2018.08.20.08.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 08:24:11 -0700 (PDT)
From: Christophe LEROY <christophe.leroy@c-s.fr>
Subject: Odd SIGSEGV issue introduced by commit 6b31d5955cb29 ("mm, oom: fix
 potential data corruption when oom_reaper races with writer")
Message-ID: <7767bdf4-a034-ecb9-1ac8-4fa87f335818@c-s.fr>
Date: Mon, 20 Aug 2018 17:23:58 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Ram Pai <linuxram@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>

Hello,

I have an odd issue on my powerpc 8xx board.

I am running latest 4.14 and get the following SIGSEGV which appears 
more or less randomly.

[    9.190354] touch[91]: unhandled signal 11 at 67807b58 nip 777cf114 
lr 777cf100 code 30001
[   24.634810] ifconfig[160]: unhandled signal 11 at 67ae7b58 nip 
77aaf114 lr 77aaf100 code 30001
[   30.383737] default.deconfi[231]: unhandled signal 11 at 67c8bb58 nip 
77c53114 lr 77c53100 code 30001
[   37.655588] S15syslogd[251]: unhandled signal 11 at 6784fb58 nip 
77817114 lr 77817100 code 30001
[   40.974649] snmpd[315]: unhandled signal 11 at 67e0bb58 nip 77dd3114 
lr 77dd3100 code 30001
[   43.220964] exe[338]: unhandled signal 11 at 67cd3b58 nip 77c9b114 lr 
77c9b100 code 30001
[   44.191494] exe[348]: unhandled signal 11 at 67c1fb58 nip 77be7114 lr 
77be7100 code 30001
[   59.175022] sleep[655]: unhandled signal 11 at 67ca3b58 nip 77c6b114 
lr 77c6b100 code 30001
[   61.853406] smcroute[705]: unhandled signal 11 at 6789bb58 nip 
77863114 lr 77863100 code 30001
[   64.662431] smcroute[778]: unhandled signal 11 at 67e03b58 nip 
77dcb114 lr 77dcb100 code 30001
[   65.623103] smcroute[795]: unhandled signal 11 at 67bdbb58 nip 
77ba3114 lr 77ba3100 code 30001
[   66.579416] exe[825]: unhandled signal 11 at 67edbb58 nip 77ea3114 lr 
77ea3100 code 30001
[   68.382941] exe[864]: unhandled signal 11 at 6789bb58 nip 77863114 lr 
77863100 code 30001
[   95.187346] exe[1147]: unhandled signal 11 at 67e83b58 nip 77e4b114 
lr 77e4b100 code 30001
[  105.238218] exe[1158]: unhandled signal 11 at 67ca3b58 nip 77c6b114 
lr 77c6b100 code 30001
[  127.556731] exe[1181]: unhandled signal 11 at 67cc3b58 nip 77c8b114 
lr 77c8b100 code 30001
[  135.558982] exe[1195]: unhandled signal 11 at 678d7b58 nip 7789f114 
lr 7789f100 code 30001
[  147.579142] exe[1216]: unhandled signal 11 at 67c6bb58 nip 77c33114 
lr 77c33100 code 30001
[  175.538747] exe[1262]: unhandled signal 11 at 67e2fb58 nip 77df7114 
lr 77df7100 code 30001
[  186.552670] exe[1275]: unhandled signal 11 at 6781fb58 nip 777e7114 
lr 777e7100 code 30001
[  230.629786] exe[1344]: unhandled signal 11 at 67cb3b58 nip 77c7b114 
lr 77c7b100 code 30001
[  249.640396] repair-service.[1369]: unhandled signal 11 at 67e5fb58 
nip 77e27114 lr 77e27100 code 30001
[  378.003410] exe[1593]: unhandled signal 11 at 678d7b58 nip 7789f114 
lr 7789f100 code 30001
[  414.060661] exe[1656]: unhandled signal 11 at 67cc7b58 nip 77c8f114 
lr 77c8f100 code 30001

The problem is present in 3.13, 3.14 and 3.15.

I bisected its appearance with commit 6b31d5955cb29 ("mm, oom: fix 
potential data corruption when oom_reaper races with writer")

And I bisected its disappearance with commit 99cd1302327a2 ("powerpc: 
Deliver SEGV signal on pkey violation")

Looking at those two commits, especially the one which makes it 
dissapear, I'm quite sceptic. Any idea on what could be the cause and/or 
how to investigate further ?

Thanks
Christophe
