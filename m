From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re: Remove page flags for software suspend)
Date: Thu, 8 Mar 2007 23:33:05 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200703082305.43513.rjw@sisk.pl> <1173391817.3831.4.camel@johannes.berg>
In-Reply-To: <1173391817.3831.4.camel@johannes.berg>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703082333.06679.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thursday, 8 March 2007 23:10, Johannes Berg wrote:
> On Thu, 2007-03-08 at 23:05 +0100, Rafael J. Wysocki wrote:
> 
> > > The easiest solution I came up with is below. Of course, the suspend
> > > patches for powerpc64 are still very much work in progress and I might
> > > end up changing the whole reservation scheme after some feedback... If
> > > nobody else needs this then don't think about it now.
> > 
> > Well, it may be needed for other things too.
> 
> Yeah, but it's probably better to wait for them :)

Agreed.

> > I think we should pass a mask.  BTW, can you please check if the appended patch
> > is sufficient?
> 
> Unfortunately I won't be able to actually try this on hardware until the
> 20th or so.

OK, it's not an urgent thing. ;-)

> > > With this patch and appropriate changes to my suspend code, it works.
> > 
> > OK, thanks for testing!
> 
> Forgot to mention, patches are at
> http://johannes.sipsolutions.net/patches/ look for the latest
> powerpc-suspend-* patchset.

Thanks for the link.
 
> > +	if (system_state == SYSTEM_BOOTING) {
> > +		/* This allocation cannot fail */
> > +		region = alloc_bootmem_low(sizeof(struct nosave_region));
> > +	} else {
> > +		region = kzalloc(sizeof(struct nosave_region), GFP_ATOMIC);
> > +		if (!region) {
> > +			printk(KERN_WARNING "swsusp: Not enough memory "
> > +				"to register a nosave region!\n");
> > +			WARN_ON(1);
> > +			return;
> > +		}
> > +	}
> 
> I don't think that'll be sufficient, system_state = SYSTEM_BOOTING is
> done only in init/main.c:init_post which is done after after calling the
> initcalls (they are called in do_basic_setup)

Well, I don't think so.  If I understand the definition of system_state
correctly, it is initially equal to SYSTEM_BOOTING.  Then, it's changed to
SYSTEM_RUNNING in init/main.c after the bootmem has been freed.

Anyway, the patch works on x86_64. :-)

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
