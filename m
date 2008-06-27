Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id m5RFbaZg017922
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 16:37:36 +0100
Received: from wr-out-0506.google.com (wri67.prod.google.com [10.54.9.67])
	by spaceape7.eur.corp.google.com with ESMTP id m5RFbZmP006220
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 16:37:35 +0100
Received: by wr-out-0506.google.com with SMTP id 67so491923wri.3
        for <linux-mm@kvack.org>; Fri, 27 Jun 2008 08:37:35 -0700 (PDT)
Message-ID: <6599ad830806270837t5f9df61cn665a88d3dd8746d4@mail.gmail.com>
Date: Fri, 27 Jun 2008 08:37:34 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC 3/5] Replacement policy on heap overfull
In-Reply-To: <20080627151838.31664.51492.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
	 <20080627151838.31664.51492.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 27, 2008 at 8:18 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>
> This patch adds a policy parameter to heap_insert. While inserting an element
> if the heap is full, the policy determines which element to replace.
> The default earlier is now obtained by passing the policy as HEAP_REP_TOP.
> The new HEAP_REP_LEAF policy, replaces a leaf node (the last element).
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
>
>  include/linux/prio_heap.h |    9 ++++++++-
>  kernel/cgroup.c           |    2 +-
>  lib/prio_heap.c           |   31 +++++++++++++++++++++++--------
>  3 files changed, 32 insertions(+), 10 deletions(-)
>
> diff -puN include/linux/prio_heap.h~prio_heap_replace_leaf include/linux/prio_heap.h
> --- linux-2.6.26-rc5/include/linux/prio_heap.h~prio_heap_replace_leaf   2008-06-27 20:43:09.000000000 +0530
> +++ linux-2.6.26-rc5-balbir/include/linux/prio_heap.h   2008-06-27 20:43:09.000000000 +0530
> @@ -22,6 +22,11 @@ struct ptr_heap {
>        int (*gt)(void *, void *);
>  };
>
> +enum heap_replacement_policy {
> +       HEAP_REP_LEAF,
> +       HEAP_REP_TOP,
> +};

Maybe "drop" rather than "replace"? HEAP_REP_TOP doesn't replace the
top element if you insert a new higher element, it drops the top.

How about HEAP_DROP_LEAF and HEAP_DROP_MAX? You could also provide a
HEAP_DROP_MIN with the caveat that it would take linear time.

Add comments here about what these mean?

> +       if (policy == HEAP_REP_TOP)

switch() here?

> +               if (heap->gt(p, ptrs[0]))
> +                       return p;
> +
> +       if (policy == HEAP_REP_LEAF) {
> +               /* Heap insertion */
> +               int pos = heap->size - 1;
> +               res = ptrs[pos];
> +               heap_insert_at(heap, p, pos);
> +               return res;
> +       }
>
>        /* Replace the current max and heapify */
>        res = ptrs[0];

This should probably be in the arm dealing with
HEAP_REP_TOP/HEAP_DROP_MAX since we only get here in that case.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
