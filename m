Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACC0A6B01B0
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 12:03:02 -0400 (EDT)
Message-ID: <4BA8E659.1030702@cs.columbia.edu>
Date: Tue, 23 Mar 2010 12:03:37 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [C/R v20][PATCH 15/96] cgroup freezer: Fix buggy resume test
 for tasks frozen with cgroup freezer
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu> <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu> <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu> <201003230028.40915.rjw@sisk.pl>
In-Reply-To: <201003230028.40915.rjw@sisk.pl>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Matt Helsley <matthltc@us.ibm.com>, Cedric Le Goater <legoater@free.fr>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Pavel Machek <pavel@ucw.cz>, linux-pm@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>



Rafael J. Wysocki wrote:
> On Wednesday 17 March 2010, Oren Laadan wrote:
>> From: Matt Helsley <matthltc@us.ibm.com>
>>
>> When the cgroup freezer is used to freeze tasks we do not want to thaw
>> those tasks during resume. Currently we test the cgroup freezer
>> state of the resuming tasks to see if the cgroup is FROZEN.  If so
>> then we don't thaw the task. However, the FREEZING state also indicates
>> that the task should remain frozen.
>>
>> This also avoids a problem pointed out by Oren Ladaan: the freezer state
>> transition from FREEZING to FROZEN is updated lazily when userspace reads
>> or writes the freezer.state file in the cgroup filesystem. This means that
>> resume will thaw tasks in cgroups which should be in the FROZEN state if
>> there is no read/write of the freezer.state file to trigger this
>> transition before suspend.
>>
>> NOTE: Another "simple" solution would be to always update the cgroup
>> freezer state during resume. However it's a bad choice for several reasons:
>> Updating the cgroup freezer state is somewhat expensive because it requires
>> walking all the tasks in the cgroup and checking if they are each frozen.
>> Worse, this could easily make resume run in N^2 time where N is the number
>> of tasks in the cgroup. Finally, updating the freezer state from this code
>> path requires trickier locking because of the way locks must be ordered.
>>
>> Instead of updating the freezer state we rely on the fact that lazy
>> updates only manage the transition from FREEZING to FROZEN. We know that
>> a cgroup with the FREEZING state may actually be FROZEN so test for that
>> state too. This makes sense in the resume path even for partially-frozen
>> cgroups -- those that really are FREEZING but not FROZEN.
>>
>> Reported-by: Oren Ladaan <orenl@cs.columbia.edu>
>> Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
>> Cc: Cedric Le Goater <legoater@free.fr>
>> Cc: Paul Menage <menage@google.com>
>> Cc: Li Zefan <lizf@cn.fujitsu.com>
>> Cc: Rafael J. Wysocki <rjw@sisk.pl>
>> Cc: Pavel Machek <pavel@ucw.cz>
>> Cc: linux-pm@lists.linux-foundation.org
> 
> Looks reasonable.
> 
> Is anyone handling that already or do you want me to take it to my tree?

Yes, please do.

Thanks !

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
