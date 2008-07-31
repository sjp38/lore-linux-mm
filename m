Date: Thu, 31 Jul 2008 14:26:12 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch v3] splice: fix race with page invalidation
Message-ID: <20080731102612.GA29766@2ka.mipt.ru>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org> <20080731061201.GA7156@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080731061201.GA7156@shareable.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 31, 2008 at 07:12:01AM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> The obvious mechanism for completion notifications is the AIO event
> interface.  I.e. aio_sendfile that reports completion when it's safe
> to modify data it was using.  aio_splice would be logical for similar
> reasons.  Note it doesn't mean when the data has reached a particular
> place, it means when the pages it's holding are released.  Pity AIO
> still sucks ;-)

It is not that simple: page can be held in hardware or tcp queues for
a long time, and the only possible way to know, that system finished
with it, is receiving ack from the remote side. There is a project to
implement such a callback at skb destruction time (it is freed after ack
from the other peer), but do we really need it? System which does care
about transmit will implement own ack mechanism, so page can be unlocked
at higher layer. Actually page can be locked during transfer and
unlocked after rpc reply received, so underlying page invalidation will
be postponed and will not affect sendfile/splice.

> Btw, Windows had this since forever, it's called overlapped
> TransmitFile with an I/O completion event.  Don't know if it's any
> good though ;-)

There was a linux aio_sendfile() too. Google still knows about its
numbers, graphs and so on... :)

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
