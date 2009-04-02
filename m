Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0D2346B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 09:36:35 -0400 (EDT)
Message-ID: <49D4BE64.8020508@redhat.com>
Date: Thu, 02 Apr 2009 16:32:20 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/4] update ksm userspace interfaces
References: <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain> <49D424AF.3090806@codemonkey.ws> <20090402053114.GF1117@x200.localdomain>
In-Reply-To: <20090402053114.GF1117@x200.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Chris Wright wrote:
> * Anthony Liguori (anthony@codemonkey.ws) wrote:
>   
>> Using an interface like madvise() would force the issue to be dealt with  
>> properly from the start :-)
>>     
>
> Yeah, I'm not at all opposed to it.
>
> This updates to madvise for register and sysfs for control.
>
> madvise issues:
> - MADV_SHAREABLE
>   - register only ATM, can add MADV_UNSHAREABLE to allow an app to proactively
>     unregister, but need a cleanup when ->mm goes away via exit/exec
>   - will register a region per vma, should probably push the whole thing
>     into vma rather than keep [mm,addr,len] tuple in ksm
>
>   
The main problem that ksm will face when removing the fd interface is:
right now when you register memory into ksm, you open fd, and then ksm 
do get_task_mm(), we will do mmput when the file will be closed
(note that this doesnt mean that if you fork and not close the fd the 
memory wont go away...., get_task_mm() doesnt protect the vmas inside 
the mm strcture and therefore they will be able to get removed)

So if we move into madvice and we remove the get_task_mm() usage, we 
will have to add notification to exit_mm() so ksm will know it should 
stop using this mm strcture, and drop it from all the trees data...

Is this what we want?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
