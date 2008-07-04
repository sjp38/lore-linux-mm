Date: Fri, 4 Jul 2008 10:30:58 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704143058.GB23215@mit.edu>
References: <1215093175.10393.567.camel@pmac.infradead.org> <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <486E2818.1060003@garzik.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <486E2818.1060003@garzik.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: David Woodhouse <dwmw2@infradead.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2008 at 09:39:36AM -0400, Jeff Garzik wrote:
> You have been told repeatedly that cp(1) and scp(1) are commonly used to  
> transport the module David and I care about -- tg3.  It's been a single  
> file module since birth, and people take advantage of that fact.

Here, I think I'll have to respectly disagree with you and say that
you are taking things too far.  I don't think scp'ing individual
modules around counts as an "exported user interface" the same way,
say "make install; make modules_install" is a commonly understand and
used interface by users and scripts (i.e., such as Debian's make-kpkg,
which does NOT know about "make firmware_install", BTW).

Asking developers that they need to scp an additional module doesn't
seem terribly onerous to me --- especially if the firmware module is
much more likely to be static, and probably doesn't need to be changed
after each compile/edit/debug cycle.

So on this point I'd side with David, and say that folding "make
firmware_install" into "make modules_install" goes a long way towards
healing this particular breakage.

HOWEVER, as I mentioned in another message, it looks like not all
forms of mkinitd and/or mkinitramfs scripts deal with /lib/firmware
correctly, including the one used by the latest version of Ubuntu.
That to me is a strong argument for either (a) leaving drivers the way
they are now, or (b) making the new request_firmware() framework be
able to place the firemware in either the original driver module, or
in another tg3_firmware.ko module --- which could be unloaded
afterwards, if people really cared about the non-swappable kernel
memory being used up.)

And this is where we pay the price for not having a standard initrd
generation (with appropriate hooks so that distros could drop in their
own enhancements) as part of the kernel build process.  If we did, it
would be a lot easier to make sure all distro's learn about new
requirements that we have imposed on the initrd.  Because we haven't,
initrd's are effectively part of the "exported interface" where we
have to move slowly enough so that distro's can catch up depending on
their release schedule.  (It also makes it much harder to run a
bleeding-edge kernel on a release distro system, at least without
tieing our hands with respect to changes involving the initrd.)

       	   	      	      	 	 	       - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
