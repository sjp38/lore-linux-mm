Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD0B6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:45:11 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so28811097pdb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 06:45:11 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id e12si39514087pat.195.2015.04.29.06.45.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 06:45:10 -0700 (PDT)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 85F5F209FF
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:45:07 -0400 (EDT)
Date: Wed, 29 Apr 2015 15:45:05 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [RFC v2 1/4] fs: Add generic file system event notifications
Message-ID: <20150429134505.GB15398@kroah.com>
References: <553E50EB.3000402@samsung.com>
 <20150427153711.GA23428@kroah.com>
 <20150428135653.GD9955@quack.suse.cz>
 <20150428140936.GA13406@kroah.com>
 <553F9D56.6030301@samsung.com>
 <20150428173900.GA16708@kroah.com>
 <5540822C.10000@samsung.com>
 <20150429074259.GA31089@quack.suse.cz>
 <20150429091303.GA4090@kroah.com>
 <5540BC2A.8010504@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5540BC2A.8010504@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Wed, Apr 29, 2015 at 01:10:34PM +0200, Beata Michalska wrote:
> >>> It needs to be done internally by the app but is doable.
> >>> The app knows what it is watching, so it can maintain the mappings.
> >>> So prior to activating the notifications it can call 'stat' on the mount point.
> >>> Stat struct gives the 'st_dev' which is the device id. Same will be reported
> >>> within the message payload (through major:minor numbers). So having this,
> >>> the app is able to get any other information it needs. 
> >>> Note that the events refer to the file system as a whole and they may not
> >>> necessarily have anything to do with the actual block device. 
> > 
> > How are you going to show an event for a filesystem that is made up of
> > multiple block devices?
> 
> AFAIK, for such filesystems there will be similar case with the anonymous
> major:minor numbers - at least the btrfs is doing so. Not sure we can
> differentiate here the actual block device. So in this case such events
> serves merely as a hint for the userspace.

"hint" seems like this isn't really going to work well.

Do you have userspace code that can properly map this back to the "real"
device that is causing problems?  Without that, this doesn't seem all
that useful as no one would be able to use those events.

> At this point a user might decide to run some scanning tools.

You can't run a scanning tool on a tmpfs :)

So what can a user do with information about one of these "virtual"
filesystems that it can't directly see or access?

> We might extend the scope of the
> info being sent, though I would consider this as a nice-to-have but not
> required for this initial version of notifications. The filesystems
> might also want to decide to send their own custom messages so it is
> possible for filesystems like btrfs to send more detailed information
> using the new genetlink multicast group.
> >>   Or you can use /proc/self/mountinfo for the mapping. There you can see
> >> device numbers, real device names if applicable and mountpoints. This has
> >> the advantage that it works even if filesystem mountpoints change.
> > 
> > Ok, then that brings up my next question, how does this handle
> > namespaces?  What namespace is the event being sent in?  block devices
> > aren't namespaced, but the mount points are, is that going to cause
> > problems?
> > 
> 
> The path should get resolved properly (as from root level). though I must
> admit I'm not sure if there will be no issues when it comes to the network
> namespaces. I'll double check it. Any hints though are more than welcomed :)

What is "root level" here?  You can mount things in different namespaces
all over the place.

This is going to get really complex very quickly :(

I still think you should tie this to an existing sysfs device, which
handles the namespace issues for you, and it also handles the fact that
userspace can properly identify the device, if at all possible.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
