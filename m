Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD876B0069
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 11:24:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g6so6334760pgn.11
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 08:24:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u66sor1052854pfa.51.2017.11.02.08.24.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 08:24:52 -0700 (PDT)
Message-ID: <1509636290.20221.3.camel@gmail.com>
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes
 process to death row (new syscall)
From: Shawn Paul Landden <slandden@gmail.com>
Date: Thu, 02 Nov 2017 08:24:50 -0700
In-Reply-To: <1509565071.2650718.1158454064.7E910622@webmail.messagingengine.com>
References: <20171101053244.5218-1-slandden@gmail.com>
	 <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
	 <CA+49okox_Hvg-dGyjZc3u0qLz1S=LJjS4-WT6SxQ9qfPyp6BjQ@mail.gmail.com>
	 <1509565071.2650718.1158454064.7E910622@webmail.messagingengine.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Walters <walters@verbum.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2017-11-01 at 15:37 -0400, Colin Walters wrote:
> threading is limited doing sync()/fsync() and gethostbyname() async.
> 
> But languages with a GC tend to at least use a background thread for
> that,
> and of course lots of modern userspace makes heavy use of
> multithreading
> (or variants like goroutines).
> 
> A common pattern though is to have a "main thread" that acts as a
> control
> point and runs the mainloop (particularly for anything with a GUI).  
> That's
> going to be the thing calling prctl(SET_IDLE) - but I think its idle
> state should implicitly
> affect the whole process, since for a lot of apps those other threads
> are going to
> just be "background".
> 
> It'd probably then be an error to use prctl(SET_IDLE) in more than
> one thread
> ever?  (Although that might break in golang due to the way goroutines
> can
> be migrated across threads)
> 
> That'd probably be a good "generality test" - what would it take to
> have
> this system call be used for a simple golang webserver app that's
> e.g.
> socket activated by systemd, or a Kubernetes service?  Or another
> really interesting case would be qemu; make it easy to flag VMs as
> always
> having this state (most of my testing VMs are like this; it's OK if
> they get
> destroyed, I just reinitialize them from the gold state).
> 
> Going back to threading - a tricky thing we should handle in general
> is when userspace libraries create threads that are unknown to the
> app;
> the "async gethostbyname()" is a good example.  To be conservative
> we'd
> likely need to "fail non-idle", but figure out some way tell the
> kernel
> for e.g. GC threads that they're still 
I realize none of this is a problem because when prctl(PR_SET_IDLE,
PR_IDLE_MODE_KILLME) is set the *entire* process has declared itsself
stateless and ready to be killed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
