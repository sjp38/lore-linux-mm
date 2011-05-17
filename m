Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C928C6B0022
	for <linux-mm@kvack.org>; Tue, 17 May 2011 03:21:32 -0400 (EDT)
Received: by bwz17 with SMTP id 17so376434bwz.14
        for <linux-mm@kvack.org>; Tue, 17 May 2011 00:21:28 -0700 (PDT)
Message-ID: <4DD221F4.5030708@gmail.com>
Date: Tue, 17 May 2011 09:21:24 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>	 <1305580757-13175-3-git-send-email-john.stultz@linaro.org>	 <4DD19D10.3000201@gmail.com>  <1305587432.2915.57.camel@work-vm> <1305590200.2503.48.camel@Joe-Laptop>
In-Reply-To: <1305590200.2503.48.camel@Joe-Laptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 05/17/2011 01:56 AM, Joe Perches wrote:
> On Mon, 2011-05-16 at 16:10 -0700, John Stultz wrote:
>> On Mon, 2011-05-16 at 23:54 +0200, Jiri Slaby wrote:
>>>> In my attempt to clean up unprotected comm access, I've noticed
>>>> most comm access is done for printk output. To simplify correct
>>>> locking in these cases, I've introduced a new %ptc format,
>>>> which will print the corresponding task's comm.
>>>> Example use:
>>>> printk("%ptc: unaligned epc - sending SIGBUS.\n", current);
>>>> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> []
>>>> +static noinline_for_stack
>>> Actually, why noinline? Did your previous version have there some
>>> TASK_COMM_LEN buffer or anything on stack which is not there anymore?
>> No, I was just following how almost all of the pointer() called
>> functions were declared.
>> But with two pointers and a long, I add more then ip6_string() has on
>> the stack, which uses the same notation.
>> But I can drop that bit if there's really no need for it.
> 
> vsprintf can be recursive, I think you should keep it.

Why? pointer is marked as noinline. The others in pointer are marked as
noinline because they really have buffers on stack. There is no reason
to have noinline for task_comm_string though. I guess all tsk, ret and
flags will be optimized that way so they will be in registers, not on
stack at all.

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
