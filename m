Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA23666
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 20:15:25 -0500
Message-Id: <m104bU6-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
Date: Mon, 25 Jan 1999 02:10:37 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.96.990125015519.19018A-100000@laser.bogus> from "Andrea Arcangeli" at Jan 25, 99 02:04:59 am
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, werner@suse.de, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If I understand well the problem is get more than 1<<maxorder contiguos
> phys pages in RAM. I think it should not too difficult to do a dirty hack

Yep. We are talking about 2->4Mb sized chunks. We are also talking about
chunks that are allocated rarely - for example when you load wave data
into the sound card, while you are capturing etc. So its blocks that
can be slow to allocate, slow to free, so long as they are normal speed
to access. That may make the problem a lot easier

> alternate __get_big_pages that does some try to get many mem-areas of the
> maximal order contigous. Maybe it will not able to give you such contiguos
> memory (due mem fragmentation) but if it's possible it will give back it
> to you (_slowly_). Then you should use an aware free_big_pages() to give
> back the memory. That way the codebase (for people that doesn't need
> __get_big_pages in their device drivers) will be untouched (so no codebase
> stability issues). 

That fact we effectively "poison" the various blocks of memory with locked
down kernel objects is what makes this so tricky. It really needs some back
pressure applied so that kernel allocations come from a limited number of
maxorder blocks, at least except under exceptional circumstances.

I think its too tricky for 2.2 even as a later retrofit

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
