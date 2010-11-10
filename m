Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 59D386B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:34:52 -0500 (EST)
Date: Wed, 10 Nov 2010 12:32:55 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101110013255.GR2715@dastard>
References: <20101105014334.GF13830@dastard>
 <E1PELiI-0001Pj-8g@approx.mit.edu>
 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com>
 <4CD696B4.6070002@kernel.dk>
 <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikNPEcwWjEQuC-_=9yH5DCCiwUAY265ggeygcSQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jens Axboe <axboe@kernel.dk>, dave b <db.pub.mail@gmail.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 07, 2010 at 07:50:13AM -0800, Linus Torvalds wrote:
> On Sun, Nov 7, 2010 at 4:08 AM, Jens Axboe <axboe@kernel.dk> wrote:
> >
> > As already mentioned, ext3 is just not a good choice for this sort of
> > thing. Did you have atimes enabled?
> 
> At least for ext3, more important than atimes is the "data=writeback"
> setting. Especially since our atime default is sane these days (ie if
> you don't specify anything, we end up using 'relatime').
> 
> If you compile your own kernel, answer "N" to the question
> 
>   Default to 'data=ordered' in ext3?
> 
> at config time (CONFIG_EXT3_DEFAULTS_TO_ORDERED), or you can make sure
> "data=writeback" is in the fstab (but I don't think everything honors
> it for the root filesystem).

Don't forget to mention data=writeback is not the default because if
your system crashes or you lose power running in this mode it will
*CORRUPT YOUR FILESYSTEM* and you *WILL LOSE DATA*. Not to mention
the significant security issues (e.g stale data exposure) that also
occur even if the filesystem is not corrupted by the crash. IOWs,
data=writeback is the "fast but I'll eat your data" option for ext3.

So I recommend that nobody follows this path because it only leads
to worse trouble down the road.  Your best bet it to migrate away
from ext3 to a filesystem that doesn't have such inherent ordering
problems like ext4 or XFS....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
