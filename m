Date: Tue, 8 May 2001 21:21:16 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles
Message-ID: <20010508212116.N505@suse.de>
References: <Pine.LNX.4.21.0105081225520.31900-100000@alloc> <Pine.LNX.4.21.0105081419070.7774-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105081419070.7774-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Tue, May 08, 2001 at 02:23:56PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Mark Hemment <markhe@veritas.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 08 2001, Marcelo Tosatti wrote:
> >   The attached patch (against 2.4.5-pre1) fixes the looping symptom, by
> > adding a counter and looping only twice for non-zero order allocations.
> 
> Looks good. (actually Rik had a patch similar to this which fixed a real
> case with cdda2wav just like you described)

Not cdda2wav, I pressume, but the optimization discussed here before that
wasn't really doable because of the vm behaviour when doing

	do 
		try to alloc some amount of contiogous pages
		if (ok)
			break

		lower number of pages wanted
	while true

CDROMREADAUDIO stopped doing this and fell back to single cdda frame
size allocations because of these failures, even though it meant a huge
decrease in speed. cdda2wav will ask for iirc 16 frames at the time, the
current driver will try and to 8 first and then fall back to slower
extraction if allocations fail.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
