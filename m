Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 65E8B6B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 03:00:07 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so1272398pde.40
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 00:00:07 -0700 (PDT)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id ew3si3786399pbb.184.2014.06.25.00.00.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 00:00:06 -0700 (PDT)
Received: by mail-pb0-f46.google.com with SMTP id md12so1309269pbc.5
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 00:00:06 -0700 (PDT)
Message-ID: <1403679595.21193.13.camel@debian>
Subject: Re: [RESEND PATCH v2] mm/vmscan.c: wrap five parameters into
 writeback_stats for reducing the stack consumption
From: Chen Yucong <slaoub@gmail.com>
Date: Wed, 25 Jun 2014 14:59:55 +0800
In-Reply-To: <1402639088-4845-1-git-send-email-slaoub@gmail.com>
References: <1402639088-4845-1-git-send-email-slaoub@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2014-06-13 at 13:58 +0800, Chen Yucong wrote:
> shrink_page_list() has too many arguments that have already reached ten.
> Some of those arguments and temporary variables introduces extra 80 bytes
> on the stack. This patch wraps five parameters into writeback_stats and removes
> some temporary variables, thus making the relative functions to consume fewer
> stack space.
> 
> Before mm/vmscan.c is changed:
>    text    data     bss     dec     hex filename
> 6876698  957224  966656 8800578  864942 vmlinux-3.15
> 
> After mm/vmscan.c is changed:
>    text    data     bss     dec     hex filename
> 6876506  957224  966656 8800386  864882 vmlinux-3.15
> 
> 
> scripts/checkstack.pl can be used for checking the change of the target function stack.
> 
> Before mm/vmscan.c is changed:
> 
> 0xffffffff810af103 shrink_inactive_list []:		152
> 0xffffffff810af43d shrink_inactive_list []:		152
> -------------------------------------------------------------
> 0xffffffff810aede8 reclaim_clean_pages_from_list []:	184
> 0xffffffff810aeef8 reclaim_clean_pages_from_list []:	184
> -------------------------------------------------------------
> 0xffffffff810ae582 shrink_page_list []:			232
> 0xffffffff810aedb5 shrink_page_list []:			232
> 
> After mm/vmscan.c is changed::
> 
> 0xffffffff810af078 shrink_inactive_list []:		120
> 0xffffffff810af36d shrink_inactive_list []:		120
> -------------------------------------------------------------
> With: struct writeback_stats dummy = {};
> 0xffffffff810aed6c reclaim_clean_pages_from_list []:    152
> 0xffffffff810aee68 reclaim_clean_pages_from_list []:    152
> -------------------------------------------------------------
> With: static struct writeback_stats dummy ={};
> 0xffffffff810aed69 reclaim_clean_pages_from_list []:    120
> 0xffffffff810aee4d reclaim_clean_pages_from_list []:    120
> --------------------------------------------------------------------------------------
> 0xffffffff810ae586 shrink_page_list []:			184   ---> sub    $0xb8,%rsp
> 0xffffffff810aed36 shrink_page_list []:			184   ---> add    $0xb8,%rsp
> 
> Via the above figures, we can find that the difference value of the stack is 32 for
> shrink_inactive_list and reclaim_clean_pages_from_list, and this value is 48(232-184)
> for shrink_page_list. From the hierarchy of functions called, the total difference
> value is 80(32+48) for this change.
> 
Hi all, 

Perhaps the fix that has been done by this patch does not quite make
sense. But I still think it is necessary to explain why we should do
this.

thx!
cyc


Until now, shrink_page_list() has too many arguments that have already
reached ten. For the kernel, this is not a good thing. Not only does it
consume the stack space, but also the additional operations of the
parameters increases the code size. In addition, it will increase the
number of memory access, especially for those architectures that have
relatively small number of registers. Therefore, limiting the number of
arguments is probably a good thing.

Via historical commit messages, we can know that those arguments related
to writeback stats were introduced one by one instead of at the same
time. We can not guarantee whether some new parameters will be
introduced at some point in the future. If that happens, then relative
code must be cleaned up. Perhaps we need to make some rules for kernel
development, so that developers to know what action should be done when
there are too many arguments that will be passed.

This patch wraps five parameters into `struct writeback_stats' for
reducing the stack consumption and code size. We can also use a array
for those writeback stats, but `struct' is more clearly.


Wrapping five parameters into `writeback_stats' save 320 bytes of text.

   text    data     bss     dec     hex filename
5701904 1274800 1052672 8029376  7a84c0 vmlinux-3.15-wrap
5702224 1274800 1052672 8029696  7a8600 vmlinux-3.15

At same time, it can save 128 bytes of stack.
                                            3.15   3.15-wrap
+0/-128 -128
shrink_inactive_list                         136     120     -16
shrink_page_list                             216     168     -48
reclaim_clean_pages_from_list                184     120     -64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
