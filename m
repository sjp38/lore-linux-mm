Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 85B846B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 03:22:23 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so109017577wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 00:22:23 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id jq2si4247689wjc.180.2015.09.08.00.22.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 00:22:22 -0700 (PDT)
Date: Tue, 8 Sep 2015 09:22:20 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: fs/ocfs2/dlm/dlmrecovery.c:1824:4-23: iterator with update on
 line 1827
In-Reply-To: <55EE7C6D.3030704@huawei.com>
Message-ID: <alpine.DEB.2.10.1509080916550.2342@hadrien>
References: <201509072033.3vy462XZ%fengguang.wu@intel.com> <alpine.DEB.2.10.1509071559590.2407@hadrien> <55EE7C6D.3030704@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joseph Qi <joseph.qi@huawei.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, akpm@linux-foundation.org, linux-mm@kvack.org, kbuild@01.org

On Tue, 8 Sep 2015, Joseph Qi wrote:

> Hi Julia,
>
> On 2015/9/7 22:01, Julia Lawall wrote:
> > It looks like a serious problem, because the loop update does a
> > dereference of the first argument of list_for_each via list_entry.
> >
> Could you give more details about this? IMO, it doesn't make any
> difference in functional logic.

Do you expect that setting lock to NULL will cause a break out of the
loop?  Because it does not.  The expansion of list_for_each_entry is:

#define list_for_each_entry(pos, head, member)                          \
	for (pos = list_first_entry(head, typeof(*pos), member);        \
             &pos->member != (head);                                    \
             pos = list_next_entry(pos, member))

Since pos is NULL, &pos->member != (head), so we will take the loop
update. List_next_entry is:

#define list_next_entry(pos, member) \
        list_entry((pos)->member.next, typeof(*(pos)), member)

list_entry is container_of, which does

const typeof( ((type *)0)->member ) *__mptr = (ptr);

This causes (pos)->member.next to be evaluated, which since pos is NULL
will crash.

julia

>
> > julia
> >
> > On Mon, 7 Sep 2015, kbuild test robot wrote:
> >
> >> TO: Joseph Qi <joseph.qi@huawei.com>
> >> CC: kbuild-all@01.org
> >> CC: Andrew Morton <akpm@linux-foundation.org>
> >> CC: Linux Memory Management List <linux-mm@kvack.org>
> >>
> >> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> >> head:   7d9071a095023cd1db8fa18fa0d648dc1a5210e0
> >> commit: f83c7b5e9fd633fe91128af116e6472a8c4d29a5 ocfs2/dlm: use list_for_each_entry instead of list_for_each
> >> date:   3 days ago
> >> :::::: branch date: 33 hours ago
> >> :::::: commit date: 3 days ago
> >>
> >>>> fs/ocfs2/dlm/dlmrecovery.c:1824:4-23: iterator with update on line 1827
> >>
> >> git remote add linus git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> >> git remote update linus
> >> git checkout f83c7b5e9fd633fe91128af116e6472a8c4d29a5
> >> vim +1824 fs/ocfs2/dlm/dlmrecovery.c
> >>
> >> 6714d8e8 Kurt Hackel 2005-12-15  1818  			BUG_ON(!(mres->flags & DLM_MRES_MIGRATION));
> >> 6714d8e8 Kurt Hackel 2005-12-15  1819
> >> 34aa8dac Junxiao Bi  2014-04-03  1820  			lock = NULL;
> >> 6714d8e8 Kurt Hackel 2005-12-15  1821  			spin_lock(&res->spinlock);
> >> e17e75ec Kurt Hackel 2007-01-05  1822  			for (j = DLM_GRANTED_LIST; j <= DLM_BLOCKED_LIST; j++) {
> >> e17e75ec Kurt Hackel 2007-01-05  1823  				tmpq = dlm_list_idx_to_ptr(res, j);
> >> f83c7b5e Joseph Qi   2015-09-04 @1824  				list_for_each_entry(lock, tmpq, list) {
> >> 34aa8dac Junxiao Bi  2014-04-03  1825  					if (lock->ml.cookie == ml->cookie)
> >> 6714d8e8 Kurt Hackel 2005-12-15  1826  						break;
> >> 34aa8dac Junxiao Bi  2014-04-03 @1827  					lock = NULL;
> >> 6714d8e8 Kurt Hackel 2005-12-15  1828  				}
> >> e17e75ec Kurt Hackel 2007-01-05  1829  				if (lock)
> >> e17e75ec Kurt Hackel 2007-01-05  1830  					break;
> >>
> >> ---
> >> 0-DAY kernel test infrastructure                Open Source Technology Center
> >> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> >>
> >
> > .
> >
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
