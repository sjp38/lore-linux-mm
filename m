Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CD7F08D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 21:51:38 -0400 (EDT)
Date: Sun, 31 Oct 2010 09:51:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101031015132.GA10086@localhost>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
 <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
 <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
 <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
 <20101031012224.GA8007@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101031012224.GA8007@localhost>
Sender: owner-linux-mm@kvack.org
To: Aidar Kultayev <the.aidar@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Ted Ts'o <tytso@mit.edu>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

> > How do I notice slowdowns ? The JuK lags so badly that it can't play
> > any music, the mouse pointer freezes, kwin effects freeze for few
> > seconds.

> > How can I make it much worse ? I can try & run disk clean up under XP,
> > that is running in VBox, with folder compression. On top of it if I
> > start copying big files in linux ( 700MB avis, etc ), GUI effects
> > freeze, mouse pointer freezes for few seconds.

It may also help to lower the dirty ratio.

echo 5 > /proc/sys/vm/dirty_ratio

Memory pressure + heavy write can easily hurt responsiveness.

- eats up to 20% (the default value for dirty_ratio) memory with dirty
  pages and hence increase the memory pressure and number of swap IO

- the file copy makes the device write congested and hence makes
  pageout() easily blocked in get_request_wait()

As a result every application may be slowed down by the heavy swap IO
when page fault as well as being blocked when allocating memory (which
may go into direct reclaim and then call pageout()). 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
