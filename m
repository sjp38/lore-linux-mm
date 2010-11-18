Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 477E86B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:40:24 -0500 (EST)
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101118132617.GA9307@localhost>
References: <20101117042720.033773013@intel.com>
	 <20101117042849.410279291@intel.com> <1290085474.2109.1480.camel@laptop>
	 <20101118132617.GA9307@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 18 Nov 2010 14:40:06 +0100
Message-ID: <1290087606.2109.1518.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, tglx <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-11-18 at 21:26 +0800, Wu Fengguang wrote:
> On Thu, Nov 18, 2010 at 09:04:34PM +0800, Peter Zijlstra wrote:
> > On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> > > - avoid useless (eg. zero pause time) balance_dirty_pages() calls
> > > - avoid too small pause time (less than  10ms, which burns CPU power)
> > > - avoid too large pause time (more than 100ms, which hurts responsive=
ness)
> > > - avoid big fluctuations of pause times=20
> >=20
> > If you feel like playing with sub-jiffies timeouts (a way to avoid that
> > HZ=3D>100 assumption), the below (totally untested) patch might be of
> > help..
>=20
> Assuming there are HZ=3D10 users.
>=20
> - when choosing such a coarse granularity, do they really care about
>   responsiveness? :)

No of course not, they usually care about booting their system,.. I've
been told booting Linux on a 10Mhz FPGA is 'fun' :-)

> - will the use of hrtimer add a little code size and/or runtime
>   overheads, and hence hurt the majority HZ=3D100 users?

Yes it will add code and runtime overhead, but it would allow you to
have 1ms timeouts even on a HZ=3D100 system, as opposed to a 10ms minimum.

Anyway, I'm not saying you should do it, I just wondered if we had the
API, saw we didn't and thought it might be nice to offer it if desired.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
