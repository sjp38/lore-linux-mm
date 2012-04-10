Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DE7AA6B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 16:09:19 -0400 (EDT)
Received: by lbao2 with SMTP id o2so207756lba.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2012 13:09:18 -0700 (PDT)
Message-ID: <4F84936A.1060708@openvz.org>
Date: Wed, 11 Apr 2012 00:09:14 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: correctly synchronize rss-counters at exit/exec
References: <20120409200336.8368.63793.stgit@zurg> <20120410170732.18750.64274.stgit@zurg> <20120410191059.GA5678@redhat.com>
In-Reply-To: <20120410191059.GA5678@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Oleg Nesterov wrote:
> On 04/10, Konstantin Khlebnikov wrote:
>>
>> This patch moves sync_mm_rss() into mm_release(), and moves mm_release() out of
>> do_exit() and calls it earlier. After mm_release() there should be no page-faults.
>
> Can't prove, but I feel there should be a simpler fix...
>
> Anyway, this patch is not exactly correct.
>
>> @@ -959,9 +959,10 @@ void do_exit(long code)
>>   				preempt_count());
>>
>>   	acct_update_integrals(tsk);
>> -	/* sync mm's RSS info before statistics gathering */
>> -	if (tsk->mm)
>> -		sync_mm_rss(tsk->mm);
>> +
>> +	/* Release mm and sync mm's RSS info before statistics gathering */
>> +	mm_release(tsk, tsk->mm);
>
> This breaks kthread_stop() at least.
>
> The exiting kthread shouldn't do complete_vfork_done() until it
> sets ->exit_code.

Ouch, I was afraid something like that.

>
> Oleg.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
