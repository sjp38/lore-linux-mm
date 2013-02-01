Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 5E16A6B002D
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 22:40:34 -0500 (EST)
Message-ID: <510B3902.6040804@cn.fujitsu.com>
Date: Fri, 01 Feb 2013 11:39:46 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>        <1359463973.1624.15.camel@kernel> <5108F2B3.3090506@cn.fujitsu.com>       <1359595344.1557.13.camel@kernel> <5109E59F.5080104@cn.fujitsu.com>      <1359613162.1587.0.camel@kernel> <510A18FA.2010107@cn.fujitsu.com>     <1359622123.1391.19.camel@kernel> <510A3CE6.202@cn.fujitsu.com>    <1359628705.2048.5.camel@kernel> <510B1B4B.5080207@huawei.com>   <1359682576.3574.1.camel@kernel> <510B20F9.10408@cn.fujitsu.com>  <1359685040.1303.6.camel@kernel> <510B2B8A.7040407@cn.fujitsu.com> <1359687985.1303.15.camel@kernel>
In-Reply-To: <1359687985.1303.15.camel@kernel>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Simon,

On 02/01/2013 11:06 AM, Simon Jeons wrote:
>
> How can distinguish map and use? I mean how can confirm memory is used
> by kernel instead of map?

If the page is free, for example, it is in the buddy system, it is not 
in use.
Even if it is direct mapped by kernel, the kernel logic should not to 
access it
because you didn't allocate it. This is the kernel's logic. Of course 
the hardware
and the user will not know this.

You want to access some memory, you should first have a logic address, 
right?
So how can you get a logic address ?  You call alloc api.

For example, when you are coding, of course you write:

p = alloc_xxx(); ---- allocate memory, now, it is in use, alloc_xxx() 
makes kernel know it.
*p = ......      ---- use the memory

You won't write:
p = 0xFFFF8745;  ---- if so, kernel doesn't know it is in use
*p = ......      ---- wrong...

right ?

The kernel mapped a page, it doesn't mean it is using the page. You 
should allocate it.
That is just the kernel's allocating logic.

Well, I think I can only give you this answer now. If you want something 
deeper, I think
you need to read how the kernel manage the physical pages. :)

>
> 1) If user process and kenel map to same physical memory, user process
> will get SIGSEGV during #PF if access to this memory, but If user proces
> s will map to the same memory which kernel map? Why? It can't access it.

When you call malloc() to allocate memory in user space, the OS logic will
assure that you won't map a page that has already been used by kernel.

A page is mapped by kernel, but not used by kernel (not allocated, like 
above),
malloc() could allocate it, and map it to user space. This is the situation
you are talking about, right ?

Now it is mapped by kernel and user, but it is only allocated by user. 
So the kernel
will not use it. When the kernel wants some memory, it will allocate 
some other memory.
This is just the kernel logic. This is what memory management subsystem 
does.

I think I cannot answer more because I'm also a student in memory 
management.
This is just my understanding. And I hope it is helpful. :)

> 2) If two user processes map to same physical memory, what will happen
> if one process access the memory?

Obviously you don't need to worry about this situation. We can swap the page
used by process 1 out, and process 2 can use the same page. When process 
1 wants
to access it again, we swap it in. This only happens when the physical 
memory
is not enough to use. :)

And also, if you are using shared memory in user space, like

shmget(), shmat()......

it is the shared memory, both processes can use it at the same time.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
