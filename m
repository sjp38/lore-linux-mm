Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B6F966B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 01:49:51 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so4686348pab.26
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 22:49:51 -0700 (PDT)
Message-ID: <52427970.8010905@windriver.com>
Date: Wed, 25 Sep 2013 13:49:36 +0800
From: Ming Liu <ming.liu@windriver.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom: avoid killing init if it assume the oom killed thread's
 mm
References: <1379929528-19179-1-git-send-email-ming.liu@windriver.com> <alpine.DEB.2.02.1309241933590.26187@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309241933590.26187@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/25/2013 10:34 AM, David Rientjes wrote:
> On Mon, 23 Sep 2013, Ming Liu wrote:
>
>> After selecting a task to kill, the oom killer iterates all processes and
>> kills all other user threads that share the same mm_struct in different
>> thread groups.
>>
>> But in some extreme cases, the selected task happens to be a vfork child
>> of init process sharing the same mm_struct with it, which causes kernel
>> panic on init getting killed. This panic is observed in a busybox shell
>> that busybox itself is init, with a kthread keeps consuming memories.
>>
> We shouldn't be selecting a process where mm == init_mm in the first
> place, so this wouldn't fix the issue entirely.

But if we add a control point for "mm == init_mm" in the first place(ie. 
in oom_unkillable_task), that would forbid the processes sharing mm with 
init to be selected, is that reasonable? Actually my fix is just to 
protect init process to be killed for its vfork child being selected and 
I think it's the only place where there is the risk. If my understanding 
is wrong, pls correct me.

Thanks,
Ming Liu
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
