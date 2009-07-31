Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 244A56B0055
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 06:49:01 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6VAn44X007473
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 31 Jul 2009 19:49:05 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A80345DE4D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 19:49:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 431C245DE4F
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 19:49:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB4B91DB8040
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 19:49:03 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7660BE08001
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 19:49:03 +0900 (JST)
Message-ID: <7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
    <20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
    <20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
    <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
Date: Fri, 31 Jul 2009 19:49:02 +0900 (JST)
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
> On Fri, 31 Jul 2009, KAMEZAWA Hiroyuki wrote:
>
>> > > Simply, reset_oom_adj_at_new_mm_context or some.
>> > >
>> >
>> > I think it's preferred to keep the name relatively short which is an
>> > unfortuante requirement in this case.  I also prefer to start the name
>> > with "oom_adj" so it appears alongside /proc/pid/oom_adj when listed
>> > alphabetically.
>> >
>> But misleading name is bad.
>>
>
> Can you help think of any names that start with oom_adj_* and are
> relatively short?  I'd happily ack it.
>
There have been traditional name "effective" as uid and euid.

 then,  per thread oom_adj as oom_adj
        per proc   oom_adj as effective_oom_adj

is an natural way as Unix, I think.



>> Why don't you think select_bad_process()-> oom_kill_task()
>> implementation is bad ?
>
> It livelocks if a thread is chosen and passed to oom_kill_task() while
> another per-thread oom_adj value is OOM_DISABLE for a thread sharing the
> same memory.
>
I say "why don't modify buggy selection logic?"

Why we have to scan all threads ?
As fs/proc/readdir does, you can scan only "process group leader".

per-thread scan itself is buggy because now we have per-process
effective-oom-adj.


>> IMHO, it's bad manner to fix an os-implementation problem by adding
>> _new_ user
>> interface which is hard to understand.
>>
>
> How else do you propose the oom killer use oom_adj values on a per-thread
> basis without considering other threads sharing the same memory?
As I wrote.
   per-process(signal struct) or per-thread oom_adj and add
   mm->effecitve_oom_adj

task scanning isn't necessary to do per-thread scan and you can scan
only process-group-leader. What's bad ?
If oom_score is problem, plz fix it to show effective_oom_score.

If you can wait until the end of August, plz wait. I'll do some.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
