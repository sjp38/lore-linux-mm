Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 1FC0D6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:00:10 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2392665dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 00:00:09 -0700 (PDT)
Date: Thu, 7 Jun 2012 23:58:28 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 2/5] vmevent: Convert from deferred timer to deferred work
Message-ID: <20120608065828.GA1515@lizard>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FD170AA.10705@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, Pekka Enberg <penberg@kernel.org>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Thu, Jun 07, 2012 at 11:25:30PM -0400, KOSAKI Motohiro wrote:
[...]
> As I already told you, vmevent shouldn't deal a timer at all. It is
> NOT familiar to embedded world. Because of, time subsystem is one of
> most complex one on linux. Our 'time' is not simple concept. time.h
> says we have 5 possibilities user want, at least.
> 
> include/linux/time.h
> ------------------------------------------
> #define CLOCK_REALTIME			0
> #define CLOCK_MONOTONIC			1
> #define CLOCK_MONOTONIC_RAW		4
> #define CLOCK_REALTIME_COARSE		5
> #define CLOCK_MONOTONIC_COARSE		6
> 
> And, some people want to change timer slack for optimize power 
> consumption.
> 
> So, Don't reinventing the wheel. Just use posix tiemr apis.

I'm puzzled, why you mention posix timers in the context of the
in-kernel user? And none of the posix timers are deferrable.

The whole point of vmevent is to be lightweight and save power.
Vmevent is doing all the work in the kernel, and it uses
deferrable timers/workqueues to save power, and it is a proper
in-kernel API to do so.

If you're saying that we should set up a timer in the userland and
constantly read /proc/vmstat, then we will cause CPU wake up
every 100ms, which is not acceptable. Well, we can try to introduce
deferrable timers for the userspace. But then it would still add
a lot more overhead for our task, as this solution adds other two
context switches to read and parse /proc/vmstat. I guess this is
not a show-stopper though, so we can discuss this.

Leonid, Pekka, what do you think about the idea?

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
