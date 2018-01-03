Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B874A6B032D
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 04:52:15 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id s105so541392wrc.23
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 01:52:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t11si527117wrb.289.2018.01.03.01.52.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Jan 2018 01:52:14 -0800 (PST)
Date: Wed, 3 Jan 2018 10:52:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20180103095211.GC11319@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <7dd106bd-460a-73a7-bae8-17ffe66a69ee@linux.vnet.ibm.com>
 <20180103085804.GA11319@dhcp22.suse.cz>
 <32bec0c9-60e2-0362-9446-feb4de1b119c@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32bec0c9-60e2-0362-9446-feb4de1b119c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 03-01-18 15:06:49, Anshuman Khandual wrote:
> On 01/03/2018 02:28 PM, Michal Hocko wrote:
> > On Wed 03-01-18 14:12:17, Anshuman Khandual wrote:
> >> On 12/08/2017 09:45 PM, Michal Hocko wrote:
[...]
> >>> @@ -1593,79 +1556,80 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
> >>>  			 const int __user *nodes,
> >>>  			 int __user *status, int flags)
> >>>  {
> >>> -	struct page_to_node *pm;
> >>> -	unsigned long chunk_nr_pages;
> >>> -	unsigned long chunk_start;
> >>> -	int err;
> >>> -
> >>> -	err = -ENOMEM;
> >>> -	pm = (struct page_to_node *)__get_free_page(GFP_KERNEL);
> >>> -	if (!pm)
> >>> -		goto out;
> >>> +	int chunk_node = NUMA_NO_NODE;
> >>> +	LIST_HEAD(pagelist);
> >>> +	int chunk_start, i;
> >>> +	int err = 0, err1;
> >>
> >> err init might not be required, its getting assigned to -EFAULT right away.
> > 
> > No, nr_pages might be 0 AFAICS.
> 
> Right but there is another err = 0 after the for loop.

No we have 
out_flush:
	/* Make sure we do not overwrite the existing error */
	err1 = do_move_pages_to_node(mm, &pagelist, current_node);
	if (!err1)
		err1 = store_status(status, start, current_node, i - start);
	if (!err)
		err = err1;

This is obviously not an act of beauty and probably a subject to a
cleanup but I just wanted this thing to be working first. Further
cleanups can go on top.

> > [...]
> >>> +		if (chunk_node == NUMA_NO_NODE) {
> >>> +			chunk_node = node;
> >>> +			chunk_start = i;
> >>> +		} else if (node != chunk_node) {
> >>> +			err = do_move_pages_to_node(mm, &pagelist, chunk_node);
> >>> +			if (err)
> >>> +				goto out;
> >>> +			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
> >>> +			if (err)
> >>> +				goto out;
> >>> +			chunk_start = i;
> >>> +			chunk_node = node;
> >>>  		}
> 
> [...]
> 
> >>> +		err = do_move_pages_to_node(mm, &pagelist, chunk_node);
> >>> +		if (err)
> >>> +			goto out;
> >>> +		if (i > chunk_start) {
> >>> +			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
> >>> +			if (err)
> >>> +				goto out;
> >>> +		}
> >>> +		chunk_node = NUMA_NO_NODE;
> >>
> >> This block of code is bit confusing.
> > 
> > I believe this is easier to grasp when looking at the resulting code.
> >>
> >> 1) Why attempt to migrate when just one page could not be isolated ?
> >> 2) 'i' is always greater than chunk_start except the starting page
> >> 3) Why reset chunk_node as NUMA_NO_NODE ?
> > 
> > This is all about flushing the pending state on an error and
> > distinguising a fresh batch.
> 
> Okay. Will test it out on a multi node system once I get hold of one.

Thanks. I have been testing this specific code path with the following
simple test program and numactl -m0. The code is rather crude so I've
always modified it manually to test different scenarios (this one keeps
every 1k page on the node node to test batching.
---
#include <sys/mman.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <numaif.h>

int main()
{
        unsigned long nr_pages = 10000;
        size_t length = nr_pages << 12, i;
        unsigned char *addr = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
        void *addrs[nr_pages];
        int nodes[nr_pages];
        int status[nr_pages];
        char cmd[128];
        char ch;

        if (addr == MAP_FAILED)
                return 1;

        madvise(addr, length, MADV_NOHUGEPAGE);

        for (i = 0; i < length; i += 4096)
                addr[i] = 1;
        for (i = 0; i < nr_pages; i++)
        {
                addrs[i] = &addr[i * 4096];
                if (i%1024)
                        nodes[i] = 1;
                else
                        nodes[i] = 0;
                status[i] = 0;
        }
        snprintf(cmd, sizeof(cmd)-1, "grep %lx /proc/%d/numa_maps", addr, getpid());
        system(cmd);
        snprintf(cmd, sizeof(cmd)-1, "grep %lx -A20 /proc/%d/smaps", addr, getpid());
        system(cmd);
        read(0, &ch, 1);
        if (move_pages(0, nr_pages, addrs, nodes, status, MPOL_MF_MOVE)) {
                printf("move_pages: err:%d\n", errno);
        }
        snprintf(cmd, sizeof(cmd)-1, "grep %lx /proc/%d/numa_maps", addr, getpid());
        system(cmd);
        snprintf(cmd, sizeof(cmd)-1, "grep %lx -A20 /proc/%d/smaps", addr, getpid());
        system(cmd);
        return 0;
}

---

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
