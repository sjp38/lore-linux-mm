Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7DBBD6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 09:43:43 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id n128so158815151pfn.3
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 06:43:43 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id e71si40182052pfd.76.2016.01.18.06.43.42
        for <linux-mm@kvack.org>;
        Mon, 18 Jan 2016 06:43:42 -0800 (PST)
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
 <20160116174953.GU31137@redhat.com> <569A852B.6050209@linux.intel.com>
 <alpine.LSU.2.11.1601172345340.1538@eggly.anvils>
From: Arjan van de Ven <arjan@linux.intel.com>
Message-ID: <569CFA1D.4030401@linux.intel.com>
Date: Mon, 18 Jan 2016 06:43:41 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1601172345340.1538@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

>>
>> And the long hang do happen... once you start getting a bit of memory
>> pressure
>> (say you go from 7000 to 7200 VMs and you only have memory for 7150) then you
>> are hitting the long delays *for every page* the VM inspects, and it will
>
> I don't understand "*for every page*": why for *every* page?
> I won't dispute "for many pages, many more than is bearable".

for every page the VM inspects; the VM tries to free memory and goes on trying
to free stuff, but (I'm guessing here) skipping active pages, but to know and clear
active, you need to walk the whole chain. for each page.

>> Now, you can make it 2x faster (reboot in 12 hours? ;-) ) but there's really
>> a much
>> higher order reduction of the "long chain" problem needed...
>> I'm with Andrea that prevention of super long chains is the way to go, we can
>> argue about 250
>> or 500 or 1000. Numbers will speak there... but from a KSM user perspective,
>> at some point
>> you reduced the cost of a page by 250x or 500x or 1000x... it's hitting
>> diminishing returns.
>
> I'm not for a moment denying that there's a problem to be solved,
> just questioning what's the right solution.
>
> The reclaim case you illustrate does not persuade me, I already suggested
> an easier way to handle that (don't waste time on pages of high mapcount).
>
> Or are you saying that in your usage, the majority of pages start out with
> high mapcount?  That would defeat my suggestion, I think,  But it's the
> compaction case I want to think more about, that may persuade me also.


well in most servers that host VMs, of the, say 128Gb to 240Gb, all but a few hundred MB
is allocated to VMs, and VM memory is generally shared. So yes a big chunk
of memory will have a high map count of some sorts.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
