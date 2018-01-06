Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC506B04F5
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 10:28:56 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id l6so297100lfg.9
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 07:28:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h83sor1404796ljf.39.2018.01.06.07.28.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jan 2018 07:28:54 -0800 (PST)
Message-ID: <1515252530.17396.16.camel@gmail.com>
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Sat, 06 Jan 2018 20:28:50 +0500
In-Reply-To: <201801062352.EFF56799.HFFLOMOJOFSQtV@I-love.SAKURA.ne.jp>
References: <201712110014.vBB0ENwU088603@www262.sakura.ne.jp>
	 <1512963298.23718.15.camel@gmail.com>
	 <201712110348.vBB3mSFZ068689@www262.sakura.ne.jp>
	 <1515248235.17396.4.camel@gmail.com>
	 <201801062352.EFF56799.HFFLOMOJOFSQtV@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Sat, 2018-01-06 at 23:52 +0900, Tetsuo Handa wrote:
> Thank you. But excuse me?
> Something unexpected must be happening in your environment.
> 
> udplogger will flush buffers upon '\n' or timeout (default is 10
> seconds) or
> too long line (default is 65536 bytes).

Very strange because neither '\n' not 10 seconds helps to flush
buffers.
$ echo -e "test\n" > /dev/udp/127.0.0.1/6666
May be I used obsolete source? Could you check this?

> 
> > 
> > Also i fixed two segfault:
> > 
> > 1) When send two messages in one second from different hosts or
> > ports.
> > For reproduce just run
> > "echo test > /dev/udp/127.0.0.1/6666 && echo test >
> > /dev/udp/127.0.0.1/6666"
> > in console.
> 
> I can't observe such problem.
> udplogger is ready to concurrently receive from multiple sources.


Too strange because this condition
https://github.com/kohsuke/udplogger/blob/master/udplogger.c#L82
do not allow open two file in one second.

> > 
> > 2) When exced limit of open files.
> > Just run "echo test > /dev/udp/127.0.0.1/6666" more than 1024
> > times.

How much your "ulimit -n" ?
My is 1024.
$ ulimit -n
1024

May be your ulimit much greater or you launch udplogger under root?

> 
> Are you using special environment? What is the shell? What is the
> compiler/version?
> 

$ gcc --version
gcc (GCC) 7.2.1 20170915 (Red Hat 7.2.1-2)
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is
NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
