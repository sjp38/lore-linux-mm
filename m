Subject: Re: [PATCH] mmotm:  ignore sigkill in get_user_pages during munlock
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20081204091235.1D53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
	 <1228334491.6693.82.camel@lts-notebook>
	 <20081204091235.1D53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 03 Dec 2008 20:49:43 -0500
Message-Id: <1228355383.7042.3.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-12-04 at 09:30 +0900, KOSAKI Motohiro wrote:
> > PATCH ignore sigkill in get_user_pages during munlock
> > 
> > Against:  2.6.28-rc7-mmotm-081203-0150
> > 
> > Fixes:  make-get_user_pages-interruptible.patch
> > 
> > An unfortunate side effect of "make-get_user_pages-interruptible"
> > is that it prevents a SIGKILL'd task from munlock-ing pages that it
> > had mlocked, resulting in freeing of mlocked pages.  Freeing of mlocked
> > pages, in itself, is not so bad.  We just count them now--altho' I
> > had hoped to remove this stat and add PG_MLOCKED to the free pages
> > flags check.
> > 
> > However, consider pages in shared libraries mapped by more than one
> > task that a task mlocked--e.g., via mlockall().  If the task that
> > mlocked the pages exits via SIGKILL, these pages would be left mlocked
> > and unevictable.
> 
> Indeed!
> Thank your for clarification!
> 
> Ying, I'd like to explain unevictable lru design for you a bit more.
> 
> __get_user_pages() also called exit(2) path.
> 
> do_exit()
>   exit_mm()
>     mmput()
>       exit_mmap()
>         munlock_vma_pages_all()
>           munlock_vma_pages_range()
>             __mlock_vma_pages_range()
>               __get_user_pages()
> 
> __mlock_vma_pages_range() process
>   (1) grab mlock related pages by __get_user_pages()
>   (2) isolate the page from lru
>   (3) the page move to evictable list if possible
> 
> if (1) is interupptible, the page left unevictable lru 
> although the page is not mlocked already.
> 
> 
> this feature was introduced 2.6.28-rc1. So I should noticed
> at last review, very sorry.
> 
> 
> this patch is definitly needed.
> 
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> > 
> > Proposed fix:
> > 
> > Add another GUP flag to ignore sigkill when calling get_user_pages
> > from munlock()--similar to Kosaki Motohiro's 'IGNORE_VMA_PERMISSIONS
> > flag for the same purpose.  We are not actually allocating memory in
> > this case, which "make-get_user_pages-interruptible" intends to avoid.
> > We're just munlocking pages that are already resident and mapped, and
> > we're reusing get_user_pages() to access those pages.
> > 
> > ?? Maybe we should combine 'IGNORE_VMA_PERMISSIONS and '_IGNORE_SIGKILL
> > into a single flag:  GUP_FLAGS_MUNLOCK ???
> 
> In my personal feeling, I like current two flags :)

I tend to agree with you, that the two different flags makes it clearer
what's happening.  And, we may find more reasons to ignore SIGKILL in
get_user_pages() as we test more.  I only brought up the possibility of
combining the flags as it does add code, and both flags are currently
only used by munlock.

Thanks for reviewing,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
