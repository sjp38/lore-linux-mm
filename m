Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CD8BE6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 16:23:36 -0500 (EST)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1NklAk-0004Il-ED
	for linux-mm@kvack.org; Thu, 25 Feb 2010 22:23:02 +0100
Received: from 85-222-76-212.home.aster.pl ([85.222.76.212])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 22:23:02 +0100
Received: from zenblu by 85-222-76-212.home.aster.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 22:23:02 +0100
From: Zenek <zenblu@wp.pl>
Subject: Re: vmapping user pages - feasible?
Date: Thu, 25 Feb 2010 21:22:42 +0000 (UTC)
Message-ID: <hm6pn2$rqp$2@dough.gmane.org>
References: <hm6l5q$rqp$1@dough.gmane.org>
	<alpine.DEB.2.00.1002251455550.18861@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Thank you for your response,

although I'm not sure I've understood...


On Thu, 25 Feb 2010 14:58:52 -0600, Christoph Lameter wrote:

> On Thu, 25 Feb 2010, Zenek wrote:

>> I will be writing to it using the CPU only, in kernel mode.
>>
> Thats possible already.

What about in the interrupt context?

>> I understand that:
>> - no page pinning is required (as only the CPU will be writing to that
>> area)
> 
> Page pinning is required if the access from the kernel is asynchrononous
> to user space.

Because simultaneous page faults can happen?
 
>> There will be no multithreaded access to that memory.
> 
> The kernel and userspace are not concurrently accessing the memory?

Could we take into account both cases?
1. not concurrently accessing the memory (e.g. ioctl() call, write by 
kernel, return - no more kernel access after return). I can just use the 
user mapping, right? What about page faults?
2. concurrently (e.g. ioctl() call, save the pointer in the kernel, 
return, asynchronous write by kernel). What then? What happens if user 
process calls free() on that area?

>> How should I go about it? Get the user's vm_area_struct, go through all
>> the pages, construct an array of struct *page and vmap it?
> 
> Do a get_user_pages() on the range?

Right... so do a get_user_pages(), pass them to vmap(), and write away... 
if the process messes up the mapping or dies, it's its fault anyway and 
it doesn't get the data, but everything is safe until I call vunmap... 
right?

The pages won't get swapped out until I vunmap, and after that even if 
they do, they data will get swapped and later restored correctly, right?

Thank you again!
Zenek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
