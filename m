Message-ID: <452F32DF.5090608@yahoo.com.au>
Date: Fri, 13 Oct 2006 16:31:59 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/5] oom: don't kill unkillable children or siblings
References: <20061012120102.29671.31163.sendpatchset@linux.site>	<20061012120111.29671.83152.sendpatchset@linux.site> <20061012150050.ad6e1c8b.akpm@osdl.org>
In-Reply-To: <20061012150050.ad6e1c8b.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>On Thu, 12 Oct 2006 16:09:43 +0200 (CEST)
>Nick Piggin <npiggin@suse.de> wrote:
>
>
>>Abort the kill if any of our threads have OOM_DISABLE set. Having this test
>>here also prevents any OOM_DISABLE child of the "selected" process from being
>>killed.
>>
>>Signed-off-by: Nick Piggin <npiggin@suse.de>
>>
>>Index: linux-2.6/mm/oom_kill.c
>>===================================================================
>>--- linux-2.6.orig/mm/oom_kill.c
>>+++ linux-2.6/mm/oom_kill.c
>>@@ -312,15 +312,24 @@ static int oom_kill_task(struct task_str
>> 	if (mm == NULL)
>> 		return 1;
>> 
>>+	/*
>>+	 * Don't kill the process if any threads are set to OOM_DISABLE
>>+	 */
>>+	do_each_thread(g, q) {
>>+		if (q->mm == mm && p->oomkilladj == OOM_DISABLE)
>>+			return 1;
>>+	} while_each_thread(g, q);
>>+
>> 	__oom_kill_task(p, message);
>>+
>> 	/*
>> 	 * kill all processes that share the ->mm (i.e. all threads),
>> 	 * but are in a different thread group
>> 	 */
>>-	do_each_thread(g, q)
>>+	do_each_thread(g, q) {
>> 		if (q->mm == mm && q->tgid != p->tgid)
>> 			__oom_kill_task(q, message);
>>-	while_each_thread(g, q);
>>+	} while_each_thread(g, q);
>> 
>> 	return 0;
>>
>
>One wonders whether OOM_DISABLE should be a property of the mm_struct, not
>of the task_struct.
>

Hmm... I don't think I could argue with that. I think this patch is needed
in the meantime though.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
