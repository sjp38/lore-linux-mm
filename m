From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: possible deadlock in __do_page_fault
Date: Mon, 28 Jan 2019 11:45:02 -0500
Message-ID: <20190128164502.GA260885@google.com>
References: <201901230201.x0N214eq043832@www262.sakura.ne.jp>
 <20190123155751.GA168927@google.com>
 <201901240152.x0O1qUUU069046@www262.sakura.ne.jp>
 <20190124134646.GA53008@google.com>
 <d736c8f5-eba1-2da8-000f-4b2a80ad74ff@i-love.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d736c8f5-eba1-2da8-000f-4b2a80ad74ff@i-love.sakura.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Todd Kjos <tkjos@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>, jack@suse.cz, jrdr.linux@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
List-Id: linux-mm.kvack.org

On Sat, Jan 26, 2019 at 01:02:06AM +0900, Tetsuo Handa wrote:
> On 2019/01/24 22:46, Joel Fernandes wrote:
> > On Thu, Jan 24, 2019 at 10:52:30AM +0900, Tetsuo Handa wrote:
> >> Joel Fernandes wrote:
> >>>> Anyway, I need your checks regarding whether this approach is waiting for
> >>>> completion at all locations which need to wait for completion.
> >>>
> >>> I think you are waiting in unwanted locations. The only location you need to
> >>> wait in is ashmem_pin_unpin.
> >>>
> >>> So, to my eyes all that is needed to fix this bug is:
> >>>
> >>> 1. Delete the range from the ashmem_lru_list
> >>> 2. Release the ashmem_mutex
> >>> 3. fallocate the range.
> >>> 4. Do the completion so that any waiting pin/unpin can proceed.
> >>>
> >>> Could you clarify why you feel you need to wait for completion at those other
> >>> locations?
> 
> OK. Here is an updated patch.
> Passed syzbot's best-effort testing using reproducers on all three reports.
> 
> From f192176dbee54075d41249e9f22918c32cb4d4fc Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 25 Jan 2019 23:43:01 +0900
> Subject: [PATCH] staging: android: ashmem: Don't call fallocate() with ashmem_mutex held.
> 
> syzbot is hitting lockdep warnings [1][2][3]. This patch tries to fix
> the warning by eliminating ashmem_shrink_scan() => {shmem|vfs}_fallocate()
> sequence.
> 
> [1] https://syzkaller.appspot.com/bug?id=87c399f6fa6955006080b24142e2ce7680295ad4
> [2] https://syzkaller.appspot.com/bug?id=7ebea492de7521048355fc84210220e1038a7908
> [3] https://syzkaller.appspot.com/bug?id=e02419c12131c24e2a957ea050c2ab6dcbbc3270
> 
> Reported-by: syzbot <syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com>
> Reported-by: syzbot <syzbot+148c2885d71194f18d28@syzkaller.appspotmail.com>
> Reported-by: syzbot <syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  drivers/staging/android/ashmem.c | 23 ++++++++++++++++++-----
>  1 file changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
> index 90a8a9f..d40c1d2 100644
> --- a/drivers/staging/android/ashmem.c
> +++ b/drivers/staging/android/ashmem.c
> @@ -75,6 +75,9 @@ struct ashmem_range {
>  /* LRU list of unpinned pages, protected by ashmem_mutex */
>  static LIST_HEAD(ashmem_lru_list);
>  
> +static atomic_t ashmem_shrink_inflight = ATOMIC_INIT(0);
> +static DECLARE_WAIT_QUEUE_HEAD(ashmem_shrink_wait);
> +
>  /*
>   * long lru_count - The count of pages on our LRU list.
>   *
> @@ -438,7 +441,6 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
>  static unsigned long
>  ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
> -	struct ashmem_range *range, *next;
>  	unsigned long freed = 0;
>  
>  	/* We might recurse into filesystem code, so bail out if necessary */
> @@ -448,17 +450,27 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
>  	if (!mutex_trylock(&ashmem_mutex))
>  		return -1;
>  
> -	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
> +	while (!list_empty(&ashmem_lru_list)) {
> +		struct ashmem_range *range =
> +			list_first_entry(&ashmem_lru_list, typeof(*range), lru);
>  		loff_t start = range->pgstart * PAGE_SIZE;
>  		loff_t end = (range->pgend + 1) * PAGE_SIZE;
> +		struct file *f = range->asma->file;
>  
> -		range->asma->file->f_op->fallocate(range->asma->file,
> -				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> -				start, end - start);
> +		get_file(f);
> +		atomic_inc(&ashmem_shrink_inflight);
>  		range->purged = ASHMEM_WAS_PURGED;
>  		lru_del(range);
>  
>  		freed += range_size(range);
> +		mutex_unlock(&ashmem_mutex);
> +		f->f_op->fallocate(f,
> +				   FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> +				   start, end - start);
> +		fput(f);
> +		if (atomic_dec_and_test(&ashmem_shrink_inflight))
> +			wake_up_all(&ashmem_shrink_wait);
> +		mutex_lock(&ashmem_mutex);

Let us replace mutex_lock with mutex_trylock, as done before the loop? Here
is there is an opportunity to not block other ashmem operations. Otherwise
LGTM. Also, CC stable.

thanks,

 - Joel
