Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA20946
	for <linux-mm@kvack.org>; Thu, 30 Jan 2003 15:44:40 -0800 (PST)
Message-ID: <3E39B8E6.5F668D28@digeo.com>
Date: Thu, 30 Jan 2003 15:44:38 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: New version of frlock (now called seqlock)
References: <1043969416.10155.619.camel@dell_ss3.pdx.osdl.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen Hemminger wrote:
> 
> This is an update to the earlier frlock.
> 

Sorry, but I have lost track of what version is what.  Please
let me get my current act together and then prepare diffs
against (or new versions of) that.

You appear to have not noticed my earlier suggestions wrt
coding tweaks and inefficiencies in the new implementation.

- SEQ_INIT and seq_init can go away.

- do seq_write_begin/end need wmb(), or mb()?  Probably, we
  should just remove these functions altogether.

-
	+static inline int seq_read_end(const seqcounter_t *s, unsigned iv)
	+{
	+       mb();
	+       return (s->counter != iv) || (iv & 1);
	+}

  So the barriers changed _again_!  Could we please at least
  get Richard Henderson and Andrea to agree that this is the
  right way to do it?

-
	+typedef struct {
	+       volatile unsigned counter;
	+} seqcounter_t;

  Why did this become a struct?

  Why is it volatile?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
