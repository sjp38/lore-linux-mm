Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62EEA600375
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:53:57 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414140523.GC13535@redhat.com>
	<xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
	<20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
	<g2u49b004811004142148i3db9fefaje1f20760426e0c7e@mail.gmail.com>
	<20100415152104.62593f37.nishimura@mxp.nes.nec.co.jp>
	<20100415155432.cf1861d9.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
	<1272056074.1821.40.camel@laptop>
Date: Sat, 24 Apr 2010 08:53:27 -0700
Message-ID: <xr93aassvoco.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <peterz@infradead.org> writes:

> On Fri, 2010-04-23 at 13:17 -0700, Greg Thelen wrote:
>> -       lock_page_cgroup(pc);
>> +       /*
>> +        * Unless a page's cgroup reassignment is possible, then avoid grabbing
>> +        * the lock used to protect the cgroup assignment.
>> +        */
>> +       rcu_read_lock();
>
> Where is the matching barrier?

Good catch.  A call to smp_wmb() belongs in
mem_cgroup_begin_page_cgroup_reassignment() like so:

static void mem_cgroup_begin_page_cgroup_reassignment(void)
{
	VM_BUG_ON(mem_cgroup_account_move_ongoing);
	mem_cgroup_account_move_ongoing = true;
	smp_wmb();
	synchronize_rcu();
}

I'll add this to the patch.

>> +       smp_rmb();
>> +       if (unlikely(mem_cgroup_account_move_ongoing)) {
>> +               local_irq_save(flags);
>
> So the added irq-disable is a bug-fix?

The irq-disable is not needed for current code, only for upcoming
per-memcg dirty page accounting which will be refactoring
mem_cgroup_update_file_mapped() into a generic memcg stat update
routine.  I assume these locking changes should be bundled with the
dependant memcg dirty page accounting changes which need the ability to
update counters from irq routines.  I'm sorry I didn't make that more
clear.

>> +               lock_page_cgroup(pc);
>> +               locked = true;
>> +       }
>> +
>>         mem = pc->mem_cgroup;
>>         if (!mem || !PageCgroupUsed(pc))
>>                 goto done;
>> @@ -1449,6 +1468,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>>         /*
>>          * Preemption is already disabled. We can use __this_cpu_xxx
>>          */
>> +       VM_BUG_ON(preemptible());
>
> Insta-bug here, there is nothing guaranteeing we're not preemptible
> here.

My addition of VM_BUG_ON() was to programmatic assert what the comment
was asserting.  All callers of mem_cgroup_update_file_mapped() hold the
pte spinlock, which disables preemption.  So I don't think this
VM_BUG_ON() will cause panic.  A function level comment for
mem_cgroup_update_file_mapped() declaring that "callers must have
preemption disabled" will be added to make this more clear.

>>         if (val > 0) {
>>                 __this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>>                 SetPageCgroupFileMapped(pc);
>> @@ -1458,7 +1478,11 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>>         }
>>  
>>  done:
>> -       unlock_page_cgroup(pc);
>> +       if (unlikely(locked)) {
>> +               unlock_page_cgroup(pc);
>> +               local_irq_restore(flags);
>> +       }
>> +       rcu_read_unlock();
>>  } 

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
