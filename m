Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 147486B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 21:10:51 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n711ApSc029169
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 1 Aug 2009 10:10:51 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F170845DE50
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 10:10:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C57D245DE4E
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 10:10:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF0A01DB803E
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 10:10:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 656031DB803B
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 10:10:50 +0900 (JST)
Message-ID: <77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
    <20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
    <20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
    <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
    <7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
    <alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com>
Date: Sat, 1 Aug 2009 10:10:49 +0900 (JST)
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

>> > It livelocks if a thread is chosen and passed to oom_kill_task() while
>> > another per-thread oom_adj value is OOM_DISABLE for a thread sharing
>> the
>> > same memory.
>> >
>> I say "why don't modify buggy selection logic?"
>>
>> Why we have to scan all threads ?
>> As fs/proc/readdir does, you can scan only "process group leader".
>>
>> per-thread scan itself is buggy because now we have per-process
>> effective-oom-adj.
>>
>
> Without my patches to change oom_adj from task_struct to mm_struct, you'd
> need to scan all tasks and not just the tgids because their oom_adj values
> can differ amongst threads in the same thread group.  So while it may now
> be possible to shorten the scan as a result of my approach, it isn't a
> solution itself to the problem.

Did I said "revert your patch in -rc" even once ?
livelock-avoidance itself is good work, thank you.
All my suggestion is based on your patch already in rc4.
Summarizing I think now .....
  - rename mm->oom_adj as mm->effective_oom_adj
  - re-add per-thread oom_adj
  - update mm->effective_oom_adj based on per-thread oom_adj
  - if necessary, plz add read-only /proc/pid/effective_oom_adj file.
    or show 2 values in /proc/pid/oom_adj
  - rewrite documentation about oom_score.
   " it's calclulated from  _process's_ memory usage and oom_adj of
    all threads which shares a memor  context".
   This behavior is not changed from old implemtation, anyway.
 - If necessary, rewrite oom_kill itself to scan only thread group
   leader. It's a way to go regardless of  vfork problem.



>
>> > How else do you propose the oom killer use oom_adj values on a
>> per-thread
>> > basis without considering other threads sharing the same memory?
>> As I wrote.
>>    per-process(signal struct) or per-thread oom_adj and add
>>    mm->effecitve_oom_adj
>>
>> task scanning isn't necessary to do per-thread scan and you can scan
>> only process-group-leader. What's bad ?
>> If oom_score is problem, plz fix it to show effective_oom_score.
>>
>
> When only using (and showing) mm->effective_oom_adj for a task, userspace
> will not be able to adjust /proc/pid/oom_score with /proc/pid/oom_adj
> as Documentation/filesystems/proc.txt says you can for a thread unless it
> exceeds effective_oom_adj.>

Is it different from old behavior ?
I think documentation is wrong. It should say "you should think of
multi-thread effect to oom_adj/oom_score".

Thanks,
-Kame

> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
