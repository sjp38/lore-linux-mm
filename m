From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15096.22053.524498.144383@pizda.ninka.net>
Date: Tue, 8 May 2001 13:25:09 -0700 (PDT)
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles 
In-Reply-To: <Pine.LNX.4.21.0105081419070.7774-100000@freak.distro.conectiva>
References: <Pine.LNX.4.21.0105081225520.31900-100000@alloc>
	<Pine.LNX.4.21.0105081419070.7774-100000@freak.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Mark Hemment <markhe@veritas.com>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti writes:
 > On Tue, 8 May 2001, Mark Hemment wrote:
 > >   Does anyone know why the 2.4.3pre6 change was made?
 > 
 > Because wakeup_bdflush(0) can wakeup bdflush _even_ if it does not have
 > any job to do (ie less than 30% dirty buffers in the default config).  

Actually, the change was made because it is illogical to try only
once on multi-order pages.  Especially because we depend upon order
1 pages so much (every task struct allocated).  We depend upon them
even more so on sparc64 (certain kinds of page tables need to be
allocated as 1 order pages).

The old code failed _far_ too easily, it was unacceptable.

Why put some strange limit in there?  Whatever number you pick
is arbitrary, and I can probably piece together an allocation
state where the choosen limit is too small.

So instead, you could test for the condition that prevents any
possible forward progress, no?

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
