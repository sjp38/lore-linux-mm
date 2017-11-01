Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 17DA66B0285
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:16:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 5so1229230wmk.13
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:16:40 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id e6si759004wrd.79.2017.11.01.08.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 08:16:38 -0700 (PDT)
Message-Id: <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
From: Colin Walters <walters@verbum.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes process
 to death row (new syscall)
References: <20171101053244.5218-1-slandden@gmail.com>
Date: Wed, 01 Nov 2017 11:16:37 -0400
In-Reply-To: <20171101053244.5218-1-slandden@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org



On Wed, Nov 1, 2017, at 01:32 AM, Shawn Landden wrote:
> It is common for services to be stateless around their main event loop.
> If a process passes the EPOLL_KILLME flag to epoll_wait5() then it
> signals to the kernel that epoll_wait5() may not complete, and the kernel
> may send SIGKILL if resources get tight.
> 

I've thought about something like this in the past too and would love
to see it land.  Bigger picture, this also comes up in (server) container
environments, see e.g.:

https://docs.openshift.com/container-platform/3.3/admin_guide/idling_applications.html

There's going to be a long slog getting apps to actually make use
of this, but I suspect if it gets wrapped up nicely in some "framework"
libraries for C/C++, and be bound in the language ecosystems like golang
we could see a fair amount of adoption on the order of a year or two.

However, while I understand why it feels natural to tie this to epoll,
as the maintainer of glib2 which is used by a *lot* of things; I'm not
sure we're going to port to epoll anytime soon.

Why not just make this a prctl()?  It's not like it's really any less racy to do:

prctl(PR_SET_IDLE)
epoll()

and this also allows:

prctl(PR_SET_IDLE)
poll()

And as this is most often just going to be an optional hint it's easier to e.g. just ignore EINVAL
from the prctl().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
