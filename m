Date: Tue, 17 Aug 1999 00:23:04 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <Pine.LNX.4.10.9908170003290.1048-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.95.990817000705.19678B-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: andrea@suse.de, alan@lxorguk.ukuu.org.uk, "Stephen C. Tweedie" <sct@redhat.com>, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, linux-usb@suse.com
List-ID: <linux-mm.kvack.org>


On Tue, 17 Aug 1999, Linus Torvalds wrote:
> 
> The code in question cannot be "fixed". It's doing something wrong in the
> first place, 

To expand on the above:

 If you write a driver and you want to give direct DMA access to some
program, the way to do it is NOT by using some magic ioctl number and
doing stupid things like some drivers do (ie notably bttv).

The way to do it is to just be up-front about the fact that the user
process wants direct access to the buffers that the IO is done from, and
use an explicit mmap() on the file descriptor. The driver can then
allocate a contiguous chunk of memory of the right type, and with the
right restrictions, and then let the nopage() function page it into the
user process space. 

Suddenly, such a _wellwritten_ driver no longer needs to play games with
the page tables. And such a well written driver wouldn't have any problems
at all with the BIGMEM patches.

Btw, this is not somehting new. Quite a number of sound drivers do exactly
this, and have been doing it for several years. I don't know why the bttv
driver has to be so broken, but as far as I can tell it's one of two (the
other one being some completely obscure planb driver for power macs).

Oh, and I notice that the USB cpia driver does bad things too, although it
seems to be limited to vmalloc'ed memory so it's not nearly as horrible. 
It seems to have copied the bug from the bttv sources. Johannes, could you
look at that a bit, it really _is_ going to break horribly at some point,
and I hadn't noticed until after I did a quick grep.. You can use
__get_free_pages() to grab a larger area than just a single page. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
