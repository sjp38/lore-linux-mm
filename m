Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 744DE6B0390
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 00:43:06 -0400 (EDT)
Date: Mon, 23 Aug 2010 14:42:48 +1000
From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on
 dirty_ratio
Message-ID: <20100823144248.15fbb700@notabene>
In-Reply-To: <201008201550.54164.kernel@kolivas.org>
References: <20100820032506.GA6662@localhost>
	<20100820131249.5FF4.A69D9226@jp.fujitsu.com>
	<201008201550.54164.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Con Kolivas <kernel@kolivas.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 15:50:54 +1000
Con Kolivas <kernel@kolivas.org> wrote:

> On Fri, 20 Aug 2010 02:13:25 pm KOSAKI Motohiro wrote:
> > > The dirty_ratio was silently limited to >= 5%. This is not a user
> > > expected behavior. Let's rip it.
> > >
> > > It's not likely the user space will depend on the old behavior.
> > > So the risk of breaking user space is very low.
> > >
> > > CC: Jan Kara <jack@suse.cz>
> > > CC: Neil Brown <neilb@suse.de>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> >
> > Thank you.
> > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> I have tried to do this in the past, and setting this value to 0 on some 
> machines caused the machine to come to a complete standstill with small 
> writes to disk. It seemed there was some kind of "minimum" amount of data 
> required by the VM before anything would make it to the disk and I never 
> quite found out where that blockade occurred. This was some time ago (3 years 
> ago) so I'm not sure if the problem has since been fixed in the VM since 
> then. I suggest you do some testing with this value set to zero before 
> approving this change.
> 

 If it is appropriate to have a lower limit, that should be imposed where
 the sysctl is defined in kernel/sysctl.c, not imposed after the fact where
 the value is used.

 As we now have dirty_bytes which over-rides dirty_ratio, there is little
 cost in having a lower_limit for dirty_ratio - it could even stay at 5% -
 but it really shouldn't be silent.  Writing a number below the limit to the
 sysctl file should fail.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
