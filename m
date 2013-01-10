Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 0B3D16B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 00:04:07 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CA5AB3EE0BB
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:04:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AF52145DE52
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:04:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9626745DE4F
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:04:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 874EAE08003
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:04:05 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D076E08002
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:04:05 +0900 (JST)
Message-ID: <50EE4B84.5080205@jp.fujitsu.com>
Date: Thu, 10 Jan 2013 14:03:00 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456367-14660-1-git-send-email-handai.szj@taobao.com> <20130102104421.GC22160@dhcp22.suse.cz> <CAFj3OHXKyMO3gwghiBAmbowvqko-JqLtKroX2kzin1rk=q9tZg@mail.gmail.com> <50EA7860.6030300@jp.fujitsu.com> <CAFj3OHXMgRG6u2YoM7y5WuPo2ZNA1yPmKRV29FYj9B6Wj_c6Lw@mail.gmail.com> <50EE247B.6090405@jp.fujitsu.com> <CAFj3OHW=n22veXzR27qfc+10t-nETU=B78NULPXrEDT1S-KsOw@mail.gmail.com>
In-Reply-To: <CAFj3OHW=n22veXzR27qfc+10t-nETU=B78NULPXrEDT1S-KsOw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

(2013/01/10 13:26), Sha Zhengju wrote:

> But this method also has its pros and cons(e.g. need lock nesting). So
> I doubt whether the following is able to deal with these issues all
> together:
> (CPU-A does "page stat accounting" and CPU-B does "move")
>
>               CPU-A                            CPU-B
>
> move_lock_mem_cgroup()
> memcg = pc->mem_cgroup
> SetPageDirty(page)
> move_unlock_mem_cgroup()
>                                        move_lock_mem_cgroup()
>                                        if (PageDirty) {
>                                                 old_memcg->nr_dirty --;
>                                                 new_memcg->nr_dirty ++;
>                                         }
>                                         pc->mem_cgroup = new_memcg
>                                         move_unlock_mem_cgroup()
>
> memcg->nr_dirty ++
>
>
> For CPU-A, we save pc->mem_cgroup in a temporary variable just before
> SetPageDirty inside move_lock and then update stats if the page is set
> PG_dirty successfully. But CPU-B may do "moving" in advance that
> "old_memcg->nr_dirty --" will make old_memcg->nr_dirty incorrect but
> soon CPU-A will do "memcg->nr_dirty ++" at the heels that amend the
> stats.
> However, there is a potential problem that old_memcg->nr_dirty  may be
> minus in a very short period but not a big issue IMHO.
>

IMHO, this will work. Please take care of that the recorded memcg will not
be invalid pointer when you update the nr_dirty later.
(Maybe RCU will protect it.)

_If_ this method can handle "nesting" problem clearer and make implementation
simpler, please go ahead. To be honest, I'm not sure how the code will be until
seeing the patch. Hmm, why you write SetPageDirty() here rather than
TestSetPageDirty()....

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
