Received: from localhost (riel@localhost)
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id PAA23712
	for <linux-mm@kvack.org>; Thu, 8 Jun 2000 15:35:10 -0300
From: linux@horizon.com
Date: 8 Jun 2000 17:56:32 -0000
Message-ID: <20000608175632.19821.qmail@science.horizon.com>
Subject: Heard about the 2Q algorithm?
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.21.0006081535070.22665@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

That's a page-aging algorithm that claims better than LRU performance.

There are two tunable knobs.

You divide memory into two sections: a FIFO section and an LRU section.
Pages first loaded go into the FIFO section.  The size of this section is
one of the knobs.

Somewhere in the middle of the LRU section (exactly where is the second knob),
we start looking for additional accesses to the page.  If we get any, it
goes into the LRU section.  If not, it eventually gets pushed out of the
FIFO section.

A third knob that's available is to extend the FIFO queue "beyond memory"
into backing store.  Pages that have been pushed out but get referenced
can go straight into the LRU pool rather than taking another pass through
the FIFO.


The idea is that the FIFO absorbs sequential scans and filters out the
initial burst of accesses.  Only if access to the page is *prolonged*
do we consider it for longer-term cacheing.


I haven't implemented it, but the idea is fairly straightforward and makes
sense, and has a reasonable but not excessive number of tuning knobs to
play with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
