Date: Fri, 28 Jan 2000 12:26:50 -0500
Message-Id: <200001281726.MAA12528@tsx-prime.MIT.EDU>
From: "Theodore Y. Ts'o" <tytso@MIT.EDU>
In-reply-to: Ivan Kokshaysky's message of Fri, 28 Jan 2000 19:48:27 +0300,
	<20000128194827.A23800@jurassic.park.msu.ru>
Subject: Re: 2.2.15pre4 VM fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

   On Fri, Jan 28, 2000 at 02:40:30PM +0000, Alan Cox wrote:
   > > n_tty_open() has been caught with your patch.
   > > Thanks!
   > 
   > Do you know which drivers (serial,tty) you were using it. n_tty_open itself
   > seems ok, but the caller may be guilty

   It happened when ppp connection was terminated (remote end hangup).
   Serial driver is Comtrol Rocketport. The problem is repeatable
   (3 times last 20 hours), so I can investigate further to see who
   is the caller.

I think it's a flase positive.  It's happeninig because tty_do_hangup()
is calling ldisc.open --- which means n_tty_open() inside an interrupt
context.  n_tty_open() makes a check to see whether it is being called
inside an interrupt, and uses GFP_ATOMIC to avoid blocking inside the
interrupt.  


static int n_tty_open(struct tty_struct *tty)
{
	....
		get_zeroed_page(in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
	...
}

This should be OK, I think.

						- Ted
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
