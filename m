Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9DF396B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 22:36:02 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 6so242465yxn.26
        for <linux-mm@kvack.org>; Wed, 01 Apr 2009 19:36:35 -0700 (PDT)
Message-ID: <49D424AF.3090806@codemonkey.ws>
Date: Wed, 01 Apr 2009 21:36:31 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws> <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain>
In-Reply-To: <20090402012215.GE1117@x200.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Chris Wright wrote:
> * Anthony Liguori (anthony@codemonkey.ws) wrote:
>   
>> The ioctl() interface is quite bad for what you're doing.  You're  
>> telling the kernel extra information about a VA range in userspace.   
>> That's what madvise is for.  You're tweaking simple read/write values of  
>> kernel infrastructure.  That's what sysfs is for.
>>     
>
> I agree re: sysfs (brought it up myself before).  As far as madvise vs.
> ioctl, the one thing that comes from the ioctl is fops->release to
> automagically unregister memory on exit.

This is precisely why ioctl() is a bad interface.  fops->release isn't 
tied to the process but rather tied to the open file.  The file can stay 
open long after the process exits either by a fork()'d child inheriting 
the file descriptor or through something more sinister like SCM_RIGHTS.

In fact, a common mistake is to leak file descriptors by not closing 
them when exec()'ing a process.  Instead of just delaying a close, if 
you rely on this behavior to unregister memory regions, you could 
potentially have badness happen in the kernel if ksm attempted to access 
an invalid memory region.

So you absolutely have to automatically unregister regions in something 
other than the fops->release handler based on something that's tied to 
the pid's life cycle.

Using an interface like madvise() would force the issue to be dealt with 
properly from the start :-)

I'm often afraid of what sort of bugs we'd uncover in kvm if we passed 
the fds around via SCM_RIGHTS and started poking around :-/

Regards,

Anthony Liguori


>   This needs to be handled
> anyway if some -p pid is added to add a process after it's running,
> so less weight there.
>
> thanks,
> -chris
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
