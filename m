Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 0F8336B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 03:28:17 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id n5so293666oag.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 00:28:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50EE4B84.5080205@jp.fujitsu.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
	<1356456367-14660-1-git-send-email-handai.szj@taobao.com>
	<20130102104421.GC22160@dhcp22.suse.cz>
	<CAFj3OHXKyMO3gwghiBAmbowvqko-JqLtKroX2kzin1rk=q9tZg@mail.gmail.com>
	<50EA7860.6030300@jp.fujitsu.com>
	<CAFj3OHXMgRG6u2YoM7y5WuPo2ZNA1yPmKRV29FYj9B6Wj_c6Lw@mail.gmail.com>
	<50EE247B.6090405@jp.fujitsu.com>
	<CAFj3OHW=n22veXzR27qfc+10t-nETU=B78NULPXrEDT1S-KsOw@mail.gmail.com>
	<50EE4B84.5080205@jp.fujitsu.com>
Date: Thu, 10 Jan 2013 16:28:16 +0800
Message-ID: <CAFj3OHXbfW+ubBhGNpy9ZcyUQvpKwssRvyjK5k=CM9sqQE9r4g@mail.gmail.com>
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

On Thu, Jan 10, 2013 at 1:03 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2013/01/10 13:26), Sha Zhengju wrote:
>
>> But this method also has its pros and cons(e.g. need lock nesting). So
>> I doubt whether the following is able to deal with these issues all
>> together:
>> (CPU-A does "page stat accounting" and CPU-B does "move")
>>
>>               CPU-A                            CPU-B
>>
>> move_lock_mem_cgroup()
>> memcg = pc->mem_cgroup
>> SetPageDirty(page)
>> move_unlock_mem_cgroup()
>>                                        move_lock_mem_cgroup()
>>                                        if (PageDirty) {
>>                                                 old_memcg->nr_dirty --;
>>                                                 new_memcg->nr_dirty ++;
>>                                         }
>>                                         pc->mem_cgroup = new_memcg
>>                                         move_unlock_mem_cgroup()
>>
>> memcg->nr_dirty ++
>>
>>
>> For CPU-A, we save pc->mem_cgroup in a temporary variable just before
>> SetPageDirty inside move_lock and then update stats if the page is set
>> PG_dirty successfully. But CPU-B may do "moving" in advance that
>> "old_memcg->nr_dirty --" will make old_memcg->nr_dirty incorrect but
>> soon CPU-A will do "memcg->nr_dirty ++" at the heels that amend the
>> stats.
>> However, there is a potential problem that old_memcg->nr_dirty  may be
>> minus in a very short period but not a big issue IMHO.
>>
>
> IMHO, this will work. Please take care of that the recorded memcg will not
> be invalid pointer when you update the nr_dirty later.
> (Maybe RCU will protect it.)
>
Yes, there're 3 places to change pc->mem_cgroup: charge & uncharge &
move_account. "charge" has no race with stat updater and "uncharge"
doesn't reset pc->mem_cgroup directly, also "move_account" is just the
one we are handling, so they may do no harm here. Meanwhile, invalid
pointer made by cgroup deletion may also be avoided by RCU. Yet it's a
rough conclusion by quick look...

> _If_ this method can handle "nesting" problem clearer and make
> implementation
> simpler, please go ahead. To be honest, I'm not sure how the code will be
> until
Okay, later I'll try to propose the patch.

> seeing the patch. Hmm, why you write SetPageDirty() here rather than
> TestSetPageDirty()....
>
No particular reason...TestSetPageDirty() may be more precise... : )


-- 
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
