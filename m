From: stoffel@lucent.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15671.5657.312779.438143@gargle.gargle.HOWL>
Date: Thu, 18 Jul 2002 15:25:13 -0400
Subject: Re: [PATCH] strict VM overcommit for stock 2.4
In-Reply-To: <Pine.LNX.4.30.0207181942240.30902-100000@divine.city.tvnet.hu>
References: <1027016939.1086.127.camel@sinai>
	<Pine.LNX.4.30.0207181942240.30902-100000@divine.city.tvnet.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szakacsits Szabolcs <szaka@sienet.hu>
Cc: Robert Love <rml@tech9.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Szakacsits> About 99% of the people don't know about, don't understand
Szakacsits> or don't care about resource limits. But they do care
Szakacsits> about cleaning up when mess comes. Adding reserved root
Szakacsits> memory would be a couple of lines

So what does this buy you when root itself runs the box into the
ground?  Or if a dumb user decides to run his process as root, and it
takes down the system?

You're arguing for the wrong thing here.  What Robert is doing is
making sure that when a process asks for memory, it can only succeed
when there is physical memory available.

Linux currently runs in over-commit mode, since it actually makes alot
of sense.  Most processes ask for potentially huge amounts of memory,
but never use it.  So if I have 10mb of RAM, and process A asks for
5mb, and process b asks for 5mb I'm ok.  If process B asks for 6mb
then one of two things happens:

  Over commit mode:
       process B succeeds.

  Strict overcommit mode:
       process B gets a malloc failure and can't proceed. 

Even if A and B only want to use 2mb of RAM each, and the system would
have 6mb free, they could *ask* for the extra RAM and overcommit the
system and hit the OOM situation.

DEC OSF/1 had a toggle way back when in the early 90s to turn this
feature on and off.  Generally, being a school, we turned if off
(i.e. allowed lazy allocation) but for some core servers, we turned it
on to make sure the system was more stable.

In any case, what you're asking for is a *stupid user safety buffer*
and that's not sane.  As I said before, keeping around a few Mb for
root doesn't do shit when a root process runs and pushes the system
into OOM.

John



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
