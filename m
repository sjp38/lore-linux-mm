Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0856B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 06:48:09 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so6274742pdb.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 03:48:09 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id x4si28577770pdr.44.2015.03.17.03.48.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 03:48:08 -0700 (PDT)
Message-ID: <5508064C.7090707@huawei.com>
Date: Tue, 17 Mar 2015 18:47:40 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tracing: add trace event for memory-failure
References: <1426241451-25729-1-git-send-email-xiexiuqi@huawei.com>	<CA+8MBbKen9JfQ29AWVZuxO9CkPCmjG670q0Fg7G-qCPDrtDHig@mail.gmail.com> <20150313153210.14f1bd88@gandalf.local.home>
In-Reply-To: <20150313153210.14f1bd88@gandalf.local.home>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Chen Gong <gong.chen@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Borislav
 Petkov <bp@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jingle.chen@huawei.com

On 2015/3/14 3:32, Steven Rostedt wrote:
> On Fri, 13 Mar 2015 09:37:34 -0700
> Tony Luck <tony.luck@gmail.com> wrote:
> 
> 
>>>  int sysctl_memory_failure_early_kill __read_mostly = 0;
>>>
>>> @@ -837,6 +838,8 @@ static struct page_state {
>>>   */
>>>  static void action_result(unsigned long pfn, char *msg, int result)
>>>  {
>>> +       trace_memory_failure_event(pfn, msg, action_name[result]);
>>> +
>>>         pr_err("MCE %#lx: %s page recovery: %s\n",
>>>                 pfn, msg, action_name[result]);
>>>  }
>>> --
>>> 1.7.1
>>>
>>> --
>>
>> Concept looks good to me. Adding Steven Rostedt as we've historically had
>> challenges adding new trace points in the cleanest way.
> 
> Hehe, thank you :-) I actually do have a recommendation. How about just
> passing in "result" and doing:
> 
> 
> 	TP_printk("pfn %#lx: %s page recovery: %s",
> 		__entry->pfn,
> 		__get_str(action),
> 		__print_symbolic(result, 0, "Ignored",
> 				1, "Failed",
> 				2, "Delayed",
> 				3, "Recovered"))
> 
> 
> Now it is hard coded here because trace-cmd and perf do not have a way
> to process enums (yet, I need to fix that).

Hi Steve,

Thanks for you comments.

I'm not clearly why we need a hard coded here. As the strings or "result" have
defined in mm/memory-failure.c, so passing "action_name[result]" would be more
clean and more flexible here?

Thanks,
	Xie XiuQi

> 
> I also need a way to just submit print strings on module load and boot
> up such that you only need to pass in the address of the action field
> instead of the string. That is also a todo of mine that I may soon
> change.
> 
> -- Steve
> 
> 
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
