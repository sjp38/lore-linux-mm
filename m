Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 924EC6B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 07:27:23 -0400 (EDT)
Message-ID: <49D4A016.9040506@redhat.com>
Date: Thu, 02 Apr 2009 14:23:02 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws> <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain> <49D424AF.3090806@codemonkey.ws>
In-Reply-To: <49D424AF.3090806@codemonkey.ws>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Chris Wright <chrisw@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Anthony Liguori wrote:
> Chris Wright wrote:
>> * Anthony Liguori (anthony@codemonkey.ws) wrote:
>>  
>>> The ioctl() interface is quite bad for what you're doing.  You're  
>>> telling the kernel extra information about a VA range in 
>>> userspace.   That's what madvise is for.  You're tweaking simple 
>>> read/write values of  kernel infrastructure.  That's what sysfs is for.
>>>     
>>
>> I agree re: sysfs (brought it up myself before).  As far as madvise vs.
>> ioctl, the one thing that comes from the ioctl is fops->release to
>> automagically unregister memory on exit.
>
> This is precisely why ioctl() is a bad interface.  fops->release isn't 
> tied to the process but rather tied to the open file.  The file can 
> stay open long after the process exits either by a fork()'d child 
> inheriting the file descriptor or through something more sinister like 
> SCM_RIGHTS.
>
> In fact, a common mistake is to leak file descriptors by not closing 
> them when exec()'ing a process.  Instead of just delaying a close, if 
> you rely on this behavior to unregister memory regions, you could 
> potentially have badness happen in the kernel if ksm attempted to 
> access an invalid memory region. 
How could such badness ever happen in the kernel?
Ksm work by virtual addresses!, it fetch the pages by using 
get_user_pages(), and the mm struct is protected by get_task_mm(), in 
addion we take the down_read(mmap_sem)

So how could ksm ever acces to invalid memory region unless the host 
page table or get_task_mm() would stop working!

When someone register memory for scan, we do get_task_mm() when the file 
is closed or when he say that he dont want this to be registered anymore 
he call the unregister ioctl


You can aurgoment about API, but this is mathamathical thing to say Ksm 
is insecure, please show me senario!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
