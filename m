Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id E8DC56B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 10:30:52 -0400 (EDT)
Received: by lagz14 with SMTP id z14so2140540lag.14
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 07:30:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F86D733.50809@parallels.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
	<4F86BA66.2010503@jp.fujitsu.com>
	<4F86D733.50809@parallels.com>
Date: Thu, 12 Apr 2012 16:30:50 +0200
Message-ID: <CAFTL4hyKOkoTv=717MkYx4QB0j3B6xA0ZPp1jg6HkrtTkAu7nQ@mail.gmail.com>
Subject: Re: [PATCH 1/7] res_counter: add a function res_counter_move_parent().
From: Frederic Weisbecker <fweisbec@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

2012/4/12 Glauber Costa <glommer@parallels.com>:
> On 04/12/2012 08:20 AM, KAMEZAWA Hiroyuki wrote:
>>
>> This function is used for moving accounting information to its
>> parent in the hierarchy of res_counter.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> Frederic has a patch in his fork cgroup series, that allows you to
> uncharge a counter until you reach a specific ancestor.
> You pass the parent as a parameter, and then only you gets uncharged.

I'm missing the referring patchset from Kamezawa. Ok I'm going to
subscribe to the
cgroup mailing list. Meanwhile perhaps would it be nice to keep Cc
LKML for cgroup patches?

Some comments below:

>
> I think that is a much better interface than this you are proposing.
> We should probably merge that patch and use it.
>
>> ---
>> =A0 include/linux/res_counter.h | =A0 =A03 +++
>> =A0 kernel/res_counter.c =A0 =A0 =A0 =A0| =A0 13 +++++++++++++
>> =A0 2 files changed, 16 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>> index da81af0..8919d3c 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -135,6 +135,9 @@ int __must_check res_counter_charge_nofail(struct re=
s_counter *counter,
>> =A0 void res_counter_uncharge_locked(struct res_counter *counter, unsign=
ed long val);
>> =A0 void res_counter_uncharge(struct res_counter *counter, unsigned long=
 val);
>>
>> +/* move resource to parent counter...i.e. just forget accounting in a c=
hild */
>> +void res_counter_move_parent(struct res_counter *counter, unsigned long=
 val);
>> +
>> =A0 /**
>> =A0 =A0* res_counter_margin - calculate chargeable space of a counter
>> =A0 =A0* @cnt: the counter
>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>> index d508363..fafebf0 100644
>> --- a/kernel/res_counter.c
>> +++ b/kernel/res_counter.c
>> @@ -113,6 +113,19 @@ void res_counter_uncharge(struct res_counter *count=
er, unsigned long val)
>> =A0 =A0 =A0 local_irq_restore(flags);
>> =A0 }
>>
>> +/*
>> + * In hierarchical accounting, child's usage is accounted into ancestor=
s.
>> + * To move local usage to its parent, just forget current level usage.

The way I understand this comment and the changelog matches the opposite
of what the below function is doing.

The function charges a child and ignore all its parents. The comments says =
it
charges the parents but not the child.

>> + */
>> +void res_counter_move_parent(struct res_counter *counter, unsigned long=
 val)
>> +{
>> + =A0 =A0 unsigned long flags;
>> +
>> + =A0 =A0 BUG_ON(!counter->parent);
>> + =A0 =A0 spin_lock_irqsave(&counter->lock, flags);
>> + =A0 =A0 res_counter_uncharge_locked(counter, val);
>> + =A0 =A0 spin_unlock_irqrestore(&counter->lock, flags);
>> +}
>>
>> =A0 static inline unsigned long long *
>> =A0 res_counter_member(struct res_counter *counter, int member)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
