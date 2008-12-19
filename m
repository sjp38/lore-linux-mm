Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD606B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 14:25:59 -0500 (EST)
Date: Fri, 19 Dec 2008 20:27:36 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [RFC]: Support for zero-copy TCP transmit of user space data
Message-ID: <20081219192736.GQ32491@kernel.dk>
References: <4942BAB8.4050007@vlnb.net> <1229110673.3262.94.camel@localhost.localdomain> <49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org> <4947FA1C.2090509@vlnb.net> <494A97DD.7080503@vlnb.net> <494A99EF.6070400@flurg.com> <494BDBC5.7050701@vlnb.net> <20081219190701.GP32491@kernel.dk> <494BF361.1090003@vlnb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <494BF361.1090003@vlnb.net>
Sender: owner-linux-mm@kvack.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Cc: "David M. Lloyd" <dmlloyd@flurg.com>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net, Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 19 2008, Vladislav Bolkhovitin wrote:
> Jens Axboe, on 12/19/2008 10:07 PM wrote:
> >On Fri, Dec 19 2008, Vladislav Bolkhovitin wrote:
> >>David M. Lloyd, on 12/18/2008 09:43 PM wrote:
> >>>On 12/18/2008 12:35 PM, Vladislav Bolkhovitin wrote:
> >>>>An iSCSI target driver iSCSI-SCST was a part of the patchset 
> >>>>(http://lkml.org/lkml/2008/12/10/293). For it a nice optimization to 
> >>>>have TCP zero-copy transmit of user space data was implemented. Patch, 
> >>>>implementing this optimization was also sent in the patchset, see 
> >>>>http://lkml.org/lkml/2008/12/10/296.
> >>>I'm probably ignorant of about 90% of the context here, but isn't this 
> >>>the sort of problem that was supposed to have been solved by vmsplice(2)?
> >>No, vmsplice can't help here. ISCSI-SCST is a kernel space driver. But, 
> >>even if it was a user space driver, vmsplice wouldn't change anything 
> >>much. It doesn't have a possibility for a user to know, when 
> >>transmission of the data finished. So, it is intended to be used as: 
> >>vmsplice() buffer -> munmap() the buffer -> mmap() new buffer -> 
> >>vmsplice() it. But on the mmap() stage kernel has to zero all the newly 
> >>mapped pages and zeroing memory isn't much faster, than copying it. 
> >>Hence, there would be no considerable performance increase.
> >
> >vmsplice() isn't the right choice, but splice() very well could be. You
> >could easily use splice internally as well. The vmsplice() part sort-of
> >applies in the sense that you want to fill pages into a pipe, which is
> >essentially what vmsplice() does. You'd need some helper to do that.
> 
> Sorry, Jens, but splice() works only if there is a file handle on the 
> another side, so user space doesn't see data buffers. But SCST needs to 
> serve a wider usage cases, like reading data with decompression from a 
> virtual tape, where decompression is done in user space. For those only 
> complete zero-copy network send, which I implemented, can give the best 
> performance.

__splice_from_pipe() takes a pipe, a descriptor and an actor. There's
absolutely ZERO reason you could not reuse most of that for this
implementation. The big bonus here is that getting the put correct from
networking would even make splice() better for everyone. Win for Linux,
win for you since it'll make it MUCH easier for you to get this stuff
in. Looking at your original patch and I almost think it's a flame bait
to induce discussion (nothing wrong with that, that approach works quite
well and has been used before). There's no way in HELL that it'd ever be
a merge candidate. And I suspect you know that, at least I hope you do
or you are farther away from going forward with this than you think.

So don't look at splice() the system call, look at the infrastructure
and check if that could be useful for your case. To me it looks
absolutely like it could, if you goal is just zero-copy transmit. The
only missing piece is dropping the reference and signalling page
consumption at the right point, which is when the data is safe to be
reused. That very bit is missing, but that should be all as far as I can
tell.

> >And
> >the ack-on-xmit-done bits is something that splice-to-socket needs
> >anyway, so I think it'd be quite a suitable choice for this.
> 
> So, are you writing that splice() could also benefit from the zero-copy 
> transmit feature, like I implemented?

I like how you want to reinvent everything, perhaps you should spend a
little more time looking into various other approaches? splice() already
does zero-copy network transmit, there are no copies going on. Ideally,
you'd have zero copies moving data into your pipe, but migrade/move
isn't quite there yet. But that doesn't apply to your case at all.

What is missing, as I wrote, is the 'release on ack' and not on pipe
buffer release. This is similar to the get_page/put_page stuff you did
in your patch, but don't go claiming that zero-copy transmit is a
Vladislav original - the ->sendpage() does no copies.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
