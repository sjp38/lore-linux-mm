Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Comment on patch to remove nr_async_pages limitA
Date: Wed, 6 Jun 2001 00:21:33 +0200
References: <Pine.LNX.4.33.0106052211490.2310-100000@mikeg.weiden.de>
In-Reply-To: <Pine.LNX.4.33.0106052211490.2310-100000@mikeg.weiden.de>
MIME-Version: 1.0
Message-Id: <01060600213307.00553@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>, "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Zlatko Calusic <zlatko.calusic@iskon.hr>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 05 June 2001 23:00, Mike Galbraith wrote:
> On Tue, 5 Jun 2001, Benjamin C.R. LaHaise wrote:
> > Swapping early causes many more problems than swapping late as
> > extraneous seeks to the swap partiton severely degrade performance.
>
> That is not the case here at the spot in the performance curve I'm
> looking at (transition to throughput).
>
> Does this mean the block layer and/or elevator is having problems? 
> Why would using avaliable disk bandwidth vs letting it lie dormant be
> a generically bad thing?.. this I just can't understand.  The
> elevator deals with seeks, the vm is flat not equipped to do so.. it
> contains such concept.

Clearly, if the spindle a dirty file page belongs to is idle, we have 
goofed.

With process data the situation is a little different because the 
natural home of the data is not the swap device but main memory.  The 
following gets pretty close to the truth: when there is memory 
pressure, if the spindle a dirty process page belongs to is idle, we 
have goofed.

Well, as soon as I wrote those obvious truths I started thinking of 
exceptions, but they are silly exceptions such as:

  - read disk block 0
  - dirty last block of disk
  - dirty 1,000 blocks starting at block 0.

For good measure, delete the file the last block of the disk belongs 
to.  We have just sent the head off on a wild goose chase, but we had 
to work at it.  To handle such a set of events without requiring 
prescience we need to be able to cancel disk writes, but just ignoring 
such oddball situations is the next best thing.

That's all by way of saying I agree with you.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
