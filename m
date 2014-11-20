Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 773166B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:23:27 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id pv20so1908726lab.37
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 23:23:26 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id o10si1421464laj.15.2014.11.19.23.23.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Nov 2014 23:23:25 -0800 (PST)
Message-ID: <546D8882.4040908@parallels.com>
Date: Thu, 20 Nov 2014 10:21:54 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] RFC: userfault (question about remap_anon_pages
 API)
In-Reply-To: 20140703140853.GG21667 () redhat ! com
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

Andrea,

We'd like to use this code to implement the post-copy migration
too, but this time for containers, not for virtual machines. This
will be done as a part of the CRIU [1] project.

>From our experiments almost everything is suitable, but the
remap_anon_pages() system call, so I'd like you to comment on
whether we're mis-using your API or not :) So, for containers the
post-copy migration would look like this.


On the source node we freeze the container's process tree, read
its state, except for the memory contents using CRIU tool, then
copy the state on remote host and recreate the processes back
using the CRIU tool again.

At this step (restore) we mark all the memory of the tasks we
restore with MADV_USERFAULT so that any attempt to access one 
results in the notification via userfaultfd. The userfaultfd, in
turn, exists for every process in the container and, in our plans, 
is owned by the CRIU daemon, that will provide the post-copy 
memory updates. Then we unfreeze the processes and let them run
further.

So, when a process tries to access the memory the CRIU daemon
wakes up, reads the fault address, pulls the page from source node
and then it should put this page into the proper process' address
space. And here's where we have problems.

The page with data is in CRIU daemon address space and the syscall
remap_anon_pages() works on current process address space. So, in
order to have the data in the container's process address space, we
have two choices. Either we somehow make the page be available in 
the other process address space and make this process call the remap
system call, or we should extend the syscall to accept the pid of 
the process on whose address space we'd like to work on.


What do you think? Are you OK with tuning the remap_anon_pages, or
we should do things in completely different way? If the above
explanation is not clear enough, we'd be happy to provide more 
details.

Thanks,
Pavel

[1] http://criu.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
