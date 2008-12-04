Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id mB41JZSU025623
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 17:19:35 -0800
Received: from wf-out-1314.google.com (wff29.prod.google.com [10.142.6.29])
	by spaceape11.eur.corp.google.com with ESMTP id mB41J6aq009136
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 17:19:33 -0800
Received: by wf-out-1314.google.com with SMTP id 29so3914379wff.10
        for <linux-mm@kvack.org>; Wed, 03 Dec 2008 17:19:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081204091235.1D53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
	 <1228334491.6693.82.camel@lts-notebook>
	 <20081204091235.1D53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Wed, 3 Dec 2008 17:19:32 -0800
Message-ID: <604427e00812031719o20fbd381va785913697c05483@mail.gmail.com>
Subject: Re: [PATCH] mmotm: ignore sigkill in get_user_pages during munlock
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 3, 2008 at 4:30 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> PATCH ignore sigkill in get_user_pages during munlock
>>
>> Against:  2.6.28-rc7-mmotm-081203-0150
>>
>> Fixes:  make-get_user_pages-interruptible.patch
>>
>> An unfortunate side effect of "make-get_user_pages-interruptible"
>> is that it prevents a SIGKILL'd task from munlock-ing pages that it
>> had mlocked, resulting in freeing of mlocked pages.  Freeing of mlocked
>> pages, in itself, is not so bad.  We just count them now--altho' I
>> had hoped to remove this stat and add PG_MLOCKED to the free pages
>> flags check.
>>
>> However, consider pages in shared libraries mapped by more than one
>> task that a task mlocked--e.g., via mlockall().  If the task that
>> mlocked the pages exits via SIGKILL, these pages would be left mlocked
>> and unevictable.
>
> Indeed!
> Thank your for clarification!
>
> Ying, I'd like to explain unevictable lru design for you a bit more.
>
> __get_user_pages() also called exit(2) path.
>
> do_exit()
>  exit_mm()
>    mmput()
>      exit_mmap()
>        munlock_vma_pages_all()
>          munlock_vma_pages_range()
>            __mlock_vma_pages_range()
>              __get_user_pages()
>
> __mlock_vma_pages_range() process
>  (1) grab mlock related pages by __get_user_pages()
>  (2) isolate the page from lru
>  (3) the page move to evictable list if possible
>
> if (1) is interupptible, the page left unevictable lru
> although the page is not mlocked already.

Thanks KOSAKI, that is clear now. and thanks Lee for the patch. :-)

--Ying
>
> this feature was introduced 2.6.28-rc1. So I should noticed
> at last review, very sorry.
>
>
> this patch is definitly needed.
>
>        Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
>>
>> Proposed fix:
>>
>> Add another GUP flag to ignore sigkill when calling get_user_pages
>> from munlock()--similar to Kosaki Motohiro's 'IGNORE_VMA_PERMISSIONS
>> flag for the same purpose.  We are not actually allocating memory in
>> this case, which "make-get_user_pages-interruptible" intends to avoid.
>> We're just munlocking pages that are already resident and mapped, and
>> we're reusing get_user_pages() to access those pages.
>>
>> ?? Maybe we should combine 'IGNORE_VMA_PERMISSIONS and '_IGNORE_SIGKILL
>> into a single flag:  GUP_FLAGS_MUNLOCK ???
>
> In my personal feeling, I like current two flags :)
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
