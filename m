Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id EB2FB6B00F5
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 02:43:16 -0400 (EDT)
Received: by lbao2 with SMTP id o2so2829357lba.14
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 23:43:14 -0700 (PDT)
Message-ID: <4F87CAFF.2010407@openvz.org>
Date: Fri, 13 Apr 2012 10:43:11 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: call complete_vfork_done() after clearing child_tid
 and flushing rss-counters
References: <20120409200336.8368.63793.stgit@zurg> <20120412080952.26401.2025.stgit@zurg> <20120412163953.4cd2314d.akpm@linux-foundation.org>
In-Reply-To: <20120412163953.4cd2314d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Andrew Morton wrote:
> On Thu, 12 Apr 2012 12:09:53 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> Child should wake ups parent from vfork() only after finishing all operations with
>> shared mm. There is no sense to use CLONE_CHILD_CLEARTID together with CLONE_VFORK,
>> but it looks more accurate now.
>>
>> ...
>>
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -728,9 +728,6 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
>>   	/* Get rid of any cached register state */
>>   	deactivate_mm(tsk, mm);
>>
>> -	if (tsk->vfork_done)
>> -		complete_vfork_done(tsk);
>> -
>>   	/*
>>   	 * If we're exiting normally, clear a user-space tid field if
>>   	 * requested.  We leave this alone when dying by signal, to leave
>> @@ -759,6 +756,13 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
>>   	 */
>>   	if (mm)
>>   		sync_mm_rss(mm);
>> +
>> +	/*
>> +	 * All done, finally we can wake up parent and return this mm to him.
>> +	 * Also kthread_stop() uses this completion for synchronization.
>> +	 */
>> +	if (tsk->vfork_done)
>> +		complete_vfork_done(tsk);
>>   }
>
> That does look a bit racy.
>
> But are we really sure that the patch really does fix something?
> Because it does increase vfork() latency a tiny bit.
>
> I'm going to call this a patch against the fork subsystem, not the mm
> subsystem.
>
> I believe that this patch is unrelated to "mm: set task exit code
> before complete_vfork_done()", yes?

Yes, unrelated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
