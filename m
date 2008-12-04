Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB40UjO8014117
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 09:30:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 74CC245DE54
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 09:30:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 513B445DE52
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 09:30:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27C1F1DB8037
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 09:30:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C95941DB803B
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 09:30:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mmotm:  ignore sigkill in get_user_pages during munlock
In-Reply-To: <1228334491.6693.82.camel@lts-notebook>
References: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com> <1228334491.6693.82.camel@lts-notebook>
Message-Id: <20081204091235.1D53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 09:30:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

> PATCH ignore sigkill in get_user_pages during munlock
> 
> Against:  2.6.28-rc7-mmotm-081203-0150
> 
> Fixes:  make-get_user_pages-interruptible.patch
> 
> An unfortunate side effect of "make-get_user_pages-interruptible"
> is that it prevents a SIGKILL'd task from munlock-ing pages that it
> had mlocked, resulting in freeing of mlocked pages.  Freeing of mlocked
> pages, in itself, is not so bad.  We just count them now--altho' I
> had hoped to remove this stat and add PG_MLOCKED to the free pages
> flags check.
> 
> However, consider pages in shared libraries mapped by more than one
> task that a task mlocked--e.g., via mlockall().  If the task that
> mlocked the pages exits via SIGKILL, these pages would be left mlocked
> and unevictable.

Indeed!
Thank your for clarification!

Ying, I'd like to explain unevictable lru design for you a bit more.

__get_user_pages() also called exit(2) path.

do_exit()
  exit_mm()
    mmput()
      exit_mmap()
        munlock_vma_pages_all()
          munlock_vma_pages_range()
            __mlock_vma_pages_range()
              __get_user_pages()

__mlock_vma_pages_range() process
  (1) grab mlock related pages by __get_user_pages()
  (2) isolate the page from lru
  (3) the page move to evictable list if possible

if (1) is interupptible, the page left unevictable lru 
although the page is not mlocked already.


this feature was introduced 2.6.28-rc1. So I should noticed
at last review, very sorry.


this patch is definitly needed.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 
> Proposed fix:
> 
> Add another GUP flag to ignore sigkill when calling get_user_pages
> from munlock()--similar to Kosaki Motohiro's 'IGNORE_VMA_PERMISSIONS
> flag for the same purpose.  We are not actually allocating memory in
> this case, which "make-get_user_pages-interruptible" intends to avoid.
> We're just munlocking pages that are already resident and mapped, and
> we're reusing get_user_pages() to access those pages.
> 
> ?? Maybe we should combine 'IGNORE_VMA_PERMISSIONS and '_IGNORE_SIGKILL
> into a single flag:  GUP_FLAGS_MUNLOCK ???

In my personal feeling, I like current two flags :)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
