Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E1A846B0096
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 13:28:18 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so94928243pdb.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:28:18 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id u4si4255444pdh.9.2015.06.19.10.28.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 10:28:17 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQ700294CJ17Z20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Jun 2015 18:28:13 +0100 (BST)
Message-id: <5584512B.5020301@samsung.com>
Date: Fri, 19 Jun 2015 19:28:11 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v3 1/4] fs: Add generic file system event notifications
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
 <20150617230605.GK10224@dastard> <55828064.5040301@samsung.com>
 <20150619000341.GM10224@dastard>
In-reply-to: <20150619000341.GM10224@dastard>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, greg@kroah.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On 06/19/2015 02:03 AM, Dave Chinner wrote:
> On Thu, Jun 18, 2015 at 10:25:08AM +0200, Beata Michalska wrote:
>> On 06/18/2015 01:06 AM, Dave Chinner wrote:
>>> On Tue, Jun 16, 2015 at 03:09:30PM +0200, Beata Michalska wrote:
>>>> Introduce configurable generic interface for file
>>>> system-wide event notifications, to provide file
>>>> systems with a common way of reporting any potential
>>>> issues as they emerge.
>>>>
>>>> The notifications are to be issued through generic
>>>> netlink interface by newly introduced multicast group.
>>>>
>>>> Threshold notifications have been included, allowing
>>>> triggering an event whenever the amount of free space drops
>>>> below a certain level - or levels to be more precise as two
>>>> of them are being supported: the lower and the upper range.
>>>> The notifications work both ways: once the threshold level
>>>> has been reached, an event shall be generated whenever
>>>> the number of available blocks goes up again re-activating
>>>> the threshold.
>>>>
>>>> The interface has been exposed through a vfs. Once mounted,
>>>> it serves as an entry point for the set-up where one can
>>>> register for particular file system events.
>>>>
>>>> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
>>>
>>> This has massive scalability problems:
> ....
>>> Have you noticed that the filesystems have percpu counters for
>>> tracking global space usage? There's good reason for that - taking a
>>> spinlock in such a hot accounting path causes severe contention.
> ....
>>> Then puts the entire netlink send path inside this spinlock, which
>>> includes memory allocation and all sorts of non-filesystem code
>>> paths. And it may be inside critical filesystem locks as well....
>>>
>>> Apart from the serialisation problem of the locking, adding
>>> memory allocation and the network send path to filesystem code
>>> that is effectively considered "innermost" filesystem code is going
>>> to have all sorts of problems for various filesystems. In the XFS
>>> case, we simply cannot execute this sort of function in the places
>>> where we update global space accounting.
>>>
>>> As it is, I think the basic concept of separate tracking of free
>>> space if fundamentally flawed. What I think needs to be done is that
>>> filesystems need access to the thresholds for events, and then the
>>> filesystems call fs_event_send_thresh() themselves from appropriate
>>> contexts (ie. without compromising locking, scalability, memory
>>> allocation recursion constraints, etc).
>>>
>>> e.g. instead of tracking every change in free space, a filesystem
>>> might execute this once every few seconds from a workqueue:
>>>
>>> 	event = fs_event_need_space_warning(sb, <fs_free_space>)
>>> 	if (event)
>>> 		fs_event_send_thresh(sb, event);
>>>
>>> User still gets warnings about space usage, but there's no runtime
>>> overhead or problems with lock/memory allocation contexts, etc.
>>
>> Having fs to keep a firm hand on thresholds limits would indeed be
>> far more sane approach though that would require each fs to
>> add support for that and handle most of it on their own. Avoiding
>>> this was the main rationale behind this rfc.
>> If fs people agree to that, I'll be more than willing to drop this
>> in favour of the per-fs tracking solution. 
>> Personally, I hope they will.
> 
> I was hoping that you'd think a little more about my suggestion and
> work out how to do background threshold event detection generically.
> I kind of left it as "an exercise for the reader" because it seems
> obvious to me.
> 
> Hint: ->statfs allows you to get the total, free and used space
> from filesystems in a generic manner.
> 
> Cheers,
> 
> Dave.
> 

I haven't given up on that, so yes, I'm still working on a more suitable
generic solution.
Background detection is one of the options, though it needs some more thoughts.
Giving up the sync approach means less accuracy for the threshold notifications,
but I guess this could be fine-tuned to get an acceptable level. Another bump:
how this tuning is supposed to be done (additional config option maybe)? 
The interface would have to keep it somehow sane - but what would 'sane' mean
in this case (?) Also, I'm not sure whether single approach would server here
well for all the potentially supported file systems so this would have to be
properly adjusted (taking the threshold levels into consideration as well). 
And still,it would require some form of synchronization with tracked fs so that
this 'detection' is not being unnecessarily performed (i.e. while fs remains frozen).

There is also an idea of using an interface resembling the stackable fs:
a transparent file system layered on top of the tracked one 
(solely for the tracking purposes). This would simplify handling the trace 
object's lifetime - no more list of registered traces.
It would also give a way of tracking (to some extent) the changes in the amount
of available space, which combined with tweaked background check could give
a solution with less performance overhead than the original one.
I'll try this one and see how it goes.

Thank You for your feedback so far - I really appreciate it.


Best Regards
Beata 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
