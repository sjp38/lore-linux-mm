Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 7AF7A6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 02:49:56 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0ED003EE0C0
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 16:49:55 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E14B245DEBB
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 16:49:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE8DC45DEB7
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 16:49:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF2441DB803E
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 16:49:54 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 540111DB8040
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 16:49:54 +0900 (JST)
Message-ID: <50EA7E07.4070902@jp.fujitsu.com>
Date: Mon, 07 Jan 2013 16:49:27 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456367-14660-1-git-send-email-handai.szj@taobao.com> <20130102104421.GC22160@dhcp22.suse.cz> <CAFj3OHXKyMO3gwghiBAmbowvqko-JqLtKroX2kzin1rk=q9tZg@mail.gmail.com> <alpine.LNX.2.00.1301061135400.29149@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1301061135400.29149@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sha Zhengju <handai.szj@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

(2013/01/07 5:02), Hugh Dickins wrote:
> On Sat, 5 Jan 2013, Sha Zhengju wrote:
>> On Wed, Jan 2, 2013 at 6:44 PM, Michal Hocko <mhocko@suse.cz> wrote:
>>>
>>> Maybe I have missed some other locking which would prevent this from
>>> happening but the locking relations are really complicated in this area
>>> so if mem_cgroup_{begin,end}_update_page_stat might be called
>>> recursively then we need a fat comment which justifies that.
>>>
>>
>> Ohhh...good catching!  I didn't notice there is a recursive call of
>> mem_cgroup_{begin,end}_update_page_stat in page_remove_rmap().
>> The mem_cgroup_{begin,end}_update_page_stat() design has depressed
>> me a lot recently as the lock granularity is a little bigger than I thought.
>> Not only the resource but also some code logic is in the range of locking
>> which may be deadlock prone. The problem still exists if we are trying to
>> add stat account of other memcg page later, may I make bold to suggest
>> that we dig into the lock again...
>
> Forgive me, I must confess I'm no more than skimming this thread,
> and don't like dumping unsigned-off patches on people; but thought
> that on balance it might be more helpful than not if I offer you a
> patch I worked on around 3.6-rc2 (but have updated to 3.8-rc2 below).
>
> I too was getting depressed by the constraints imposed by
> mem_cgroup_{begin,end}_update_page_stat (good job though Kamezawa-san
> did to minimize them), and wanted to replace by something freer, more
> RCU-like.  In the end it seemed more effort than it was worth to go
> as far as I wanted, but I do think that this is some improvement over
> what we currently have, and should deal with your recursion issue.
>
In what case does this improve performance ?

> But if this does appear useful to memcg people, then we really ought
> to get it checked over by locking/barrier experts before going further.
> I think myself that I've over-barriered it, and could use a little
> lighter; but they (Paul McKenney, Peter Zijlstra, Oleg Nesterov come
> to mind) will see more clearly, and may just hate the whole thing,
> as yet another peculiar lockdep-avoiding hand-crafted locking scheme.
> I've not wanted to waste their time on reviewing it, if it's not even
> going to be useful to memcg people.
>
> It may be easier to understand if you just apply the patch and look
> at the result in mm/memcontrol.c, where I tried to gather the pieces
> together in one place and describe them ("These functions mediate...").
>
> Hugh
>

Hi, this patch seems interesting but...doesn't this make move_account() very
slow if the number of cpus increases because of scanning all cpus per a page ?
And this looks like reader-can-block-writer percpu rwlock..it's too heavy to
writers if there are many readers.


Thanks,
-Kame


  







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
