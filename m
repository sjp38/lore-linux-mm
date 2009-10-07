Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B66186B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 23:37:42 -0400 (EDT)
Received: by iwn34 with SMTP id 34so2495575iwn.12
        for <linux-mm@kvack.org>; Tue, 06 Oct 2009 20:37:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0910061226300.18309@gentwo.org>
References: <20091006112803.5FA5.A69D9226@jp.fujitsu.com>
	 <20091006114052.5FAA.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.1.10.0910061226300.18309@gentwo.org>
Date: Wed, 7 Oct 2009 12:37:41 +0900
Message-ID: <2f11576a0910062037r785da04bg5723a1779f40d45c@mail.gmail.com>
Subject: Re: [PATCH 2/2] mlock use lru_add_drain_all_async()
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

2009/10/7 Christoph Lameter <cl@linux-foundation.org>:
> On Tue, 6 Oct 2009, KOSAKI Motohiro wrote:
>
>> =A0 Suppose you have 2 cpus, cpu1 is busy doing a SCHED_FIFO-99 while(1)=
,
>> =A0 cpu0 does mlock()->lru_add_drain_all(), which does
>> =A0 schedule_on_each_cpu(), which then waits for all cpus to complete th=
e
>> =A0 work. Except that cpu1, which is busy with the RT task, will never r=
un
>> =A0 keventd until the RT load goes away.
>>
>> =A0 This is not so much an actual deadlock as a serious starvation case.
>>
>> Actually, mlock() doesn't need to wait to finish lru_add_drain_all().
>> Thus, this patch replace it with lru_add_drain_all_async().
>
> Ok so this will queue up lots of events for the cpu doing a RT task. If
> the RT task is continuous then they will be queued there forever?

Yes. this patch solved very specific issue only.
In original bug-report case, the system has two cpuset and the RT task
own one cpuset as monopoly. Thus, your worried thing doesn't occur.

Perhaps, we need complete solution. but I don't think this patch have
bad side effect. then, I hope to push it into mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
