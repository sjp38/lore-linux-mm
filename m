Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1JERF6M246518
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 01:27:15 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JEDerM128732
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 01:13:40 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JEAAED017066
	for <linux-mm@kvack.org>; Tue, 20 Feb 2007 01:10:10 +1100
Message-ID: <45D9AFBE.5020107@in.ibm.com>
Date: Mon, 19 Feb 2007 19:40:06 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH][2/4] Add RSS accounting and control
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop> <20070219065034.3626.2658.sendpatchset@balbir-laptop> <20070219005828.3b774d8f.akpm@linux-foundation.org> <45D97DF8.5080000@in.ibm.com> <20070219030141.42c65bc0.akpm@linux-foundation.org> <45D9856D.1070902@in.ibm.com> <20070219032352.2856af36.akpm@linux-foundation.org> <45D9906F.2090605@in.ibm.com> <6599ad830702190409x4f64e56ex4044a12d949e44af@mail.gmail.com>
In-Reply-To: <6599ad830702190409x4f64e56ex4044a12d949e44af@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, xemul@sw.ru, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 2/19/07, Balbir Singh <balbir@in.ibm.com> wrote:
>>> More worrisome is the potential for use-after-free.  What prevents the
>>> pointer at mm->container from referring to freed memory after we're dropped
>>> the lock?
>>>
>> The container cannot be freed unless all tasks holding references to it are
>> gone,
> 
> ... or have been moved to other containers. If you're not holding
> task->alloc_lock or one of the container mutexes, there's nothing to
> stop the task being moved to another container, and the container
> being deleted.
> 
> If you're in an RCU section then you can guarantee that the container
> (that you originally read from the task) and its subsystems at least
> won't be deleted while you're accessing them, but for accounting like
> this I suspect that's not enough, since you need to be adding to the
> accounting stats on the correct container. I think you'll need to hold
> mm->container_lock for the duration of memctl_update_rss()
> 
> Paul
> 

Yes, that sounds like the correct thing to do.

-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
