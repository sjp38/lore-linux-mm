Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D9F976B0088
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 11:42:02 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0TGg0Mn003992
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 30 Jan 2010 01:42:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4568345DE62
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:42:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 18AE645DE55
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:42:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DEF541DB803B
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:41:59 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 788CA1DB8038
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 01:41:59 +0900 (JST)
Message-ID: <5a0e6098f900aa36993b2b7f2320f927.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20100129163030.1109ce78@lxorguk.ukuu.org.uk>
References: 
    <f8c9aca9c98db8ae7df3ac2d7ac8d922.squirrel@webmail-b.css.fujitsu.com>
    <20100129162137.79b2a6d4@lxorguk.ukuu.org.uk>
    <c6c48fdf7f746add49bb9cc058b513ae.squirrel@webmail-b.css.fujitsu.com>
    <20100129163030.1109ce78@lxorguk.ukuu.org.uk>
Date: Sat, 30 Jan 2010 01:41:58 +0900 (JST)
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, vedran.furac@gmail.com, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> > Ultimately it is policy. The kernel simply can't read minds.
>> >
>> If so, all heuristics other than vm_size should be purged, I think.
>> ...Or victim should be just determined by the class of application
>> user sets. oom_adj other than OOM_DISABLE, searching victim process
>> by black magic are all garbage.
>
> oom_adj by value makes sense as do some of the basic heuristics - but a
> lot of the complexity I would agree is completely nonsensical.
>
> There are folks who use oom_adj weightings to influence things (notably
> embedded and desktop). The embedded world would actually benefit on the
> whole if the oom_adj was an absolute value because they usually know
> precisely what they want to die and in what order.
>
okay...I guess the cause of the problem Vedran met came from
this calculation.
==
 109         /*
 110          * Processes which fork a lot of child processes are likely
 111          * a good choice. We add half the vmsize of the children if they
 112          * have an own mm. This prevents forking servers to flood the
 113          * machine with an endless amount of children. In case a single
 114          * child is eating the vast majority of memory, adding only half
 115          * to the parents will make the child our kill candidate of
choice.
 116          */
 117         list_for_each_entry(child, &p->children, sibling) {
 118                 task_lock(child);
 119                 if (child->mm != mm && child->mm)
 120                         points += child->mm->total_vm/2 + 1;
 121                 task_unlock(child);
 122         }
 123
==
This makes task launcher(the fist child of some daemon.) first victim.
And...I wonder this is not good for oom_adj,
I think it's set per task with regard to personal memory usage.

But I'm not sure why this code is used now. Does anyone remember
history or the benefit of this calculation ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
