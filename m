Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C61566B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 16:10:33 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so100819814pab.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 13:10:33 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ek10si13523750pdb.228.2015.04.16.13.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 13:10:32 -0700 (PDT)
Received: by pacyx8 with SMTP id yx8so100793660pac.1
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 13:10:32 -0700 (PDT)
Date: Thu, 16 Apr 2015 13:10:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
In-Reply-To: <552F75D6.4030902@samsung.com>
Message-ID: <alpine.LSU.2.11.1504161229450.17935@eggly.anvils>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com> <552F308F.1050505@redhat.com> <552F75D6.4030902@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: Eric Sandeen <sandeen@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Thu, 16 Apr 2015, Beata Michalska wrote:
> On 04/16/2015 05:46 AM, Eric Sandeen wrote:
> > On 4/15/15 2:15 AM, Beata Michalska wrote:
> >> Introduce configurable generic interface for file
> >> system-wide event notifications to provide file
> >> systems with a common way of reporting any potential
> >> issues as they emerge.
> >>
> >> The notifications are to be issued through generic
> >> netlink interface, by a dedicated, for file system
> >> events, multicast group. The file systems might as
> >> well use this group to send their own custom messages.
> > 
> > ...
> > 
> >> + 4.3 Threshold notifications:
> >> +
> >> + #include <linux/fs_event.h>
> >> + void fs_event_alloc_space(struct super_block *sb, u64 ncount);
> >> + void fs_event_free_space(struct super_block *sb, u64 ncount);
> >> +
> >> + Each filesystme supporting the treshold notifiactions should call
> >> + fs_event_alloc_space/fs_event_free_space repsectively whenever the
> >> + ammount of availbale blocks changes.
> >> + - sb:     the filesystem's super block
> >> + - ncount: number of blocks being acquired/released
> > 
> > so:
> > 
> >> +void fs_event_alloc_space(struct super_block *sb, u64 ncount)
> >> +{
> >> +	struct fs_trace_entry *en;
> >> +	s64 count;
> >> +
> >> +	spin_lock(&fs_trace_lock);
> > 
> > Every allocation/free for every supported filesystem system-wide will be
> > serialized on this global spinlock?  That sounds like a non-starter...
> > 
> > -Eric
> > 
> I guess there is a plenty room for improvements as this is an early version.
> I do agree that this might be a performance bottleneck event though I've tried
> to keep this to minimum - it's being taken only for hashtable look-up. But still...
> I was considering placing the trace object within the super_block to skip
> this look-up part but I'd like to gather more comments, especially on the concept
> itself.

Sorry, I have no opinion on the netlink fs notifications concept
itself, not my area of expertise at all.

No doubt you Cc'ed me for tmpfs: I am very glad you're now trying the
generic filesystem route, and yes, I'd be happy to have the support
in tmpfs, thank you - if it is generally agreed to be suitable for
filesystems; but wouldn't want this as a special for tmpfs.

However, I must echo Eric's point: please take a look at 7e496299d4d2
"tmpfs: make tmpfs scalable with percpu_counter for used blocks":
Tim would be unhappy if you added overhead back into that path.

(And please Cc linux-fsdevel@vger.kernel.org next time you post these.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
