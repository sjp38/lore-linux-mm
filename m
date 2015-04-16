Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 854996B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 04:42:04 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so84417170pdb.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 01:42:04 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id r11si11099412pdj.220.2015.04.16.01.42.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 01:42:03 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMW00HAZ5OJKM30@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 16 Apr 2015 09:45:55 +0100 (BST)
Message-id: <552F75D6.4030902@samsung.com>
Date: Thu, 16 Apr 2015 10:41:58 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <552F308F.1050505@redhat.com>
In-reply-to: <552F308F.1050505@redhat.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Sandeen <sandeen@redhat.com>
Cc: linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On 04/16/2015 05:46 AM, Eric Sandeen wrote:
> On 4/15/15 2:15 AM, Beata Michalska wrote:
>> Introduce configurable generic interface for file
>> system-wide event notifications to provide file
>> systems with a common way of reporting any potential
>> issues as they emerge.
>>
>> The notifications are to be issued through generic
>> netlink interface, by a dedicated, for file system
>> events, multicast group. The file systems might as
>> well use this group to send their own custom messages.
> 
> ...
> 
>> + 4.3 Threshold notifications:
>> +
>> + #include <linux/fs_event.h>
>> + void fs_event_alloc_space(struct super_block *sb, u64 ncount);
>> + void fs_event_free_space(struct super_block *sb, u64 ncount);
>> +
>> + Each filesystme supporting the treshold notifiactions should call
>> + fs_event_alloc_space/fs_event_free_space repsectively whenever the
>> + ammount of availbale blocks changes.
>> + - sb:     the filesystem's super block
>> + - ncount: number of blocks being acquired/released
> 
> so:
> 
>> +void fs_event_alloc_space(struct super_block *sb, u64 ncount)
>> +{
>> +	struct fs_trace_entry *en;
>> +	s64 count;
>> +
>> +	spin_lock(&fs_trace_lock);
> 
> Every allocation/free for every supported filesystem system-wide will be
> serialized on this global spinlock?  That sounds like a non-starter...
> 
> -Eric
> 
I guess there is a plenty room for improvements as this is an early version.
I do agree that this might be a performance bottleneck event though I've tried
to keep this to minimum - it's being taken only for hashtable look-up. But still...
I was considering placing the trace object within the super_block to skip
this look-up part but I'd like to gather more comments, especially on the concept
itself.

BR
Beata


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
