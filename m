Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 4D6A76B004D
	for <linux-mm@kvack.org>; Thu,  9 May 2013 05:50:42 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id er7so1348352obc.29
        for <linux-mm@kvack.org>; Thu, 09 May 2013 02:50:41 -0700 (PDT)
From: wenchaolinux@gmail.com
Subject: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep syscall
Date: Thu,  9 May 2013 17:50:05 +0800
Message-Id: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com, Wenchao Xia <wenchaolinux@gmail.com>

From: Wenchao Xia <wenchaolinux@gmail.com>

  This serial try to enable mremap syscall to cow some private memory region,
just like what fork() did. As a result, user space application would got a
mirror of those region, and it can be used as a snapshot for further processing.

This patch is based on the commit 
a12183c62717ac4579319189a00f5883a18dff08 pulled from upstream (linux 3.9) on
2013-04-04, but I hope to sent it first to see if some case I missed to handle
correctly, will try rebase to latest upstream code in next version.

simple test code:

#define _GNU_SOURCE
#include <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main(void)
{
    int len = 4096 * 2 ;
    void *old_addr = malloc(len);
    old_addr = ((unsigned long)(old_addr + 4096) & (~0x3FF));
    printf("mapping addr %p with len %d.\n", old_addr, len);
    char *oldc = old_addr;
    oldc[0] = 0;
    oldc[1] = 1;
    oldc[2] = 2;
    oldc[3] = 3;
    void *new_addr;
    unsigned long new_addr_l;
    new_addr = mremap(old_addr, len, 0, 4);
    printf("result new addr %lx %p.\n", new_addr_l, new_addr);
    char *newc = new_addr;
    printf("old value is 0x%lx.\n", *((unsigned long *)oldc));
    printf("new value is 0x%lx.\n", *((unsigned long *)newc));
    newc[0] = 6;
    printf("old value is 0x%lx.\n", *((unsigned long *)oldc));
    printf("new value is 0x%lx.\n", *((unsigned long *)newc));
    oldc[0] = 9;
    printf("old value is 0x%lx.\n", *((unsigned long *)oldc));
    printf("new value is 0x%lx.\n", *((unsigned long *)newc));
    assert(0 == munmap(new_addr, len));

}

Wenchao Xia (6):
  mm: add parameter remove_old in move_huge_pmd()
  mm : allow copy between different addresses for copy_one_pte()
  mm : export rss vec helper functions
  mm : export is_cow_mapping()
  mm : add parameter remove_old in move_page_tables
  mm : add new option MREMAP_DUP to mremap() syscall

 fs/exec.c                 |    2 +-
 include/linux/huge_mm.h   |    2 +-
 include/linux/mm.h        |    9 ++-
 include/uapi/linux/mman.h |    1 +
 mm/huge_memory.c          |    6 +-
 mm/memory.c               |   33 ++++----
 mm/mremap.c               |  200 +++++++++++++++++++++++++++++++++++++++++++--
 7 files changed, 224 insertions(+), 29 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
