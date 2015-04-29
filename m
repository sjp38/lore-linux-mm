Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2A26B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:48:22 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so31402083pac.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:48:22 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id y10si36761539pdn.1.2015.04.29.08.48.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 08:48:21 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNK007BLRWGDN90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 29 Apr 2015 16:48:16 +0100 (BST)
Message-id: <5540FD3E.9050801@samsung.com>
Date: Wed, 29 Apr 2015 17:48:14 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v2 1/4] fs: Add generic file system event notifications
References: <553E50EB.3000402@samsung.com> <20150427153711.GA23428@kroah.com>
 <20150428135653.GD9955@quack.suse.cz> <20150428140936.GA13406@kroah.com>
 <553F9D56.6030301@samsung.com> <20150428173900.GA16708@kroah.com>
 <5540822C.10000@samsung.com> <20150429074259.GA31089@quack.suse.cz>
 <20150429091303.GA4090@kroah.com> <5540BC2A.8010504@samsung.com>
 <20150429134505.GB15398@kroah.com>
In-reply-to: <20150429134505.GB15398@kroah.com>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On 04/29/2015 03:45 PM, Greg KH wrote:
> On Wed, Apr 29, 2015 at 01:10:34PM +0200, Beata Michalska wrote:
>>>>> It needs to be done internally by the app but is doable.
>>>>> The app knows what it is watching, so it can maintain the mappings.
>>>>> So prior to activating the notifications it can call 'stat' on the mount point.
>>>>> Stat struct gives the 'st_dev' which is the device id. Same will be reported
>>>>> within the message payload (through major:minor numbers). So having this,
>>>>> the app is able to get any other information it needs. 
>>>>> Note that the events refer to the file system as a whole and they may not
>>>>> necessarily have anything to do with the actual block device. 
>>>
>>> How are you going to show an event for a filesystem that is made up of
>>> multiple block devices?
>>
>> AFAIK, for such filesystems there will be similar case with the anonymous
>> major:minor numbers - at least the btrfs is doing so. Not sure we can
>> differentiate here the actual block device. So in this case such events
>> serves merely as a hint for the userspace.
> 
> "hint" seems like this isn't really going to work well.
> 
> Do you have userspace code that can properly map this back to the "real"
> device that is causing problems?  Without that, this doesn't seem all
> that useful as no one would be able to use those events.

I'm not sure we are on the same page here.
This is about watching the file system rather than the 'real' device.
Like the threshold notifications: you would like to know when you
will be approaching certain level of available space for the tmpfs
mounted on /tmp.  You do know you are watching the /tmp
and you know that the dev numbers for this are 0:20 (or so). 
(either through calling stat on /tmp or through reading the /proc/$$/mountinfo)
With this interface you can setup threshold levels
for /tmp. Then, once the limit is reached the event will be
sent with those anonymous major:minor numbers.

I can provide a sample code which will demonstrate how this
can be achieved.

> 
>> At this point a user might decide to run some scanning tools.
> 
> You can't run a scanning tool on a tmpfs :)

I was referring to btrfs here as a filesystem with multiple devices
and its btrfs device scan :)
> 
> So what can a user do with information about one of these "virtual"
> filesystems that it can't directly see or access?
> 
>> We might extend the scope of the
>> info being sent, though I would consider this as a nice-to-have but not
>> required for this initial version of notifications. The filesystems
>> might also want to decide to send their own custom messages so it is
>> possible for filesystems like btrfs to send more detailed information
>> using the new genetlink multicast group.
>>>>   Or you can use /proc/self/mountinfo for the mapping. There you can see
>>>> device numbers, real device names if applicable and mountpoints. This has
>>>> the advantage that it works even if filesystem mountpoints change.
>>>
>>> Ok, then that brings up my next question, how does this handle
>>> namespaces?  What namespace is the event being sent in?  block devices
>>> aren't namespaced, but the mount points are, is that going to cause
>>> problems?
>>>
>>
>> The path should get resolved properly (as from root level). though I must
>> admit I'm not sure if there will be no issues when it comes to the network
>> namespaces. I'll double check it. Any hints though are more than welcomed :)
> 
> What is "root level" here?  You can mount things in different namespaces
> all over the place.

I was referring here to the mounts visibility and the mount propagation
which on some distros is set by default with the make-shared option,
so the mounts created in new namespace are visible outside of it (running
cat /proc/$$/moutinfo showed the new mounts). Which got me really
confused, obviously.

> 
> This is going to get really complex very quickly :(

It will/is indeed - still I believe it's worth giving it a try.
I'll try to work out the namespace issue here and get back to you.

BR
Beata
> 
> I still think you should tie this to an existing sysfs device, which
> handles the namespace issues for you, and it also handles the fact that
> userspace can properly identify the device, if at all possible.
> 

> thanks,
> 
> greg k-h
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
