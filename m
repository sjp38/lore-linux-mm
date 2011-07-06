Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DE3039000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 21:55:40 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8A5F03EE0C0
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 10:55:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EC5C45DE5D
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 10:55:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4054F45DE56
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 10:55:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 34816E08004
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 10:55:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E9AE71DB8053
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 10:55:36 +0900 (JST)
Date: Wed, 6 Jul 2011 10:48:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2011-06-30-15-59 uploaded
Message-Id: <20110706104817.411f45d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <201106302259.p5UMxh5i019162@imap1.linux-foundation.org>
References: <201106302259.p5UMxh5i019162@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 30 Jun 2011 15:59:43 -0700
akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-06-30-15-59 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
>    git://zen-kernel.org/kernel/mmotm.git
> or
>    git://git.cmpxchg.org/linux-mmotm.git
> 
> It contains the following patches against 3.0-rc5:
> 

==
Because of x86-implement-strict-user-copy-checks-for-x86_64.patch

At compling mm/mempolicy.c, following warning is shown.

In file included from /home/kamezawa/Kernel/mmotm-0701/arch/x86/include/asm/uaccess.h:572,
                 from include/linux/uaccess.h:5,
                 from include/linux/highmem.h:7,
                 from include/linux/pagemap.h:10,
                 from include/linux/mempolicy.h:70,
                 from mm/mempolicy.c:68:
In function ?copy_from_user?,
    inlined from ?compat_sys_get_mempolicy? at mm/mempolicy.c:1415:
.../mmotm-0701/arch/x86/include/asm/uaccess_64.h:64: warning: call to ?copy_from_user_overflow? declared with attribute warning: copy_from_user() buffer size is not provably correct
  LD      mm/built-in.o

Fix this by passing correct buffer size value.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/mempolicy.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: mmotm-0701/mm/mempolicy.c
===================================================================
--- mmotm-0701.orig/mm/mempolicy.c
+++ mmotm-0701/mm/mempolicy.c
@@ -1412,7 +1412,9 @@ asmlinkage long compat_sys_get_mempolicy
 	err = sys_get_mempolicy(policy, nm, nr_bits+1, addr, flags);
 
 	if (!err && nmask) {
-		err = copy_from_user(bm, nm, alloc_size);
+		unsigned long copy_size;
+		copy_size = min_t(unsigned long, sizeof(bm), alloc_size);
+		err = copy_from_user(bm, nm, copy_size);
 		/* ensure entire bitmap is zeroed */
 		err |= clear_user(nmask, ALIGN(maxnode-1, 8) / 8);
 		err |= compat_put_bitmap(nmask, bm, nr_bits);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
