Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EF33C6B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 18:04:23 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1363338bwz.14
        for <linux-mm@kvack.org>; Tue, 17 May 2011 15:04:21 -0700 (PDT)
Message-ID: <4DD2F0E2.10100@gmail.com>
Date: Wed, 18 May 2011 00:04:18 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>	 <1305665263-20933-3-git-send-email-john.stultz@linaro.org>	 <4DD2EBAB.5080004@gmail.com> <1305669150.1722.83.camel@Joe-Laptop>
In-Reply-To: <1305669150.1722.83.camel@Joe-Laptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 05/17/2011 11:52 PM, Joe Perches wrote:
> On Tue, 2011-05-17 at 23:42 +0200, Jiri Slaby wrote:
>> On 05/17/2011 10:47 PM, John Stultz wrote:
>>> Accessing task->comm requires proper locking. However in the past
>>> access to current->comm could be done without locking. This
>>> is no longer the case, so all comm access needs to be done
>>> while holding the comm_lock.
>>> +static noinline_for_stack
>> I still fail to see why this should be slowed down by noinlining it.
>> Care to explain?
> 
> Any vsprintf is slow.
> 
>> With my setup, the code below inlined will use 32 bytes of stack. The
>> same as %pK case. Uninlined it obviously eats "only" 8 bytes for IP.
> 
> The idea is to avoid excess stack consumption for things like:
> 
> 	struct va_format vaf;
> 
> 	const char *fmt = "some format with %ptc";
> 
> 	vaf.fmt = fmt;
> 	vaf.va = &va_list;
> 
> 	printk("some format with %pV\n", &vaf);

There is no way how can noinline_for_stack for task_comm_string lower
the stack usage here, right? Note that it adds no more requirements to
the stack than there were before. Simply because there are no buffers on
the stack in task_comm_string.

If nothing, it saves 100 bytes of .text.

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
