Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 1F76A6B00E8
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 02:34:32 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so5241095bkw.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 23:34:30 -0700 (PDT)
Message-ID: <4F83D470.6010207@openvz.org>
Date: Tue, 10 Apr 2012 10:34:24 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: sync rss-counters at the end of exit_mm()
References: <20120409200336.8368.63793.stgit@zurg> <CAHGf_=oWj-hz-E5ht8-hUbQKdsZ1bzP80n987kGYnFm8BpXBVQ@mail.gmail.com> <alpine.LSU.2.00.1204091433380.1859@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204091433380.1859@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Markus Trippelsdorf <markus@trippelsdorf.de>

Hugh Dickins wrote:
> On Mon, 9 Apr 2012, KOSAKI Motohiro wrote:
>> On Mon, Apr 9, 2012 at 4:03 PM, Konstantin Khlebnikov
>> <khlebnikov@openvz.org>  wrote:
>>> On task's exit do_exit() calls sync_mm_rss() but this is not enough,
>>> there can be page-faults after this point, for example exit_mm() ->
>>> mm_release() ->  put_user() (for processing tsk->clear_child_tid).
>>> Thus there may be some rss-counters delta in current->rss_stat.
>>
>> Seems reasonable.
>
> Yes, I think Konstantin has probably caught it;
> but I'd like to hear confirmation from Markus.

There is another bug in exec_mmap()

--- a/fs/exec.c
+++ b/fs/exec.c
@@ -823,8 +823,8 @@ static int exec_mmap(struct mm_struct *mm)
         /* Notify parent that we're no longer interested in the old VM */
         tsk = current;
         old_mm = current->mm;
-       sync_mm_rss(old_mm);
         mm_release(tsk, old_mm);
+       sync_mm_rss(old_mm);

         if (old_mm) {
                 /*

>
>> but I have another question. Do we have any reason to
>> keep sync_mm_rss() in do_exit()? I havn't seen any reason that thread exiting
>> makes rss consistency.
>
> IIRC it's all about the hiwater_rss/maxrss stuff: we want to sync the
> maximum rss into mm->hiwater_rss before it's transferred to signal->maxrss,
> and later made visible to the user though getrusage(RUSAGE_CHILDREN,) -
> does your reading confirm that?
>
> Konstantin now finds the child_tid and futex stuff can trigger faults
> raising rss beyond that point, but usually it won't go higher than when
> it was captured for maxrss there.
>
> The sync_mm_rss() added by this patch (after "tsk->mm = NULL" so
> *_mm_counter_fast() cannot store any more into the tsk even if there
> were more faults) is solely to satisfy Konstantin's check_mm(), and
> it is irritating to have that duplicated on the exit path.

It was quick fix after the midnight. =) Now I think we can move mm_release()
from exit_mm() to do_exit(), and place it before sync_mm_rss(). Other stuff
there shouldn't trigger page-faults. Thus here will be only one sync_mm_rss():
at the end of mm_release()

>
> I'd be happy to see the new one put under CONFIG_DEBUG_VM along with
> check_mm(), once it's had a few -rcs of exposure without.
>
> Hugh
>
>>
>>
>>>
>>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>> Reported-by: Markus Trippelsdorf<markus@trippelsdorf.de>
>>> Cc: Hugh Dickins<hughd@google.com>
>>> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>> ---
>>>   kernel/exit.c |    1 +
>>>   1 file changed, 1 insertion(+)
>>>
>>> diff --git a/kernel/exit.c b/kernel/exit.c
>>> index d8bd3b42..8e09dbe 100644
>>> --- a/kernel/exit.c
>>> +++ b/kernel/exit.c
>>> @@ -683,6 +683,7 @@ static void exit_mm(struct task_struct * tsk)
>>>         enter_lazy_tlb(mm, current);
>>>         task_unlock(tsk);
>>>         mm_update_next_owner(mm);
>>> +       sync_mm_rss(mm);
>>>         mmput(mm);
>>>   }
>> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
