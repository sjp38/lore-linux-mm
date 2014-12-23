Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 665C46B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 09:52:30 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so7951583pdi.17
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 06:52:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id py12si8865621pab.43.2014.12.23.06.52.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 06:52:28 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141223122401.GC28549@dhcp22.suse.cz>
	<201412232200.BCI48944.LJFSFVOFHMOtQO@I-love.SAKURA.ne.jp>
	<20141223130909.GE28549@dhcp22.suse.cz>
	<201412232220.IIJ57305.OMOOSVFtFFHQLJ@I-love.SAKURA.ne.jp>
	<20141223134309.GF28549@dhcp22.suse.cz>
In-Reply-To: <20141223134309.GF28549@dhcp22.suse.cz>
Message-Id: <201412232311.IJH26045.LMSHFVOFJQFtOO@I-love.SAKURA.ne.jp>
Date: Tue, 23 Dec 2014 23:11:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> On Tue 23-12-14 22:20:57, Tetsuo Handa wrote:
> > I'm talking about possible delay between TIF_MEMDIE was set on the victim
> > and SIGKILL is delivered to the victim.
> 
> I can read what you wrote. You are just ignoring my questions it seems
> because I haven't got any reason _why it matters_. My point was that the
> victim might be looping in the kernel and doing other allocations until
> it notices it has fatal_signal_pending and bail out. So the delay
> between setting the flag and sending the signal is not that important
> AFAICS.

My point is that the victim might not be looping in the kernel
when getting TIF_MEMDIE.

Situation:

  P1: A process who called the OOM killer
  P2: A process who is chosen by the OOM killer

  P2 is running a program shown below.
----------
int main(int argc, char *argv[])
{
	const int fd = open("/dev/zero", O_RDONLY);
	char *buf = malloc(1024 * 1048576);
	if (fd == -1 || !buf)
		return 1;
	memset(buf, 0, 512 * 1048576);
	sleep(10);
	read(fd, buf, 1024 * 1048576);
	return 0;
}
----------

Sequence:

  (1) P2 is sleeping at sleep(10).
  (2) P1 triggers the OOM killer and P2 is chosen.
  (3) The OOM killer sets TIF_MEMDIE on P2.
  (4) P2 wakes up as sleep(10) expired.
  (5) P2 calls read().
  (6) P2 triggers page fault inside read().
  (7) P2 allocates from memory reserves for handling page fault.
  (8) The OOM killer sends SIGKILL to P2.
  (9) P2 receives SIGKILL after all memory reserves were
      allocated for handling page fault.
  (10) P2 starts steps for die, but memory reserves may be
       already empty.

My worry:

  More the delay between (3) and (8) becomes longer (e.g. 30 seconds
  for an overdone case), more likely to cause memory reserves being
  consumed before (9). If (3) and (8) are reversed, P2 will notice
  fatal_signal_pending() and bail out before allocating a lot of
  memory from memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
