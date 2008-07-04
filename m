Message-ID: <486D6DDB.4010205@infradead.org>
Date: Fri, 04 Jul 2008 01:24:59 +0100
From: David Woodhouse <dwmw2@infradead.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	<20080703173040.GB30506@mit.edu>	<1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net>
In-Reply-To: <20080703.162120.206258339.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: tytso@mit.edu, jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Thu, 03 Jul 2008 19:56:02 +0100
> 
>> It's wrong to change the CONFIG_FIRMWARE_IN_KERNEL default to 'Y',
>> because the _normal_ setting for that option _really_ should be 'N'.
> 
> On what basis?  From a "obviously works" basis, the default should be
> 'y'.

I already changed it to 'y'.

>> What we're doing now is just cleaning up the older drivers which don't
>> use request_firmware(), to conform to what is now common practice.
> 
> You say "conform" I say "break".

You mean...
	"What we're doing now is just cleaning up the older drivers
	 which don't use request_firmware(), to break to what is now
	 common practice."
?

Doesn't really scan, does it?

Common practice in modern Linux drivers is to use request_firmware(). 
I'm just going through and fixing up the older ones to do that too.

(After making it possible to build that firmware _into_ the kernel so 
that we aren't forcing people to use an initrd where they didn't before, 
of course.)

The word for that is definitely 'conform'. I know you don't _like_ the 
modern accepted practice, but that's _your_ windmill to tilt at. I have 
my own :)

>> In the meantime, it would be useful if Jeff would quit throwing his toys
>> out of the pram on that issue and actually review the _code_ changes. In
>> particular, are the reports correct that the device operates just fine
>> without the TSO firmware loaded? Should we change the request_firmware()
>> error path to just disable TSO and continue with the initialisation?
> 
> No!
> 
> The 5701 A0 firmware is necessary to load in order to work around
> hardware and existing firmware bugs on those cards.  It's an issue of
> basic functionality, not just optimizations.
> 
> 5701 A0 tg3 chips cannot operate at all without the firmware being
> present in the driver.
> 
> Therefore, if you can't load the firmware, the card is not going to
> work.

Neat avoidance of question there... it was fairly clear that the 5701_A0 
firmware was going to be mandatory; I was asking about the TSO firmware.

Does anyone _else_ actually want to give a straight answer to a simple 
question? Someone who wouldn't have to follow it with an apology because 
of all their shouting about 'breakage' when the firmware in question is 
actually optional anyway, perhaps?


 > If it was purely technical, you wouldn't be choosing defaults that
 > break things for users by default.

Actually, the beauty of Linux is that we _can_ change things where a 
minor short-term inconvenience leads to a better situation in the long term.

 > Jeff and I warned you about this from day one, you did not listen, and
 > now we have at least 10 reports just today of people with broken
 > networking.

Out of interest... of those, what proportion would be 'fixed' if they'd 
just paid attention when running 'make oldconfig', which is now 
addressed because I've changed the FIRMWARE_IN_KERNEL default to 'y'?

And how many would be 'fixed' if someone had given me a straight answer 
when I asked about the TSO firmware, and that failure path no longer 
aborted the driver initialisation but instead just fell back to non-TSO?

I'll look at making the requirement for 'make firmware_install' more 
obvious, or even making it happen automatically as part of 
'modules_install'.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
