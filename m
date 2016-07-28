Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 098656B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 17:02:47 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so69375228pad.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 14:02:47 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 67si14179286pfy.28.2016.07.28.14.02.45
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 14:02:46 -0700 (PDT)
From: Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH 0/3] new feature: monitoring page cache events
References: <cover.1469489884.git.gamvrosi@gmail.com>
Message-ID: <579A72F5.10808@intel.com>
Date: Thu, 28 Jul 2016 14:02:45 -0700
MIME-Version: 1.0
In-Reply-To: <cover.1469489884.git.gamvrosi@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Amvrosiadis <gamvrosi@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 07/25/2016 08:47 PM, George Amvrosiadis wrote:
>  21 files changed, 2424 insertions(+), 1 deletion(-)

I like the idea, but yikes, that's a lot of code.

Have you considered using or augmenting the kernel's existing tracing
mechanisms?  Have you considered using something like netlink for
transporting the data out of the kernel?

The PageDirty() hooks look simple but turn out to be horribly deep.
Where we used to have a plain old bit set, we now have new locks,
potentially long periods of irq disabling, and loops over all the tasks
doing duet, even path lookup!

Given a big system, I would imagine these locks slowing down
SetPageDirty() and things like write() pretty severely.  Have you done
an assessment of the performance impact of this change?   I can't
imagine this being used in any kind of performance or
scalability-sensitive environment.

The current tracing code has a model where the trace producers put data
in *one* place, then all the mulitple consumers pull it out of that
place.  Duet seems to have the model that the producer puts the data in
multiple places and consumers consume it from their own private copies.
 That seems a bit backwards and puts cost directly in to hot code paths.
 Even a single task watching a single file on the system makes everyone
go in and pay some of this cost for every SetPageDirty().

Let's say we had a big system with virtually everything sitting in the
page cache.  Does duet have a way to find things currently _in_ the
cache, or only when things move in/out of it?

Tasks seem to have a fixed 'struct path' ->regpath at duet_task_init()
time.  The code goes page->mapping->inode->i_dentry and then tries to
compare that with the originally recorded path.  Does this even work in
the face of things like bind mounts, mounts that change after
duet_task_init(), or mounting a fs with a different superblock
underneath a watched path?  It seems awfully fragile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
