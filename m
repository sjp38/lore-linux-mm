Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 1F6AC6B005C
	for <linux-mm@kvack.org>; Mon, 28 May 2012 23:18:16 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 29 May 2012 08:48:12 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4T3I7Ob9961898
	for <linux-mm@kvack.org>; Tue, 29 May 2012 08:48:07 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4T8mjwc023433
	for <linux-mm@kvack.org>; Tue, 29 May 2012 18:48:45 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hugetlb: Use compound page head in migrate_huge_page
In-Reply-To: <20120528191322.GA10071@tiehlicka.suse.cz>
References: <1338218490-30978-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120528191322.GA10071@tiehlicka.suse.cz>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Tue, 29 May 2012 08:48:00 +0530
Message-ID: <87obp7u13r.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Mon 28-05-12 20:51:30, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> The change was introduced by "hugetlb: simplify migrate_huge_page() "
>> 
>> We should use compound page head instead of tail pages in
>> migrate_huge_page().
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  mm/memory-failure.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> This is an important bug fix. If we want we can fold it with the not
>> yet merged upstream patch mentioned above in linux-next. The stack
>> trace for the crash is
>> 
>> [   75.337421] BUG: unable to handle kernel NULL pointer dereference at 0000000000000080
>> [   75.338386] IP: [<ffffffff816b3f0f>] __mutex_lock_common+0xa1/0x350
>> [   75.338386] PGD 1d700067 PUD 1d7dd067 PMD 0
>> [   75.338386] Oops: 0002 [#1] SMP
>> [   75.338386] CPU 1
>> [   75.338386] Modules linked in:
>> ...
>> ...
>> 
>> [   75.338386] Call Trace:
>> [   75.338386]  [<ffffffff810ffc04>] ? try_to_unmap_file+0x38/0x51c
>> [   75.338386]  [<ffffffff810ffc04>] ? try_to_unmap_file+0x38/0x51c
>> [   75.338386]  [<ffffffff813b5f8b>] ? vsnprintf+0x83/0x421
>> [   75.338386]  [<ffffffff816b427d>] mutex_lock_nested+0x2a/0x31
>> [   75.338386]  [<ffffffff8110999b>] ? alloc_huge_page_node+0x1d/0x55
>> [   75.338386]  [<ffffffff810ffc04>] try_to_unmap_file+0x38/0x51c
>> [   75.338386]  [<ffffffff8110999b>] ? alloc_huge_page_node+0x1d/0x55
>> [   75.338386]  [<ffffffff810a06b9>] ? arch_local_irq_save+0x9/0xc
>> [   75.338386]  [<ffffffff816b5e3b>] ? _raw_spin_unlock+0x23/0x27
>> [   75.338386]  [<ffffffff81100839>] try_to_unmap+0x25/0x3c
>> [   75.338386]  [<ffffffff810641c2>] ? console_unlock+0x210/0x238
>> [   75.338386]  [<ffffffff811141e3>] migrate_huge_page+0x8d/0x178
>
> This should be part of the changelog.

I was expecting the patch to be folded back to the existing patch in
-mm. That is the reason I added stack trace in the notes section so that
if we decided to keep it as a separate patch we can pull the stack trace
and add it to commit message.


>
>> 
>> 
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 4a45098..53a1495 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1428,8 +1428,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
>>  	}
>>  
>>  	/* Keep page count to indicate a given hugepage is isolated. */
>> -	ret = migrate_huge_page(page, new_page, MPOL_MF_MOVE_ALL, 0, true);
>> -	put_page(page);
>> +	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, 0, true);
>> +	put_page(hpage);
>>  	if (ret) {
>>  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>>  			pfn, ret, page->flags);
>
> I guess you want hpage->flags here.

Existing code pass the flag details of the page passed as the
argument. I didn't want to change that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
