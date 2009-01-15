Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3923D6B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 07:28:36 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0FCSXa8017518
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 21:28:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0258145DE52
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 21:28:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D5DBA45DE51
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 21:28:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D3571DB803C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 21:28:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 210561DB803F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 21:28:32 +0900 (JST)
Message-ID: <f7396e3b30a5e71d1e00a8373e20a348.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0901151145470.11108@blonde.anvils>
References: <20090109043257.GB9737@balbir.in.ibm.com>
    <20090109134736.a995fc49.kamezawa.hiroyu@jp.fujitsu.com>
    <20090115200545.EBE6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
    <Pine.LNX.4.64.0901151145470.11108@blonde.anvils>
Date: Thu, 15 Jan 2009 21:28:31 +0900 (JST)
Subject: Re: [PATCH] mark_page_accessed() in do_swap_page() move latter
 than memcg charge
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 15 Jan 2009, KOSAKI Motohiro wrote:
>>
>> sorry for late responce.
>>
>> > > In this case we've hit a case where the page is valid and the pc is
>> > > not. This does fix the problem, but won't this impact us getting
>> > > correct reclaim stats and thus indirectly impact the working of
>> > > pressure?
>> > >
>> >  - If retruns NULL, only global LRU's status is updated.
>> >
>> > Because this page is not belongs to any memcg, we cannot update
>> > any counters. But yes, your point is a concern.
>> >
>> > Maybe moving acitvate_page() to
>> > ==
>> > do_swap_page()
>> > {
>> >
>> > - activate_page()
>> >    mem_cgroup_try_charge()..
>> >    ....
>> >    mem_cgroup_commit_charge()....
>> >    ....
>> > +  activate_page()
>> > }
>> > ==
>> > is necessary. How do you think, kosaki ?
>>
>>
>> OK. it makes sense. and my test found no bug.
>>
>> ==
>>
>> mark_page_accessed() update reclaim_stat statics.
>> but currently, memcg charge is called after mark_page_accessed().
>>
>> then, mark_page_accessed() don't update memcg statics correctly.
>
> Statics?  "Stats" is a good abbreviation for statistics,
> but statics are something else.
>
>>
>> fixing here.
>>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
>>
>> ---
>>  mm/memory.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> Index: b/mm/memory.c
>> ===================================================================
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2426,8 +2426,6 @@ static int do_swap_page(struct mm_struct
>>  		count_vm_event(PGMAJFAULT);
>>  	}
>>
>> -	mark_page_accessed(page);
>> -
>>  	lock_page(page);
>>  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>>
>> @@ -2480,6 +2478,8 @@ static int do_swap_page(struct mm_struct
>>  		try_to_free_swap(page);
>>  	unlock_page(page);
>>
>> +	mark_page_accessed(page);
>> +
>>  	if (write_access) {
>>  		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
>>  		if (ret & VM_FAULT_ERROR)
>
> This catches my eye, because I'd discussed with Nick and was going to
> send in a patch which entirely _removes_ this mark_page_accessed call
> from do_swap_page (and replaces follow_page's mark_page_accessed call
> by a pte_mkyoung): they seem inconsistent to me, in the light of
> bf3f3bc5e734706730c12a323f9b2068052aa1f0 mm: don't mark_page_accessed
> in fault path.
>
Hmm

> Though I need to give it another think through first: the situation
> is muddied by the way we (rightly) don't bother to do the mark_page_
> accessed on Anon in zap_pte_range anyway; and anon/swap has an
> independent lifecycle now with the separate swapbacked LRUs.
>
> What do you think?  I didn't look further into your memcg situation,
> and what this patch is about: I'm unclear whether my patch to remove
> that mark_page_accessed would solve your problem, or mess you up.
>
For memcg situation, there was 2 problems.

  1. page_cgroup->mem_cgroup was accessed before it's updated.
    (in mmotm, fixed by Nishimura's patch, avoiding panic.)
  2. mem_cgroup's reclaim_stat is not updated correctly.

1. is fixed. Kosaki's patch is for "2".

If mark_page_accessed() is entirely removed, I have no concerns to
memcg but just test memcg's reclaim logic.

Anyway, at the end of the last year, it has some unfair situation..
I'll restart digging if the problem still exists.;(

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
