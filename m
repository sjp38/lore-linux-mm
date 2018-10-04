Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1AF6B0269
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 14:08:18 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c16-v6so1847638wrr.8
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 11:08:18 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id h75-v6si5654807wrh.155.2018.10.04.11.08.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Oct 2018 11:08:16 -0700 (PDT)
From: Colin Ian King <colin.king@canonical.com>
Subject: re: mm: brk: downgrade mmap_sem to read when shrinking
Message-ID: <3fe71059-557b-4bab-dc88-4d0c5cfd1845@canonical.com>
Date: Thu, 4 Oct 2018 19:08:13 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

Static analysis has found a couple of issues as follows:

commit 551f205aff9198e17add1264dd781771d1a2bd9d
Author: Yang Shi <yang.shi@linux.alibaba.com>
Date:   Thu Oct 4 07:43:18 2018 +1000

    mm: brk: downgrade mmap_sem to read when shrinking

Static analysis with CoverityScan has detected an issue in mm/mmap.c,
function do_brk_flags():

                retval = __do_munmap(mm, newbrk, oldbrk-newbrk, &uf, true);
                if (retval < 0) {
                        mm->brk = origbrk;
                        goto out;
                } else if (retval == 1)
                        downgraded = true;

retval is unsigned long, so the retval < 0 check is always false, which
looks bogus to me.

Also same kind of issue with:

commit e66477708ec2a764d3add92ca59134e3812da0bb
Author: Yang Shi <yang.shi@linux.alibaba.com>
Date:   Thu Oct 4 07:43:18 2018 +1000

    mm: mremap: downgrade mmap_sem to read when shrinking

                ret = __do_munmap(mm, addr+new_len, old_len - new_len,
                                  &uf_unmap, true);
                if (ret < 0 && old_len != new_len)
                        goto out;
                /* Returning 1 indicates mmap_sem is downgraded to read. */
                else if (ret == 1)
                        downgraded = true;

again, ret is unsigned long, so the comparison with ret < 0 is always false.

Detected by CoverityScan, CID#1473794, CID#1473791 "Unsigned compared
against 0".

Colin
