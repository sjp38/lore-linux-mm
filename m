Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4B0E6B025F
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 09:54:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y44so568781wrd.16
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 06:54:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 95si662140lfv.290.2017.09.28.06.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 06:54:28 -0700 (PDT)
Date: Thu, 28 Sep 2017 14:53:57 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RESEND] proc, coredump: add CoreDumping flag to /proc/pid/status
Message-ID: <20170928135357.GA8470@castle.DHCP.thefacebook.com>
References: <20170914224431.GA9735@castle>
 <20170920230634.31572-1-guro@fb.com>
 <20170927163106.84b9622f183f087eff7f6da7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170927163106.84b9622f183f087eff7f6da7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, Sep 27, 2017 at 04:31:06PM -0700, Andrew Morton wrote:
> On Wed, 20 Sep 2017 16:06:34 -0700 Roman Gushchin <guro@fb.com> wrote:
> 
> > Right now there is no convenient way to check if a process is being
> > coredumped at the moment.
> > 
> > It might be necessary to recognize such state to prevent killing
> > the process and getting a broken coredump.
> > Writing a large core might take significant time, and the process
> > is unresponsive during it, so it might be killed by timeout,
> > if another process is monitoring and killing/restarting
> > hanging tasks.
> > 
> > To provide an ability to detect if a process is in the state of
> > being coreduped, we can expose a boolean CoreDumping flag
> > in /proc/pid/status.
> > 
> > Example:
> > $ cat core.sh
> >   #!/bin/sh
> > 
> >   echo "|/usr/bin/sleep 10" > /proc/sys/kernel/core_pattern
> >   sleep 1000 &
> >   PID=$!
> > 
> >   cat /proc/$PID/status | grep CoreDumping
> >   kill -ABRT $PID
> >   sleep 1
> >   cat /proc/$PID/status | grep CoreDumping
> > 
> > $ ./core.sh
> >   CoreDumping:	0
> >   CoreDumping:	1
> 
> I assume you have some real-world use case which benefits from this.

Sure, we're getting a sensible number of corrupted coredump files
on machines in our fleet, just because processes are being killed
by timeout in the middle of the core writing process.

We do have a process health check, and some agent is responsible
for restarting processes which are not responding for health check requests.
Writing a large coredump to the disk can easily exceed the reasonable timeout
(especially on an overloaded machine).

This flag will allow the agent to distinguish processes which are being
coredumped, extend the timeout for them, and let them produce a full
coredump file.

> 
> >  fs/proc/array.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> 
> A Documentation/ would be appropriate?   Include a brief mention of
> *why* someone might want to use this...
> 
>

Here it is. Thank you!

--
