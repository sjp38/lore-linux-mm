Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4E0C78D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:15:40 -0400 (EDT)
Message-ID: <4CCAC8F3.3020704@redhat.com>
Date: Fri, 29 Oct 2010 09:15:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
References: <1288200090-23554-1-git-send-email-yinghan@google.com>	<4CC869F5.2070405@redhat.com>	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>	<AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>	<alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>	<AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>	<20101028091158.4de545e9.kamezawa.hiroyu@jp.fujitsu.com>	<AANLkTikdE---MJ-LSwNHEniCphvwu0T2apkWzGsRQ8i=@mail.gmail.com>	<20101029114529.4d3a8b9c.kamezawa.hiroyu@jp.fujitsu.com>	<4CCA42D0.5090603@redhat.com>	<AANLkTiku321ZpSrO4hSLyj7n9NM7QvN+RQ-A73KK4eRa@mail.gmail.com>	<4CCABEA0.8080909@redhat.com> <AANLkTim9iHYDxATbfOMPm614QfcB6uc3LkOR73nnpg2L@mail.gmail.com>
In-Reply-To: <AANLkTim9iHYDxATbfOMPm614QfcB6uc3LkOR73nnpg2L@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ken Chen <kenchen@google.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 10/29/2010 09:03 AM, Minchan Kim wrote:
> On Fri, Oct 29, 2010 at 9:31 PM, Rik van Riel<riel@redhat.com>  wrote:
>> On 10/29/2010 12:27 AM, Minchan Kim wrote:
>>
>>> What happens if we don't flush TLB?
>>> It will make for old page to pretend young page.
>>> If it is, how does it affect reclaim?
>>
>> Other way around - it will make a young page pretend to be an
>> old page, because the TLB won't know it needs to flush the
>> Accessed bit into the page tables (where the bit was recently
>> cleared).
>
> Ying's patch just removes TLB flush when page access bit is changed
> from young to old.
> We still flush TLB flush when from old to young change by
> ptep_set_access_flags. Do I miss something?

The TLB is write-through for the accessed and dirty
bits.

If the TLB has a page translation without the accessed
bit (and is accessing it), the accessed bit will be set
in the page table entry.

If the TLB has a page translation that already has the
accessed bit set, nothing will be written to the page
table entry.

With Ying's change, we will clear the accessed bit in
the page table, without invalidating the corresponding
TLB entry.

This can cause accesses to pages to not lead to the
accessed bit getting set in the corresponding page table
entry.

Making sure the TLB is flushed periodically could fix
that issue.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
