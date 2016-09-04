Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DFB7F6B0253
	for <linux-mm@kvack.org>; Sat,  3 Sep 2016 21:49:59 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c198so85961726ith.2
        for <linux-mm@kvack.org>; Sat, 03 Sep 2016 18:49:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u139si16803359oia.99.2016.09.03.18.49.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 03 Sep 2016 18:49:59 -0700 (PDT)
Subject: Re: [RFC 2/4] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
	<1472723464-22866-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472723464-22866-3-git-send-email-mhocko@kernel.org>
Message-Id: <201609041049.JBG69723.JOFFFVOtQOLMSH@I-love.SAKURA.ne.jp>
Date: Sun, 4 Sep 2016 10:49:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9ee178ba7b71..df58733ca48e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1899,7 +1899,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * bypass the last charges so that they can exit quickly and
>  	 * free their memory.
>  	 */
> -	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
> +	if (unlikely(tsk_is_oom_victim(current) ||
>  		     fatal_signal_pending(current) ||
>  		     current->flags & PF_EXITING))
>  		goto force;

Does this test_thread_flag(TIF_MEMDIE) (or tsk_is_oom_victim(current)) make sense?

If current thread is OOM-killed, SIGKILL must be pending before arriving at
do_exit() and PF_EXITING must be set after arriving at do_exit(). But I can't
find locations which do memory allocation between clearing SIGKILL and setting
PF_EXITING.

When can test_thread_flag(TIF_MEMDIE) == T (or tsk_is_oom_victim(current) == T) &&
fatal_signal_pending(current) == F && (current->flags & PF_EXITING) == 0 happen?



> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b11977585c7b..e26529edcee3 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1078,7 +1078,7 @@ void pagefault_out_of_memory(void)
>  		 * be a racing OOM victim for which oom_killer_disable()
>  		 * is waiting for.
>  		 */
> -		WARN_ON(test_thread_flag(TIF_MEMDIE));
> +		WARN_ON(tsk_is_oom_victim(current));
>  	}
>  
>  	mutex_unlock(&oom_lock);

Does this WARN_ON() make sense?

When some user thread called oom_killer_disable(), there are running
kernel threads but is no running user threads except the one which
called oom_killer_disable(). Since oom_killer_disable() waits for
oom_lock, out_of_memory() called from here shall not return false
before oom_killer_disable() sets oom_killer_disabled = true. Thus,
possible situation out_of_memory() called from here can return false
are limited to

 (a) the one which triggered pagefaults after returning from
     oom_killer_disable()
 (b) An OOM victim which was thawed triggered pagefaults from do_exit()
     after the one which called oom_killer_disable() released oom_lock
 (c) kernel threads which triggered pagefaults after use_mm()

. And since kernel threads are not subjected to mark_oom_victim(),
test_thread_flag(TIF_MEMDIE) == F (or tsk_is_oom_victim(current) == F)
for kernel threads. Thus, possible situation out_of_memory() called from
here can return false and we hit this WARN_ON() is limited to (b).

Even if (a) or (b) is possible, does continuously emitting backtraces
help? It seems to me that the system is under OOM livelock situation and
we need to take a different action (e.g. try to allocate a page using
ALLOC_NO_WATERMARKS in order to make the pagefault be solved, and panic()
if failed) than emitting same backtraces forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
