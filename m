Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 260109000BD
	for <linux-mm@kvack.org>; Sat, 24 Sep 2011 09:42:10 -0400 (EDT)
Message-ID: <4E7DDDE5.6050001@parallels.com>
Date: Sat, 24 Sep 2011 10:40:53 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/7] socket: initial cgroup code.
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-3-git-send-email-glommer@parallels.com> <CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com> <4E7A342B.5040608@parallels.com> <CAHH2K0Z_2LJPL0sLVHqkh_6b_BLQnknULTB9a9WfEuibk5kONg@mail.gmail.com> <CAKTCnz=59HuEg9T-USi5oKSK=F+vr2QxCA17+i-rGj73k49rzw@mail.gmail.com>
In-Reply-To: <CAKTCnz=59HuEg9T-USi5oKSK=F+vr2QxCA17+i-rGj73k49rzw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On 09/22/2011 12:09 PM, Balbir Singh wrote:
> On Thu, Sep 22, 2011 at 11:30 AM, Greg Thelen<gthelen@google.com>  wrote:
>> On Wed, Sep 21, 2011 at 11:59 AM, Glauber Costa<glommer@parallels.com>  wrote:
>>> Right now I am working under the assumption that tasks are long lived inside
>>> the cgroup. Migration potentially introduces some nasty locking problems in
>>> the mem_schedule path.
>>>
>>> Also, unless I am missing something, the memcg already has the policy of
>>> not carrying charges around, probably because of this very same complexity.
>>>
>>> True that at least it won't EBUSY you... But I think this is at least a way
>>> to guarantee that the cgroup under our nose won't disappear in the middle of
>>> our allocations.
>>
>> Here's the memcg user page behavior using the same pattern:
>>
>> 1. user page P is allocate by task T in memcg M1
>> 2. T is moved to memcg M2.  The P charge is left behind still charged
>> to M1 if memory.move_charge_at_immigrate=0; or the charge is moved to
>> M2 if memory.move_charge_at_immigrate=1.
>> 3. rmdir M1 will try to reclaim P (if P was left in M1).  If unable to
>> reclaim, then P is recharged to parent(M1).
>>
>
> We also have some magic in page_referenced() to remove pages
> referenced from different containers. What we do is try not to
> penalize a cgroup if another cgroup is referencing this page and the
> page under consideration is being reclaimed from the cgroup that
> touched it.
>
> Balbir Singh
Btw:

This has the same problem we'll face for any kmem related memory in the 
cgroup: We can't just force reclaim to make the cgroup empty...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
