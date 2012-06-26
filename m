Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id DE8AD6B00CD
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 23:14:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EE8233EE0AE
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3B2D45DEB5
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B8DAC45DEAD
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A5E0A1DB803C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CDDD1DB803B
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:11 +0900 (JST)
Message-ID: <4FE9284F.5040001@jp.fujitsu.com>
Date: Tue, 26 Jun 2012 12:11:11 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com> <4FE8CCCD.7080503@redhat.com> <alpine.DEB.2.00.1206251726040.1895@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206251726040.1895@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/06/26 9:32), David Rientjes wrote:
> On Mon, 25 Jun 2012, Rik van Riel wrote:
>
>> The patch makes sense, however I wonder if it would make
>> more sense in the long run to allow migrate/compaction to
>> temporarily exceed the memcg memory limit for a cgroup,
>> because the original page will get freed again soon anyway.
>>
>> That has the potential to improve compaction success, and
>> reduce compaction related CPU use.
>>
>
> Yeah, Kame brought up the same point with a sample patch by allowing the
> temporary charge for the new page.  It would certainly solve this problem
> in a way that we don't have to even touch compaction, it's disappointing
> that we have to charge memory to do a page migration.  I'm not so sure
> about the approach of temporarily allowing the excess charge, however,
> since it would scale with the number of cpus doing compaction or
> migration, which could end up with PAGE_SIZE * nr_cpu_ids.
>

I don't think it's problem. Even if there are 4096 cpus, it's only 16MB
on that system, which tends to have terabytes of memory.
(We already have 32pages of per-cpu-cache....)

I'd like to post that patch with updating to mmotm.

> I haven't looked at it (yet), but I'm hoping that there's a way to avoid
> charging the temporary page at all until after move_to_new_page()
> succeeds, i.e. find a way to uncharge page before charging newpage.

Hmm...this code has been verrry racy and we did many mis-accounting.
So, I'd like to start from a safe way.

THanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
