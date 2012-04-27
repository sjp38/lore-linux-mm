Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 981416B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 21:07:24 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AA9803EE0AE
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 10:07:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C8F445DE52
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 10:07:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72D1D45DE4E
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 10:07:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62DD7E38002
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 10:07:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C66A1DB803A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 10:07:22 +0900 (JST)
Message-ID: <4F99F0BE.2060402@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 10:05:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/3] make jump_labels wait while updates are in place
References: <1335480667-8301-1-git-send-email-glommer@parallels.com> <1335480667-8301-2-git-send-email-glommer@parallels.com> <20120427004305.GC23877@home.goodmis.org>
In-Reply-To: <20120427004305.GC23877@home.goodmis.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, Jason Baron <jbaron@redhat.com>

(2012/04/27 9:43), Steven Rostedt wrote:

> On Thu, Apr 26, 2012 at 07:51:05PM -0300, Glauber Costa wrote:
>> In mem cgroup, we need to guarantee that two concurrent updates
>> of the jump_label interface wait for each other. IOW, we can't have
>> other updates returning while the first one is still patching the
>> kernel around, otherwise we'll race.
> 
> But it shouldn't. The code as is should prevent that.
> 
>>
>> I believe this is something that can fit well in the static branch
>> API, without noticeable disadvantages:
>>
>> * in the common case, it will be a quite simple lock/unlock operation
>> * Every context that calls static_branch_slow* already expects to be
>>   in sleeping context because it will mutex_lock the unlikely case.
>> * static_key_slow_inc is not expected to be called in any fast path,
>>   otherwise it would be expected to have quite a different name. Therefore
>>   the mutex + atomic combination instead of just an atomic should not kill
>>   us.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Tejun Heo <tj@kernel.org>
>> CC: Li Zefan <lizefan@huawei.com>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Ingo Molnar <mingo@elte.hu>
>> CC: Jason Baron <jbaron@redhat.com>
>> ---
>>  kernel/jump_label.c |   21 +++++++++++----------
>>  1 files changed, 11 insertions(+), 10 deletions(-)
>>
>> diff --git a/kernel/jump_label.c b/kernel/jump_label.c
>> index 4304919..5d09cb4 100644
>> --- a/kernel/jump_label.c
>> +++ b/kernel/jump_label.c
>> @@ -57,17 +57,16 @@ static void jump_label_update(struct static_key *key, int enable);
>>  
>>  void static_key_slow_inc(struct static_key *key)
>>  {
>> +	jump_label_lock();
>>  	if (atomic_inc_not_zero(&key->enabled))
>> -		return;
> 
> If key->enabled is not zero, there's nothing to be done. As the jump
> label has already been enabled. Note, the key->enabled doesn't get set
> until after the jump label is updated. Thus, if two tasks were to come
> in, they both would be locked on the jump_label_lock().
> 

Ah, sorry, I misunderstood somthing. I'm sorry, Glauber.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
