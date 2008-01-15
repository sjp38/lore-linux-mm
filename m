Date: Tue, 15 Jan 2008 10:05:52 -0200
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
Message-ID: <20080115120552.GA25009@dmt>
References: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080115104619.10dab6de@lxorguk.ukuu.org.uk> <20080115195022.11A3.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080115112027.6120915b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080115112027.6120915b@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Alan,

On Tue, Jan 15, 2008 at 11:20:27AM +0000, Alan Cox wrote:
> On Tue, 15 Jan 2008 19:59:02 +0900
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > 
> > > > the core of this patch series.
> > > > add /dev/mem_notify device for notification low memory to user process.
> > > 
> > > As you only wake one process how would you use this API from processes
> > > which want to monitor and can free memory under load. Also what fairness
> > > guarantees are there...
> > 
> > Sorry, I don't make sense what you mean fairness.
> > Could you tell more?
> 
> If you have two processes each waiting on mem_notify is it not possible
> that one of them will keep being the one woken up and the other will
> remain stuck ?

Tasks are added to the end of waitqueue->task_list through
add_wait_queue_exclusive, and waken up from the start of the list. So
I don't think that can happen (its FIFO).

> It also appears there is no way to wait for memory shortages (processes
> that can free memory easily) only for memory to start appearing.

The notification is sent once the VM starts moving anonymous pages to
the inactive list (meaning there is memory shortage). So polling on the
device is all about waiting for memory shortage.

Or do you mean something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
