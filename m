Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 6A8886B0073
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 08:21:18 -0400 (EDT)
Date: Wed, 24 Oct 2012 13:26:03 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH v2 2/6] PM / Runtime: introduce
 pm_runtime_set_memalloc_noio()
Message-ID: <20121024132603.6c52cc47@pyramind.ukuu.org.uk>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7060@saturn3.aculab.com>
References: <CACVXFVMmszZWHaeNS6LSG4nHR4wWBLwM_BvynRwUW8X=nO+JWA@mail.gmail.com>
	<Pine.LNX.4.44L0.1210231022230.1635-100000@iolanthe.rowland.org>
	<CACVXFVN+=XH_f5BmRkXeagTNowz0o0-Pd7GcxCneO0FSq8xqEw@mail.gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7060@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: Ming Lei <ming.lei@canonical.com>, Alan Stern <stern@rowland.harvard.edu>, linux-kernel@vger.kernel.org, Oliver
 Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Wed, 24 Oct 2012 10:06:36 +0100
"David Laight" <David.Laight@ACULAB.COM> wrote:

> > Looks the problem is worse than above, not only bitfields are affected, the
> > adjacent fields might be involved too, see:
> > 
> >            http://lwn.net/Articles/478657/
> 
> Not mentioned in there is that even with x86/amd64 given
> a struct with the following adjacent fields:
> 	char a;
> 	char b;
> 	char c;
> then foo->b |= 0x80; might do a 32bit RMW cycle.

There are processors that will do this for the char case at least as they
do byte ops by a mix of 32bit ops and rotate.

> This will (well might - but probably does) happen
> if compiled to a 'BTS' instruction.
> The x86 instruction set docs are actually unclear
> as to whether the 32bit cycle might even be misaligned!
> amd64 might do a 64bit cycle (not checked the docs).

Even with a suitably aligned field the compiler is at liberty to generate
things like

	reg = 0x80
	reg |= foo->b
	foo->b = reg;

One reason it's a good idea to use set_bit/test_bit and friends.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
