Message-ID: <47EB5D07.9020601@openvz.org>
Date: Thu, 27 Mar 2008 11:38:31 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC][2/3] Account and control virtual address space allocations
 (v2)
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain> <20080326185017.9465.29950.sendpatchset@localhost.localdomain> <47EB4A7E.6060505@openvz.org> <47EB548D.2050609@linux.vnet.ibm.com> <47EB59C3.3080803@openvz.org> <47EB5B27.2050907@linux.vnet.ibm.com>
In-Reply-To: <47EB5B27.2050907@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[snip]

>>>>> +	css_put(&mem->css);
>>>> Why don't you check whether the counter is charged? This is
>>>> bad for two reasons:
>>>> 1. you allow for some growth above the limit (e.g. in expand_stack)
>>> I was doing that earlier and then decided to keep the virtual address space code
>>> in sync with the RLIMIT_AS checking code in the kernel. If you see the flow, it
>>> closely resembles what we do with mm->total_vm and may_expand_vm().
>>> expand_stack() in turn calls acct_stack_growth() which calls may_expand_vm()
>> But this is racy! Look - you do expand_stack on two CPUs and the limit is
>> almost reached - so that there's room for a single expansion. In this case 
>> may_expand_vm will return true for both, since it only checks the limit, 
>> while the subsequent charge will fail on one of them, since it actually 
>> tries to raise the usage...
>>
> 
> Hmm... yes, possibly. Thanks for pointing this out. For a single mm_struct, the
> check is done under mmap_sem(), so it's OK for processes. I suspect, I'll have

Sure, but this controller should work with arbitrary group of processes ;)

> to go back to what I had earlier. I don't want to add a mutex to mem_cgroup,
> that will hurt parallelism badly.

My opinion is that we should always perform a pure charge without any
pre-checks, etc.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
