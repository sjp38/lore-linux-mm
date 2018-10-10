Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97A806B000D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 06:44:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h37-v6so3264162pgh.4
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 03:44:35 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u8-v6si15739692plh.376.2018.10.10.03.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 03:44:34 -0700 (PDT)
Date: Wed, 10 Oct 2018 13:44:21 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] mm: brk: downgrade mmap_sem to read when shrinking
Message-ID: <20181010104420.GA15538@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linux.alibaba.com
Cc: linux-mm@kvack.org

Hello Yang Shi,

The patch ca761a3ea456: "mm: brk: downgrade mmap_sem to read when
shrinking" from Oct 4, 2018, leads to the following static checker
warning:

	mm/mmap.c:252 __do_sys_brk()
	warn: unsigned 'retval' is never less than zero.

mm/mmap.c
   223          /*
   224           * Check against rlimit here. If this check is done later after the test
   225           * of oldbrk with newbrk then it can escape the test and let the data
   226           * segment grow beyond its set limit the in case where the limit is
   227           * not page aligned -Ram Gupta
   228           */
   229          if (check_data_rlimit(rlimit(RLIMIT_DATA), brk, mm->start_brk,
   230                                mm->end_data, mm->start_data))
   231                  goto out;
   232  
   233          newbrk = PAGE_ALIGN(brk);
   234          oldbrk = PAGE_ALIGN(mm->brk);
   235          if (oldbrk == newbrk) {
   236                  mm->brk = brk;
   237                  goto success;
   238          }
   239  
   240          /*
   241           * Always allow shrinking brk.
   242           * __do_munmap() may downgrade mmap_sem to read.
   243           */
   244          if (brk <= mm->brk) {
   245                  /*
   246                   * mm->brk must to be protected by write mmap_sem so update it
   247                   * before downgrading mmap_sem. When __do_munmap() fails,
   248                   * mm->brk will be restored from origbrk.
   249                   */
   250                  mm->brk = brk;
   251                  retval = __do_munmap(mm, newbrk, oldbrk-newbrk, &uf, true);
   252                  if (retval < 0) {
                            ^^^^^^^^^^
Impossible.

   253                          mm->brk = origbrk;
   254                          goto out;
   255                  } else if (retval == 1)
   256                          downgraded = true;
   257                  goto success;
   258          }
   259  

See also:
mm/mremap.c:571 __do_sys_mremap() warn: unsigned 'ret' is never less than zero.

regards,
dan carpenter
