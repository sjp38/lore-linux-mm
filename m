Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id D5EC76B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 21:56:49 -0400 (EDT)
Received: from mail-ee0-f41.google.com ([74.125.83.41])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TNwOm-0003TH-R2
	for linux-mm@kvack.org; Tue, 16 Oct 2012 01:56:48 +0000
Received: by mail-ee0-f41.google.com with SMTP id c4so3612754eek.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:56:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121015154724.GA2840@barrios>
References: <1350278059-14904-1-git-send-email-ming.lei@canonical.com>
	<1350278059-14904-2-git-send-email-ming.lei@canonical.com>
	<20121015154724.GA2840@barrios>
Date: Tue, 16 Oct 2012 09:56:48 +0800
Message-ID: <CACVXFVM09H=8ZuFSzkcN1NmOCR1pcPUsuUyT9tpR0doVam2BiQ@mail.gmail.com>
Subject: Re: [RFC PATCH 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Jiri Kosina <jiri.kosina@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Mon, Oct 15, 2012 at 11:47 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Mon, Oct 15, 2012 at 01:14:17PM +0800, Ming Lei wrote:
>> This patch introduces PF_MEMALLOC_NOIO on process flag('flags' field of
>> 'struct task_struct'), so that the flag can be set by one task
>> to avoid doing I/O inside memory allocation in the task's context.
>>
>> The patch trys to solve one deadlock problem caused by block device,
>> and the problem can be occured at least in the below situations:
>>
>> - during block device runtime resume situation, if memory allocation
>> with GFP_KERNEL is called inside runtime resume callback of any one
>> of its ancestors(or the block device itself), the deadlock may be
>> triggered inside the memory allocation since it might not complete
>> until the block device becomes active and the involed page I/O finishes.
>> The situation is pointed out first by Alan Stern. It is not a good
>> approach to convert all GFP_KERNEL in the path into GFP_NOIO because
>> several subsystems may be involved(for example, PCI, USB and SCSI may
>> be involved for usb mass stoarage device)
>
> Couldn't we expand pm_restrict_gfp_mask to cover resume path as well as
> suspend path?

IMO, we could, but it is not good and might trigger memory allocation problem.

pm_restrict_gfp_mask uses the global variable of gfp_allowed_mask to
avoid allocating page with GFP_IOFS in all contexts during system sleep,
when processes have been frozen.

But during runtime PM, the whole system is running and all processes are
runnable. Also runtime PM is per device and the whole system may have
lots of devices, so taking the global gfp_allowed_mask may keep page
allocation with ~GFP_IOFS for a considerable proportion of system
running time, then alloc_page() will return failure easier.

The above deadlock problem may be fixed by allocating memory with
~GFP_IOFS only in the context of calling runtime_resume, and that is
idea of the patch.

>
>>
>> - during error handling situation of usb mass storage deivce, USB
>> bus reset will be put on the device, so there shouldn't have any
>> memory allocation with GFP_KERNEL during USB bus reset, otherwise
>> the deadlock similar with above may be triggered. Unfortunately, any
>> usb device may include one mass storage interface in theory, so it
>> requires all usb interface drivers to handle the situation. In fact,
>> most usb drivers don't know how to handle bus reset on the device
>> and don't provide .pre_set() and .post_reset() callback at all, so
>> USB core has to unbind and bind driver for these devices. So it
>> is still not practical to resort to GFP_NOIO for solving the problem.
>
> I hope this case could be handled by usb core like usb_restrict_gfp_mask
> rather than adding new branch on fast path.

See above, applying the global gfp_allowed_mask is not good.


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
