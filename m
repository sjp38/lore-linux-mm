Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3296B01F4
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:34:08 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so688450wiv.3
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 05:34:08 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id bg4si1253901wjc.52.2014.03.20.05.34.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 05:34:07 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 20 Mar 2014 12:34:06 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2E76B17D8063
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:34:48 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2KCXqvc54263994
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:33:53 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2KCY3af016184
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 06:34:04 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 0/3] memblock: add physmem list and convert s390 to memblock
Date: Thu, 20 Mar 2014 13:33:47 +0100
Message-Id: <1395318830-7435-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tangchen@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, grygorii.strashko@ti.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

Greetings,

this is our current patch series to convert s390 to memblock.

The list of excluded memory that has been proposed by Philipp in
his patch from January is gone, it has been replaced by the list
of physically available memory. The available memory is initially
added to both the 'memory' and the 'physmem' list, but memory is
only removed from the 'memory' list. A typical use case is the
'mem=' parameter to limit the kdump kernel to a small part of the
memory while the physmem list still contains all physically
available memory.

To avoid code duplication for the physmem list the first of the
three patches refactors the memblock code a bit, with no functional
change for the existing memblock API.

The second patch adds support for the physmem list to memblock,
to enable it the option HAVE_MEMBLOCK_PHYS_MAP needs to be
selected by the architecture Kconfig file.

The third patch is the s390 conversion to memblock.

>From my point of view this code is now nice and clean and I would
like to add it to the s390 features branch in the near future.
As 3.14 is close I would suggest doing this after the next merge
window has closed.

blue skies,
  Martin.

Philipp Hachtmann (3):
  mm/memblock: Do some refactoring, enhance API
  mm/memblock: add physical memory list
  s390/mm: Convert bootmem to memblock

 arch/s390/Kconfig             |    3 +-
 arch/s390/include/asm/setup.h |   16 +-
 arch/s390/kernel/crash_dump.c |   83 ++++----
 arch/s390/kernel/early.c      |    6 +
 arch/s390/kernel/head31.S     |    1 -
 arch/s390/kernel/setup.c      |  451 +++++++++++++++--------------------------
 arch/s390/kernel/topology.c   |    4 +-
 arch/s390/mm/mem_detect.c     |  138 ++++---------
 arch/s390/mm/vmem.c           |   30 ++-
 drivers/s390/char/zcore.c     |   44 ++--
 include/linux/memblock.h      |   79 ++++++--
 mm/Kconfig                    |    3 +
 mm/memblock.c                 |  205 ++++++++++++-------
 13 files changed, 476 insertions(+), 587 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
