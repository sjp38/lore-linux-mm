Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id D52FF6B00F7
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:00:08 -0400 (EDT)
From: Arnd Bergmann <arnd.bergmann@linaro.org>
Subject: Re: [PATCH v2 01/16] FS: Added demand paging markers to filesystem
Date: Wed, 9 May 2012 13:59:40 +0000
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com> <CANfBPZ_2JeWUu7ti97CVc=ODeEi65ke9EKV6Uje0JHcCM8gYqQ@mail.gmail.com> <20120509003348.GM5091@dastard>
In-Reply-To: <20120509003348.GM5091@dastard>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201205091359.40554.arnd.bergmann@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "S, Venkatraman" <svenkatr@ti.com>, linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Wednesday 09 May 2012, Dave Chinner wrote:
> > In low end flash devices, some requests might take too long than normal
> > due to background device maintenance (i.e flash erase / reclaim procedure)
> > kicking in in the context of an ongoing write, stalling them by several
> > orders of magnitude.
> 
> And thereby stalling what might be writes critical to operation.
> Indeed, how does this affect the system when it starts swapping
> heavily? If you keep stalling writes, the system won't be able to
> swap and free memory...

The point here is that reads have a consistent latency, e.g. 500
microseconds for a small access, while writes have a latency
that can easily become 1000x the read latency (e.g. 500 ms of
blocking the device) depending on the state of the device. Most
of the time, writes are fast as well, but sometimes (when garbage
collection happens in the device), they are extremely slow and
block everything else.
This is the only time we ever want to interrupt a write: keeping
the system running interactively while eventually getting to do
the writeback. There is a small penalty for interrupting the garbage
collection, but the device should be able to pick up its work
at the point where we interrupt it, so we can still make forward
progress.

> > > This really seems like functionality that belongs in an IO
> > > scheduler so that write starvation can be avoided, not in high-level
> > > data read paths where we have no clue about anything else going on
> > > in the IO subsystem....
> > 
> > Indeed, the feature is built mostly in the low level device driver and
> > minor changes in the elevator. Changes above the block layer are only
> > about setting
> > attributes and transparent to their operation.
> 
> The problem is that the attribute you are setting covers every
> single data read that is done by all users. If that's what you want
> to have happen, then why do you even need a new flag at this layer?
> Just treat every non-REQ_META read request as a demand paged IO and
> you've got exactly the same behaviour without needing to tag at the
> higher layer....

My feeling is that we should just treat every (REQ_SYNC | REQ_READ)
request the same and let them interrupt long-running writes,
independent of whether it's REQ_META or demand paging.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
