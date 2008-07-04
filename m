Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <alpine.DEB.1.10.0807031938260.7820@asgard.lang.hm>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
	 <1215111362.10393.651.camel@pmac.infradead.org>
	 <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org>
	 <alpine.DEB.1.10.0807031938260.7820@asgard.lang.hm>
Content-Type: text/plain
Date: Fri, 04 Jul 2008 11:07:25 +0100
Message-Id: <1215166045.10393.738.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: David Miller <davem@davemloft.net>, tytso@mit.edu, jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-03 at 19:42 -0700, david@lang.hm wrote:
> > (After making it possible to build that firmware _into_ the kernel so that we 
> > aren't forcing people to use an initrd where they didn't before, of course.)
> 
> has this taken place yet? (and if so, what kernel version first included 
> this fix)

It's in linux-next now. See the CONFIG_EXTRA_FIRMWARE option.

That's one of the reasons Ted's ranting about 'religious fundamentalism'
is so funny -- I've actually made it _easier_ for you to combine
arbitrary firmware files into your kernel.

> >> If it was purely technical, you wouldn't be choosing defaults that
> >> break things for users by default.
> >
> > Actually, the beauty of Linux is that we _can_ change things where a minor 
> > short-term inconvenience leads to a better situation in the long term.
> 
> but doing so should not be a easy and quick decision, and it needs to be 
> made very clear exactly what breakage is going to take place and why 
> (along with the explination of why the breakage couldn't be avoided)

All forms of change introduce _some_ risk of breakage, of course. In
this case, as usual, I've tried to be careful to avoid regressions. The
most important part, obviously, was having a way to build firmware into
the static kernel.

When it comes to _modules_, doing that would introduce a certain amount
of complexity which just doesn't seem necessary -- if you can load
modules, then you have userspace, and you can use hotplug for firmware
too. Especially given that so many modern drivers already _require_ you
to do that, so the users understand it, and the tools like mkinitrd
already cope with it -- checking MODULE_FIRMWARE() for the modules they
include and including the appropriate files automatically.

The alleged problem with modules seems to be _just_ about the fact that
people need to run 'make firmware_install', and need to have their
firmware installed. Something which all modern drivers require _anyway_,
and people are used to in the general case already. It's not exactly
hard; there's just the initial step of realising that the driver _you_
are using has now been updated to behave like all the others.

That step is _minor_, and it doesn't actually get any easier _however_
long you postpone it. Yes, you might get 10 people in the first day
tripping over it, and I'll look to see if I can make it clearer. But
it's still a very minor, short-term thing.

I suspect that the best option is just to hold off on updating the net
drivers until later, when people already _know_ that they need to run
'make firmware_install', (or it happens automatically or something, if
we go down that route). That way, Dave and Jeff shouldn't be affected by
the initial transition period.

There's plenty of other drivers which need updating, after all. And most
maintainers are _happy_ to see the patches to bring their drivers in
line with best current practice.

> > I'll look at making the requirement for 'make firmware_install' more obvious, 
> > or even making it happen automatically as part of 'modules_install'.
> 
> I won't mind this as long as I can get a working kernel without doing make 
> firmware_install or make modules_install

You can. You need to stay sober for long enough to say 'Y' when it asks
you if you want to build the required firmware into the kernel. And we
even made that the _default_ now, for the benefit of those who can't
stay sober that long. (Perhaps we'll make 'allyesconfig' the default
next?)

>  (I almost never use modules, my laptop is one of the few exceptions,
> and even there it's mostly becouse of the intel wireless driver
> needing userspace for firmware)

You don't need to do that any more :)

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
