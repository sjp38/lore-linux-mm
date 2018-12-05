Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20D4F6B715C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:24:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so8918794edr.7
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 16:24:16 -0800 (PST)
Received: from mxchg04.rrz.uni-hamburg.de (mxchg04.rrz.uni-hamburg.de. [134.100.38.114])
        by mx.google.com with ESMTPS id n20-v6si2544623ejc.171.2018.12.04.16.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 16:24:14 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
	by mxchg04.rrz.uni-hamburg.de (Postfix) with ESMTP id CF8F4B000F
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 01:24:13 +0100 (CET)
Received: from mxchg04.rrz.uni-hamburg.de ([127.0.0.1])
	by localhost (mxchg04.rrz.uni-hamburg.de [127.0.0.1]) (amavisd-new, port 10424)
	with ESMTP id w01-1sQprue5 for <linux-mm@kvack.org>;
	Wed,  5 Dec 2018 01:24:13 +0100 (CET)
Received: from mailhost.uni-hamburg.de (mailhost.uni-hamburg.de [134.100.38.99])
	by mxchg04.rrz.uni-hamburg.de (Postfix) with ESMTPS
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 01:24:13 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by mailhost.uni-hamburg.de (Postfix) with ESMTP id B8BF01F8793
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 01:24:13 +0100 (CET)
Received: from mailhost.uni-hamburg.de ([134.100.38.99])
	by localhost (mailhost.uni-hamburg.de [127.0.0.1]) (amavisd-new, port 20124)
	with LMTP id u5UGF_LrQLs5 for <linux-mm@kvack.org>;
	Wed,  5 Dec 2018 01:24:06 +0100 (CET)
Received: from klammerschelle (185-29-243-105.lsn8.wtnet.de [185.29.243.105])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: rznv039@uni-hamburg.de)
	by mailhost.uni-hamburg.de (Postfix) with ESMTPSA id 92C7D903D3
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 01:24:06 +0100 (CET)
Date: Wed, 5 Dec 2018 01:24:05 +0100
From: "Dr. Thomas Orgis" <thomas.orgis@uni-hamburg.de>
Subject: Obviously wrong values of Committed_AS on a range of kernels
Message-ID: <20181205012405.14187359@klammerschelle>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I am struggling with meaningless values of Committed_AS on a number of
Linux systems that I manage or have access to. I do wonder if this is a bug
in the kernel (certain versions or configurations) or my lack of
understanding even after reading the limited amount of code that seems
to deal with the task of counting committed memory (wherever
vm_committed_as appears).

How can it be that the kernel shows a value for Committed_AS that is
_smaller_ than the currently used memory after disregarding
cache/buffers?

An extreme example is a CentOS 7 NFS server (400 clients) that has
MemTotal-MemAvailable of 7431272K, but only Committed_AS of 655532K.
This is less than a tenth!

MemTotal:       131755776 kB
MemFree:         1403468 kB
MemAvailable:   124324504 kB
Buffers:           82352 kB
Cached:         110162312 kB
SwapCached:          156 kB
Active:         93531636 kB
Inactive:       16786948 kB
Active(anon):      53472 kB
Inactive(anon):   200004 kB
Active(file):   93478164 kB
Inactive(file): 16586944 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:      16777212 kB
SwapFree:       16754172 kB
Dirty:                16 kB
Writeback:             0 kB
AnonPages:         73772 kB
Mapped:            46068 kB
Shmem:            179556 kB
Slab:           14604768 kB
SReclaimable:   13649928 kB
SUnreclaim:       954840 kB
KernelStack:        5056 kB
PageTables:         5900 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    82655100 kB
Committed_AS:     655532 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      497836 kB
VmallocChunk:   34358947836 kB
HardwareCorrupted:     0 kB
AnonHugePages:     10240 kB
CmaTotal:              0 kB
CmaFree:               0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      150772 kB
DirectMap2M:     6031360 kB
DirectMap1G:    130023424 kB


How can the committed memory be smaller than the physically used memory?

Eeven if it is supposed to be an estimate, it should not be obviously
wrong (by an oder of magnitude), should it? I'd think that the kernel
does accurately keep track of the committed amount of memory. It for
sure looks so with the use of vm_acct_memory().

Am I missing some kernel configuration that intentionally triggers
these strangely low values for a reason? I looked at a range of systems
and found some with the same inverted relation with Committed_AS, some
with numbers that at least do not look obviously wrong. I also built a
vanilla 4.14.84 kernel loosely based on the CentOS config and booted a
compute node with it. I probably falsely remember that it also showed
the issue, but maybe I looked at the wrong system back then. Now this
node shows reasonable numbers (0.5G used, 1.8G committed), also on
fresh boot where a system with the stock kernel has too low committed
memory from the start.

For more context, please see

	https://serverfault.com/questions/942173/

where I included a list of differing systems with the relation of the
physical and virtual memory use.


Regards,

Thomas
-- 
Dr. Thomas Orgis
HPC @ Universität Hamburg
