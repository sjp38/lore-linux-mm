Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F09996B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 12:12:56 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id z6so93177587pgc.13
        for <linux-mm@kvack.org>; Mon, 15 May 2017 09:12:56 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0131.outbound.protection.outlook.com. [104.47.2.131])
        by mx.google.com with ESMTPS id t21si10855893pfg.153.2017.05.15.09.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 15 May 2017 09:12:55 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH 1/1] ksm: fix use after free with merge_across_nodes = 0
References: <20170512193805.8807-1-aarcange@redhat.com>
 <20170512193805.8807-2-aarcange@redhat.com>
Message-ID: <359799de-6afa-8385-1573-4ea45625eac8@virtuozzo.com>
Date: Mon, 15 May 2017 19:14:36 +0300
MIME-Version: 1.0
In-Reply-To: <20170512193805.8807-2-aarcange@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Evgheni Dereveanchin <ederevea@redhat.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Arjan van de Ven <arjan@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Gavin Guo <gavin.guo@canonical.com>, Jay Vosburgh <jay.vosburgh@canonical.com>, Mel Gorman <mgorman@techsingularity.net>

On 05/12/2017 10:38 PM, Andrea Arcangeli wrote:
> If merge_across_nodes was manually set to 0 (not the default value) by
> the admin or a tuned profile on NUMA systems triggering cross-NODE
> page migrations, a stable_node use after free could materialize.
> 
> If the chain is collapsed stable_node would point to the old chain
> that was already freed. stable_node_dup would be the stable_node dup
> now converted to a regular stable_node and indexed in the rbtree in
> replacement of the freed stable_node chain (not anymore a dup).
> 
> This special case where the chain is collapsed in the NUMA replacement
> path, is now detected by setting stable_node to NULL by the
> chain_prune callee if it decides to collapse the chain. This tells the
> NUMA replacement code that even if stable_node and stable_node_dup are
> different, this is not a chain if stable_node is NULL, as the
> stable_node_dup was converted to a regular stable_node and the chain
> was collapsed.
> 
> It is generally safer for the callee to force the caller stable_node
> to NULL the moment it become stale so any other mistake like this
> would result in an instant Oops easier to debug than an use after free.
> 
> Otherwise the replace logic would act like if stable_node was a valid
> chain, when in fact it was freed. Notably
> stable_node_chain_add_dup(page_node, stable_node) would run on a
> stable stable_node.
> 
> Andrey Ryabinin found the source of the use after free in
> chain_prune().
> 
> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reported-by: Evgheni Dereveanchin <ederevea@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---


Works for me,

Tested-by: Andrey Ryabinin <aryabinin@virtuozzo.com>


Bellow is reproducer which causes crash in ksm in several minutes without this fix.


$ cat  ksm_test.c

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <numaif.h>
#include <sys/types.h>
#include <sys/wait.h>

#define NR_NODES 4
#define MAP_SIZE 4096

#define NR_THREADS 1024

pid_t pids[NR_THREADS];

int merge_and_migrate(void)
{
        void *p;
        unsigned long rnd;
        unsigned long old_node, new_node;
        pid_t p_pid, pid;
        int j;

        p = mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE,
                MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
        if (p == MAP_FAILED)
                perror("mmap"), exit(1);

        memset(p, 0xff, MAP_SIZE);
        if (madvise(p, MAP_SIZE, MADV_MERGEABLE))
                perror("madvise"), exit(1);


        while (1) {
                sleep(0);
                rnd = rand() % 2;
                switch (rnd) {
                case 0: {
                        rnd = rand() % 128;
                        memset(p, rnd, MAP_SIZE);
                        break;
                }
                case 1: {
                        j = rand()%NR_NODES;
                        old_node = 1 << j;
                        new_node = 1<<((j+1)%NR_NODES);

                        migrate_pages(0, NR_NODES, &old_node, &new_node);
                        break;
                }
                }
        }
        return 0;
}

int main(void)
{
        int i,ret,j;
        pid_t pid;
        int wstatus;
        unsigned long old_node, new_node;

        for (i = 0; i < NR_THREADS; i++) {
                pid = fork();
                if (pid < 0) {
                        perror("fork");
                        return 1;
                }
                if (pid) {
                        pids[i] = pid;
                        continue;
                } else
                        merge_and_migrate();
        }

        while (1) {
                pid = waitpid(-1, &wstatus, WNOHANG);
                if (pid < 0) {
                        perror("waitpid failed");
                        return 1;
                }
                if (pid) {
                        for (i = 0; i< NR_THREADS; i++) {
                                if (pids[i] == pid) {
                                        pid = fork();
                                        if (pid < 0) {
                                                perror("fork in while");
                                                return 1;
                                        }
                                        if (pid) {
                                                pids[i] = pid;
                                                break;
                                        } else
                                                merge_and_migrate();
                                }
                        }
                        continue; /*while(1)*/
                }
                i = rand()%NR_THREADS;
                kill(pids[i], SIGKILL);
        }
        return 0;
}

$ cat run_ksm.sh
#!/bin/bash

gcc -lnuma -O2 ksm_test.c -o ksm_test
echo 1 > /sys/kernel/mm/ksm/run
echo 0 > /sys/kernel/mm/ksm/merge_across_nodes
echo 2 > /sys/kernel/mm/ksm/max_page_sharing
echo 0 > /sys/kernel/mm/ksm/stable_node_chains_prune_millisecs
./ksm_test


$ ./run_ksm.sh
[  203.251200] ==================================================================
[  203.251679] BUG: KASAN: use-after-free in stable_tree_search+0x1450/0x16f0
[  203.252229] Read of size 4 at addr ffff880037e9d938 by task ksmd/170
[  203.252800] 
[  203.252957] CPU: 2 PID: 170 Comm: ksmd Not tainted 4.12.0-rc1-next-20170515+ #639
[  203.253627] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
[  203.254670] Call Trace:
[  203.254907]  dump_stack+0x67/0x98
[  203.255222]  print_address_description+0x7c/0x290
[  203.255652]  ? stable_tree_search+0x1450/0x16f0
[  203.256073]  kasan_report+0x26e/0x350
[  203.256418]  __asan_report_load4_noabort+0x19/0x20
[  203.256852]  stable_tree_search+0x1450/0x16f0
[  203.257262]  ? __stable_node_chain+0x8a0/0x8a0
[  203.257668]  ? follow_page_mask+0x5f9/0xd80
[  203.258060]  ksm_scan_thread+0xb47/0x2790
[  203.258438]  ? stable_tree_search+0x16f0/0x16f0
[  203.258858]  ? __schedule+0x904/0x1ad0
[  203.259214]  ? clkdev_alloc+0xd0/0xd0
[  203.259553]  ? wake_atomic_t_function+0x2a0/0x2a0
[  203.259985]  ? trace_hardirqs_on+0xd/0x10
[  203.260361]  kthread+0x2d6/0x3d0
[  203.260658]  ? stable_tree_search+0x16f0/0x16f0
[  203.261073]  ? kthread_create_on_node+0xb0/0xb0
[  203.261485]  ret_from_fork+0x2e/0x40
[  203.261819] 
[  203.261936] Allocated by task 170:
[  203.262251]  save_stack_trace+0x1b/0x20
[  203.262601]  kasan_kmalloc+0xee/0x180
[  203.262938]  kasan_slab_alloc+0x12/0x20
[  203.263290]  kmem_cache_alloc+0x129/0x2d0
[  203.263654]  alloc_stable_node_chain+0x29/0x310
[  203.264072]  ksm_scan_thread+0x2048/0x2790
[  203.264444]  kthread+0x2d6/0x3d0
[  203.264744]  ret_from_fork+0x2e/0x40
[  203.265075] 
[  203.265220] Freed by task 170:
[  203.265503]  save_stack_trace+0x1b/0x20
[  203.265852]  kasan_slab_free+0xad/0x180
[  203.266208]  kmem_cache_free+0xc7/0x300
[  203.266558]  __stable_node_chain+0x68a/0x8a0
[  203.266948]  stable_tree_search+0x18e/0x16f0
[  203.267339]  ksm_scan_thread+0xb47/0x2790
[  203.267655]  kthread+0x2d6/0x3d0
[  203.267910]  ret_from_fork+0x2e/0x40





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
