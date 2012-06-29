Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 106B26B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 23:49:45 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0FB6A3EE081
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:49:43 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC3A245DE58
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:49:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3E5F45DE57
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:49:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C7A971DB8037
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:49:42 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 844BE1DB802F
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:49:42 +0900 (JST)
Message-ID: <4FED2554.6020601@jp.fujitsu.com>
Date: Fri, 29 Jun 2012 12:47:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: needed lru_add_drain_all() change
References: <20120626143703.396d6d66.akpm@linux-foundation.org> <CAHGf_=ra6eXSVyhox3z2X-4csrwWeeDgMjS83i-J2nJwuWpqhg@mail.gmail.com>
In-Reply-To: <CAHGf_=ra6eXSVyhox3z2X-4csrwWeeDgMjS83i-J2nJwuWpqhg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

(2012/06/28 15:23), KOSAKI Motohiro wrote:
> On Tue, Jun 26, 2012 at 5:37 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> https://bugzilla.kernel.org/show_bug.cgi?id=43811
>>
>> lru_add_drain_all() uses schedule_on_each_cpu().  But
>> schedule_on_each_cpu() hangs if a realtime thread is spinning, pinned
>> to a CPU.  There's no intention to change the scheduler behaviour, so I
>> think we should remove schedule_on_each_cpu() from the kernel.
>>
>> The biggest user of schedule_on_each_cpu() is lru_add_drain_all().
>>
>> Does anyone have any thoughts on how we can do this?  The obvious
>> approach is to declare these:
>>
>> static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>> static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>> static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>>
>> to be irq-safe and use on_each_cpu().  lru_rotate_pvecs is already
>> irq-safe and converting lru_add_pvecs and lru_deactivate_pvecs looks
>> pretty simple.
>>
>> Thoughts?
>
> I agree.
>
> But i hope more. In these days, we have plenty lru_add_drain_all()
> callsite. So,
> i think we should remove struct pagevec and should aim migration aware new
> batch mechanism. maybe. This also improve compaction success rate.
>

migration-aware means an framework which isolate_xxxx_page() can work with ?
To do that, we need to know which object points to the page. Hmm. Do you have
anyidea ?

-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
