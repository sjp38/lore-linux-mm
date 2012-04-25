Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9033F6B004A
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 20:07:07 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2DEED3EE0AE
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 09:07:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 11C4845DE7E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 09:07:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7A2245DEB7
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 09:07:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D48A61DB8044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 09:07:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 89D991DB803F
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 09:07:05 +0900 (JST)
Message-ID: <4F973FB8.6050103@jp.fujitsu.com>
Date: Wed, 25 Apr 2012 09:05:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
References: <1335171318-4838-1-git-send-email-minchan@kernel.org> <4F963742.2030607@jp.fujitsu.com> <4F963B8E.9030105@kernel.org> <CAPa8GCA8q=S9sYx-0rDmecPxYkFs=gATGL-Dz0OYXDkwEECJkg@mail.gmail.com> <4F965413.9010305@kernel.org> <CAPa8GCCwfCFO6yxwUP5Qp9O1HGUqEU2BZrrf50w8TL9FH9vbrA@mail.gmail.com> <20120424143015.99fd8d4a.akpm@linux-foundation.org> <4F973BF2.4080406@jp.fujitsu.com> <CAHGf_=r09BCxXeuE8dSti4_SrT5yahrQCwJh=NrrA3rsUhhu_w@mail.gmail.com>
In-Reply-To: <CAHGf_=r09BCxXeuE8dSti4_SrT5yahrQCwJh=NrrA3rsUhhu_w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/04/25 8:55), KOSAKI Motohiro wrote:

> On Tue, Apr 24, 2012 at 7:49 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> (2012/04/25 6:30), Andrew Morton wrote:
>>
>>> On Tue, 24 Apr 2012 17:48:29 +1000
>>> Nick Piggin <npiggin@gmail.com> wrote:
>>>
>>>>> Hmm, there are several places to use GFP_NOIO and GFP_NOFS even, GFP_ATOMIC.
>>>>> I believe it's not trivial now.
>>>>
>>>> They're all buggy then. Unfortunately not through any real fault of their own.
>>>
>>> There are gruesome problems in block/blk-throttle.c (thread "mempool,
>>> percpu, blkcg: fix percpu stat allocation and remove stats_lock").  It
>>> wants to do an alloc_percpu()->vmalloc() from the IO submission path,
>>> under GFP_NOIO.
>>>
>>> Changing vmalloc() to take a gfp_t does make lots of sense, although I
>>> worry a bit about making vmalloc() easier to use!
>>>
>>> I do wonder whether the whole scheme of explicitly passing a gfp_t was
>>> a mistake and that the allocation context should be part of the task
>>> context.  ie: pass the allocation mode via *current.
>>
>> yes...that's very interesting.
> 
> I think GFP_ATOMIC is used non task context too. ;-)

Hmm, in interrupt context or some ? Can't we detect it ?

Thanks,
-Kame

 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
