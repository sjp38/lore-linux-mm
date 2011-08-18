Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B45466B0171
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:13:49 -0400 (EDT)
Date: Thu, 18 Aug 2011 21:13:43 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: Per-block device
 bdi->dirty_writeback_interval and bdi->dirty_expire_interval.
Message-ID: <20110818131343.GA17473@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
 <20110818094824.GA25752@localhost>
 <1313669702.6607.24.camel@sauron>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313669702.6607.24.camel@sauron>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Kautuk Consul <consul.kautuk@gmail.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

Hi Artem,

> Here is a real use-case we had when developing the N900 phone. We had
> internal flash and external microSD slot. Internal flash is soldered in
> and cannot be removed by the user. MicroSD, in contrast, can be removed
> by the user.
> 
> For the internal flash we wanted long intervals and relaxed limits to
> gain better performance.
> 
> For MicroSD we wanted very short intervals and tough limits to make sure
> that if the user suddenly removes his microSD (users do this all the
> time) - we do not lose data.

Thinking twice about it, I find that the different requirements for
interval flash/external microSD can also be solved by this scheme.

Introduce a per-bdi dirty_background_time (and optionally dirty_time)
as the counterpart of (and works in parallel to) global dirty[_background]_ratio,
however with unit "milliseconds worth of data".

The per-bdi dirty_background_time will be set low for external microSD
and high for internal flash. Then you get timely writeouts for microSD
and reasonably delayed writes for internal flash (controllable by the
global dirty_expire_centisecs).

The dirty_background_time will actually work more reliable than
dirty_expire_centisecs because it will checked immediately after the
application dirties more pages. And the dirty_time could provide
strong data integrity guarantee -- much stronger than
dirty_expire_centisecs -- if used.

Does that sound reasonable?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
