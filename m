Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 690536B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 23:46:59 -0400 (EDT)
Received: by qkx62 with SMTP id 62so119336670qkx.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 20:46:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b130si7029765qka.51.2015.04.15.20.46.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 20:46:58 -0700 (PDT)
Message-ID: <552F308F.1050505@redhat.com>
Date: Wed, 15 Apr 2015 22:46:23 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
In-Reply-To: <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org
Cc: tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On 4/15/15 2:15 AM, Beata Michalska wrote:
> Introduce configurable generic interface for file
> system-wide event notifications to provide file
> systems with a common way of reporting any potential
> issues as they emerge.
> 
> The notifications are to be issued through generic
> netlink interface, by a dedicated, for file system
> events, multicast group. The file systems might as
> well use this group to send their own custom messages.

...

> + 4.3 Threshold notifications:
> +
> + #include <linux/fs_event.h>
> + void fs_event_alloc_space(struct super_block *sb, u64 ncount);
> + void fs_event_free_space(struct super_block *sb, u64 ncount);
> +
> + Each filesystme supporting the treshold notifiactions should call
> + fs_event_alloc_space/fs_event_free_space repsectively whenever the
> + ammount of availbale blocks changes.
> + - sb:     the filesystem's super block
> + - ncount: number of blocks being acquired/released

so:

> +void fs_event_alloc_space(struct super_block *sb, u64 ncount)
> +{
> +	struct fs_trace_entry *en;
> +	s64 count;
> +
> +	spin_lock(&fs_trace_lock);

Every allocation/free for every supported filesystem system-wide will be
serialized on this global spinlock?  That sounds like a non-starter...

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
