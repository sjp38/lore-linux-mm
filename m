Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id A08836B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 16:13:16 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id t61so4229573wes.39
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:13:16 -0700 (PDT)
Received: from mail-we0-x231.google.com (mail-we0-x231.google.com [2a00:1450:400c:c03::231])
        by mx.google.com with ESMTPS id k12si6050105wjw.96.2014.05.06.13.13.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 13:13:15 -0700 (PDT)
Received: by mail-we0-f177.google.com with SMTP id x48so4158554wes.22
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:13:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140505221846.4564e04d@gandalf.local.home>
References: <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
 <1399057350-16300-1-git-send-email-ddstreet@ieee.org> <1399057350-16300-4-git-send-email-ddstreet@ieee.org>
 <20140505221846.4564e04d@gandalf.local.home>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 6 May 2014 16:12:54 -0400
Message-ID: <CALZtONAr7XGMB8LHwKRjqeEaWTEKBbwkUuP1RAZd04YQiwxrGw@mail.gmail.com>
Subject: Re: [PATCH 3/4] plist: add plist_rotate
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijieut@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, May 5, 2014 at 10:18 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Fri,  2 May 2014 15:02:29 -0400
> Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Add plist_rotate(), which moves the specified plist_node after
>> all other same-priority plist_nodes in the list.
>
> This is a little confusing? You mean it takes a plist_node from a plist
> and simply moves it to the end of the list of all other nodes of the
> same priority?

yes, exactly

> Kind of like what a sched_yield() would do with a
> SCHED_FIFO task? I wonder if we should call this "plist_yield()" then?

I suppose it is similar, yes...I'll rename it in a v2 patch.

>
>>
>> This is needed by swap, which has a plist of swap_info_structs
>> and needs to use each same-priority swap_info_struct equally.
>
> "needs to use each same-priority swap_info_struct equally"
>
> -ENOCOMPUTE

heh, yeah that needs a bit more explaining doesn't it :-)

by "equally", I mean as swap writes pages out to its swap devices, it
must write to any same-priority devices on a round-robin basis.

I'll update the comment in the v2 patch to try to explain clearer.

>
>>
>> Also add plist_test_rotate() test function, for use by plist_test()
>> to test plist_rotate() function.
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Cc: Steven Rostedt <rostedt@goodmis.org>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>>
>> ---
>>
>> This patch is new to this patch set, and it's required by the next patch,
>> which needs a way to move a plist entry to the end of all following
>> same-priority entries.  This is possible to do manually instead of adding
>> a new plist function, but having a common plist function instead of code
>> specific only to swap seems preferable.
>>
>>  include/linux/plist.h |  2 ++
>>  lib/plist.c           | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 50 insertions(+)
>>
>> diff --git a/include/linux/plist.h b/include/linux/plist.h
>> index c815491..06e6925 100644
>> --- a/include/linux/plist.h
>> +++ b/include/linux/plist.h
>> @@ -141,6 +141,8 @@ static inline void plist_node_init(struct plist_node *node, int prio)
>>  extern void plist_add(struct plist_node *node, struct plist_head *head);
>>  extern void plist_del(struct plist_node *node, struct plist_head *head);
>>
>> +extern void plist_rotate(struct plist_node *node, struct plist_head *head);
>> +
>>  /**
>>   * plist_for_each - iterate over the plist
>>   * @pos:     the type * to use as a loop counter
>> diff --git a/lib/plist.c b/lib/plist.c
>> index 1ebc95f..a8b54e5 100644
>> --- a/lib/plist.c
>> +++ b/lib/plist.c
>> @@ -134,6 +134,42 @@ void plist_del(struct plist_node *node, struct plist_head *head)
>>       plist_check_head(head);
>>  }
>>
>> +/**
>> + * plist_rotate - Rotate @node to end of same-prio entries.
>> + *
>> + * @node:    &struct plist_node pointer - entry to be moved
>> + * @head:    &struct plist_head pointer - list head
>> + */
>> +void plist_rotate(struct plist_node *node, struct plist_head *head)
>> +{
>> +     struct plist_node *next;
>> +     struct list_head *next_node_list = &head->node_list;
>
> Naming convention should be the same as plist_add() and call this
> node_next instead of next_node_list.

ok will do.

>
> -- Steve
>
>> +
>> +     plist_check_head(head);
>> +     BUG_ON(plist_head_empty(head));
>> +     BUG_ON(plist_node_empty(node));
>> +
>> +     if (node == plist_last(head))
>> +             return;
>> +
>> +     next = plist_next(node);
>> +
>> +     if (node->prio != next->prio)
>> +             return;
>> +
>> +     plist_del(node, head);
>> +
>> +     plist_for_each_continue(next, head) {
>> +             if (node->prio != next->prio) {
>> +                     next_node_list = &next->node_list;
>> +                     break;
>> +             }
>> +     }
>> +     list_add_tail(&node->node_list, next_node_list);
>> +
>> +     plist_check_head(head);
>> +}
>> +
>>  #ifdef CONFIG_DEBUG_PI_LIST
>>  #include <linux/sched.h>
>>  #include <linux/module.h>
>> @@ -170,6 +206,14 @@ static void __init plist_test_check(int nr_expect)
>>       BUG_ON(prio_pos->prio_list.next != &first->prio_list);
>>  }
>>
>> +static void __init plist_test_rotate(struct plist_node *node)
>> +{
>> +     plist_rotate(node, &test_head);
>> +
>> +     if (node != plist_last(&test_head))
>> +             BUG_ON(node->prio == plist_next(node)->prio);
>> +}
>> +
>>  static int  __init plist_test(void)
>>  {
>>       int nr_expect = 0, i, loop;
>> @@ -193,6 +237,10 @@ static int  __init plist_test(void)
>>                       nr_expect--;
>>               }
>>               plist_test_check(nr_expect);
>> +             if (!plist_node_empty(test_node + i)) {
>> +                     plist_test_rotate(test_node + i);
>> +                     plist_test_check(nr_expect);
>> +             }
>>       }
>>
>>       for (i = 0; i < ARRAY_SIZE(test_node); i++) {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
