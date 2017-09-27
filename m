Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D01506B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 19:31:10 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v109so17977953wrc.5
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 16:31:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 39si138819wrx.324.2017.09.27.16.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 16:31:09 -0700 (PDT)
Date: Wed, 27 Sep 2017 16:31:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND] proc, coredump: add CoreDumping flag to
 /proc/pid/status
Message-Id: <20170927163106.84b9622f183f087eff7f6da7@linux-foundation.org>
In-Reply-To: <20170920230634.31572-1-guro@fb.com>
References: <20170914224431.GA9735@castle>
	<20170920230634.31572-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, 20 Sep 2017 16:06:34 -0700 Roman Gushchin <guro@fb.com> wrote:

> Right now there is no convenient way to check if a process is being
> coredumped at the moment.
> 
> It might be necessary to recognize such state to prevent killing
> the process and getting a broken coredump.
> Writing a large core might take significant time, and the process
> is unresponsive during it, so it might be killed by timeout,
> if another process is monitoring and killing/restarting
> hanging tasks.
> 
> To provide an ability to detect if a process is in the state of
> being coreduped, we can expose a boolean CoreDumping flag
> in /proc/pid/status.
> 
> Example:
> $ cat core.sh
>   #!/bin/sh
> 
>   echo "|/usr/bin/sleep 10" > /proc/sys/kernel/core_pattern
>   sleep 1000 &
>   PID=$!
> 
>   cat /proc/$PID/status | grep CoreDumping
>   kill -ABRT $PID
>   sleep 1
>   cat /proc/$PID/status | grep CoreDumping
> 
> $ ./core.sh
>   CoreDumping:	0
>   CoreDumping:	1

I assume you have some real-world use case which benefits from this.

>  fs/proc/array.c | 6 ++++++
>  1 file changed, 6 insertions(+)

A Documentation/ would be appropriate?   Include a brief mention of
*why* someone might want to use this...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
