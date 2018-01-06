Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B3D48280297
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 09:17:20 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id m195so1510692lfg.2
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 06:17:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n24sor1213229lfi.51.2018.01.06.06.17.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jan 2018 06:17:18 -0800 (PST)
Message-ID: <1515248235.17396.4.camel@gmail.com>
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Sat, 06 Jan 2018 19:17:15 +0500
In-Reply-To: <201712110348.vBB3mSFZ068689@www262.sakura.ne.jp>
References: <201712110014.vBB0ENwU088603@www262.sakura.ne.jp>
	 <1512963298.23718.15.camel@gmail.com>
	 <201712110348.vBB3mSFZ068689@www262.sakura.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Mon, 2017-12-11 at 12:48 +0900, Tetsuo Handa wrote:
> mikhail wrote:
> > > > netconsole works only within local network? destination ip may
> > > > be from
> > > > another network?
> > > 
> > > netconsole can work with another network.
> > > 
> > > (step 1) Verify that UDP packets are reachable. You can test with
> > > 
> > >          # echo test > /dev/udp/213.136.82.171/6666
> > > 
> > >          if you are using bash.
> > 
> > After this on remote machine was created folder with name of router
> > external ip address.
> > Inside this folder was places one file with name of current day.
> > This
> > file has size 0 of bytes and not contain "test" message inside.
> > That is how it should be?
> 
> The message should be written to the log file. If not written, UDP
> packets
> are dropped somewhere. You need to solve this problem first.

I found root cause this problem. Here culprit udplogger, because it not
flush buffers when terminated by ctrl-c.

Here my pull request with fix this problem:
https://github.com/kohsuke/udplogger/pull/1/

Also i fixed two segfault:

1) When send two messages in one second from different hosts or ports.
For reproduce just run
"echo test > /dev/udp/127.0.0.1/6666 && echo test >
/dev/udp/127.0.0.1/6666"
in console.

2) When exced limit of open files.
Just run "echo test > /dev/udp/127.0.0.1/6666" more than 1024 times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
