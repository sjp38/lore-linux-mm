Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC946B006C
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:11:05 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so122269687pdb.2
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 02:11:04 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id vi11si15911881pab.48.2015.04.17.02.11.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 02:11:04 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMY005WS1RJGJ70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 17 Apr 2015 10:16:31 +0100 (BST)
Message-id: <5530CE22.8080903@samsung.com>
Date: Fri, 17 Apr 2015 11:10:58 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <552F308F.1050505@redhat.com> <552F75D6.4030902@samsung.com>
 <alpine.LSU.2.11.1504161229450.17935@eggly.anvils>
In-reply-to: <alpine.LSU.2.11.1504161229450.17935@eggly.anvils>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Eric Sandeen <sandeen@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

Hi,

On 04/16/2015 10:10 PM, Hugh Dickins wrote:
> On Thu, 16 Apr 2015, Beata Michalska wrote:
>> On 04/16/2015 05:46 AM, Eric Sandeen wrote:
>>> On 4/15/15 2:15 AM, Beata Michalska wrote:
>>>> Introduce configurable generic interface for file
>>>> system-wide event notifications to provide file
>>>> systems with a common way of reporting any potential
>>>> issues as they emerge.
>>>>
>>>> The notifications are to be issued through generic
>>>> netlink interface, by a dedicated, for file system
>>>> events, multicast group. The file systems might as
>>>> well use this group to send their own custom messages.
>>>
>>> ...
>>>
>>>> + 4.3 Threshold notifications:
>>>> +
>>>> + #include <linux/fs_event.h>
>>>> + void fs_event_alloc_space(struct super_block *sb, u64 ncount);
>>>> + void fs_event_free_space(struct super_block *sb, u64 ncount);
>>>> +
>>>> + Each filesystme supporting the treshold notifiactions should call
>>>> + fs_event_alloc_space/fs_event_free_space repsectively whenever the
>>>> + ammount of availbale blocks changes.
>>>> + - sb:     the filesystem's super block
>>>> + - ncount: number of blocks being acquired/released
>>>
>>> so:
>>>
>>>> +void fs_event_alloc_space(struct super_block *sb, u64 ncount)
>>>> +{
>>>> +	struct fs_trace_entry *en;
>>>> +	s64 count;
>>>> +
>>>> +	spin_lock(&fs_trace_lock);
>>>
>>> Every allocation/free for every supported filesystem system-wide will be
>>> serialized on this global spinlock?  That sounds like a non-starter...
>>>
>>> -Eric
>>>
>> I guess there is a plenty room for improvements as this is an early version.
>> I do agree that this might be a performance bottleneck event though I've tried
>> to keep this to minimum - it's being taken only for hashtable look-up. But still...
>> I was considering placing the trace object within the super_block to skip
>> this look-up part but I'd like to gather more comments, especially on the concept
>> itself.
> 
> Sorry, I have no opinion on the netlink fs notifications concept
> itself, not my area of expertise at all.
> 
> No doubt you Cc'ed me for tmpfs: I am very glad you're now trying the
> generic filesystem route, and yes, I'd be happy to have the support
> in tmpfs, thank you - if it is generally agreed to be suitable for
> filesystems; but wouldn't want this as a special for tmpfs.
> 
> However, I must echo Eric's point: please take a look at 7e496299d4d2
> "tmpfs: make tmpfs scalable with percpu_counter for used blocks":
> Tim would be unhappy if you added overhead back into that path.
> 
> (And please Cc linux-fsdevel@vger.kernel.org next time you post these.)
> 
> Hugh
> 

Well, the concept of using netlink interface here is just a part of the overall
idea - so any comments are really welcomed here. The more of them the better solution
can be worked out, as I believe.

As for the possible overhead: this is the last thing I would want, so I'll
definitely do may best to not to introduce any. I will definitely rework this.

Thanks for Your comments,

BR
Beata


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
