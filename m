Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m2RESKVl001417
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 07:28:20 -0700
Received: from py-out-1112.google.com (pyia25.prod.google.com [10.34.253.25])
	by zps37.corp.google.com with ESMTP id m2RESJGW030141
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 07:28:19 -0700
Received: by py-out-1112.google.com with SMTP id a25so5776534pyi.13
        for <linux-mm@kvack.org>; Thu, 27 Mar 2008 07:28:19 -0700 (PDT)
Message-ID: <6599ad830803270728y354b567s7bfe8cb7472aa065@mail.gmail.com>
Date: Thu, 27 Mar 2008 07:28:18 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][0/3] Virtual address space control for cgroups (v2)
In-Reply-To: <47EB5528.8070800@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
	 <6599ad830803261522p45a9daddi8100a0635c21cf7d@mail.gmail.com>
	 <47EB5528.8070800@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 27, 2008 at 1:04 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  I thought I addressed some of those by adding a separate config option. You
>  could enable just the address space control, by letting memory.limit_in_bytes at
>  the maximum value it is at (at the moment).
>

Having a config option is better than none at all, certainly for
people who roll their own kernels. But what config choice should a
distro make when they're deciding what to build into their kernel
configuration?

It's much easier to decide to build in a feature that can be ignored
by those who don't use it.

>
>  Yes, I agree with the overhead philosophy. I suspect that users will enable
>  both. I am not against making it a separate controller. I am still hopeful of
>  getting the mm->owner approach working
>

I was thinking more about that, and I think I found a possibly fatal flaw:


>
>  >
>  > Trying to account/control physical memory or swap usage via virtual
>  > address space limits is IMO a hopeless task. Taking Google's
>  > production clusters and the virtual server systems that I worked on in
>  > my previous job as real-life examples that I've encountered, there's
>  > far too much variety of application behaviour (including Java apps
>  > that have massive sparse heaps, jobs with lots of forked children
>  > sharing pages but not address spaces with their parents, and multiple
>  > serving processes mapping large shared data repositories from SHM
>  > segments) that saying VA = RAM + swap is going to break lots of jobs.
>  > But pushing up the VA limit massively makes it useless for the purpose
>  > of preventing excessive swapping. If you want to prevent excessive
>  > swap space usage without breaking a large class of apps, you need to
>  > limit swap space, not virtual address space.
>  >
>  > Additionally, you suggested that VA limits provide a "soft-landing".
>  > But I'm think that the number of applications that will do much other
>  > than abort() if mmap() returns ENOMEM is extremely small - I'd be
>  > interested to hear if you know of any.
>  >
>
>  What happens if swap is completely disabled? Should the task running be OOM
>  killed in the container?

Yes, I think so.

>  How does the application get to know that it is
>  reaching its limit?

That's something that needs to be addressed outside of the concept of
cgroups too.

> I suspect the system administrator will consider
>  vm.overcommit_ratio while setting up virtual address space limits and real page
>  usage limit. As far as applications failing gracefully is concerned, my opinion is
>
>  1. Lets not be dictated by bad applications to design our features
>  2. Autonomic computing is forcing applications to see what resources
>  applications do have access to

Yes, you're right - I shouldn't be arguing this based on current apps,
I should be thinking of the potential for future apps.

>  3. Swapping is expensive, so most application developers, I spoken to at
>  conferences, recently, state that they can manage their own memory, provided
>  they are given sufficient hints from the OS. An mmap() failure, for example can
>  force the application to free memory it is not currently using or trigger the
>  garbage collector in a managed environment.

But the problem that I have with this is that mmap() is only very
loosely connected with physical memory. If we're trying to help
applications avoid swapping, and giving them advance warning that
they're running out of physical memory, then we should do exactly
that, not try to treat address space as a proxy for physical memory.
For apps where there's a close correspondence between virtual address
space and physical memory, this should work equally well. For apps
that use a lot more virtual address space than physical memory this
should work much better.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
