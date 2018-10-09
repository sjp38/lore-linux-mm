Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 604FA6B000A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 02:35:11 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id h8so388708otb.4
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 23:35:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d17-v6si9195473oic.50.2018.10.08.23.35.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 23:35:10 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w996Y5w8082358
	for <linux-mm@kvack.org>; Tue, 9 Oct 2018 02:35:09 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n0jbjs883-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Oct 2018 02:35:09 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 9 Oct 2018 07:35:06 +0100
Date: Tue, 9 Oct 2018 08:35:00 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [BUG -next 20181008] list corruption with "mm/slub: remove useless
 condition in deactivate_slab"
Message-Id: <20181009063500.GB3555@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: Quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

with linux-next for 20181008 I can reliably crash my system with lot's of
debugging options enabled on s390. List debugging triggers the list
corruption below, which I could bisect down to this commit:

fde06e07750477f049f12d7d471ffa505338a3e7 is the first bad commit
commit fde06e07750477f049f12d7d471ffa505338a3e7
Author: Pingfan Liu <kernelfans@gmail.com>
Date:   Thu Oct 4 07:43:01 2018 +1000

    mm/slub: remove useless condition in deactivate_slab

    The var l should be used to reflect the original list, on which the page
    should be.  But c->page is not on any list.  Furthermore, the current c=
ode
    does not update the value of l.  Hence remove the related logic

    Link: http://lkml.kernel.org/r/1537941430-16217-1-git-send-email-kernel=
fans@gmail.com
    Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
    Acked-by: Christoph Lameter <cl@linux.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

list_add double add: new=3D000003d1029ecc08, prev=3D000000008ff846d0,next=
=3D000003d1029ecc08.
------------[ cut here ]------------
kernel BUG at lib/list_debug.c:31!
illegal operation: 0001 ilc:1 [#1] PREEMPT SMP
Modules linked in:
CPU: 3 PID: 106 Comm: (sd-executor) Not tainted 4.19.0-rc6-00291-gfde06e077=
504 #21
Hardware name: IBM 2964 NC9 702 (z/VM 6.4.0)
Krnl PSW : (____ptrval____) (____ptrval____) (__list_add_valid+0x98/0xa8)
           R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 RI:0 EA:3
Krnl GPRS: 0000000074311fdf 0000000080000001 0000000000000058 0000000000e7b=
8b2
           0000000000000000 0000000075438c64 00000000a7b31928 001c007b00000=
000
           000000008fe99d00 00000000a7b31b40 000003d1029ecc08 00000000a7c03=
a80
           000003d1029ecc08 000000008ff84680 00000000007b5674 00000000a7c03=
960
Krnl Code: 00000000007b5668: c0200034734a        larl    %r2,e43cfc
           00000000007b566e: c0e5ffd0cf51        brasl   %r14,1cf510
          #00000000007b5674: a7f40001            brc     15,7b5676
          >00000000007b5678: a7290001            lghi    %r2,1
           00000000007b567c: ebcff0a00004        lmg     %r12,%r15,160(%r15)
           00000000007b5682: 07fe                bcr     15,%r14
           00000000007b5684: 0707                bcr     0,%r7
           00000000007b5686: 0707                bcr     0,%r7
Call Trace:
([<00000000007b5674>] __list_add_valid+0x94/0xa8)
 [<000000000037d30e>] deactivate_slab.isra.15+0x45e/0x810
 [<000000000037ede4>] ___slab_alloc+0x76c/0x7c0
 [<000000000037eeb0>] __slab_alloc.isra.16+0x78/0xa8
 [<00000000003808c8>] kmem_cache_alloc+0x160/0x458
 [<0000000000141a3a>] vm_area_dup+0x3a/0x60
 [<0000000000142f0a>] copy_process+0xd72/0x2100
 [<000000000014449a>] _do_fork+0xba/0x688
 [<0000000000144bb0>] sys_clone+0x48/0x50
 [<0000000000b8faf0>] system_call+0xd8/0x2d0
INFO: lockdep is turned off.
Last Breaking-Event-Address:
 [<00000000007b5674>] __list_add_valid+0x94/0xa8

Kernel panic - not syncing: Fatal exception: panic_on_oops
