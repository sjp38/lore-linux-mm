Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5683B6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 16:56:04 -0500 (EST)
Date: Sat, 20 Dec 2008 00:58:17 +0300
From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [RFC]: Support for zero-copy TCP transmit of user space data
Message-ID: <20081219215817.GA704@ioremap.net>
References: <1229110673.3262.94.camel@localhost.localdomain> <49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org> <4947FA1C.2090509@vlnb.net> <494A97DD.7080503@vlnb.net> <494A99EF.6070400@flurg.com> <494BDBC5.7050701@vlnb.net> <20081219190701.GP32491@kernel.dk> <494BF361.1090003@vlnb.net> <20081219192736.GQ32491@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081219192736.GQ32491@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Vladislav Bolkhovitin <vst@vlnb.net>, "David M. Lloyd" <dmlloyd@flurg.com>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net, Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 19, 2008 at 08:27:36PM +0100, Jens Axboe (jens.axboe@oracle.com) wrote:
> What is missing, as I wrote, is the 'release on ack' and not on pipe
> buffer release. This is similar to the get_page/put_page stuff you did
> in your patch, but don't go claiming that zero-copy transmit is a
> Vladislav original - the ->sendpage() does no copies.

Just my small rant: it does, when underlying device does not support
hardware tx checksumming and scatter/gather, which is likely exception
than a rule for the modern NICs.

As of having notifications of the received ack (or from user's point of
view notification of the freeing of the buffer), I have following idea
in mind: extend skb ahsred info by copy of the frag array and additional
destructor field, which will be invoked when not only skb but also all
its clones are freed (that's when shared info is freed), so that user
could save some per-page context in fraglist and work with it when data
is not used anymore.

Extending page or skb structure is a no-go for sure, and actually even
shared info is not rubber, but there we can at least add something...

If only destructor field is allowed (similar patch was not rejected),
scsi can save its pages in the tree (indexed by the page pointer) and
traverse it when destructor is invoked selecting pages found in the
freed skb.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
