Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 970876B00CE
	for <linux-mm@kvack.org>; Wed, 22 May 2013 10:44:38 -0400 (EDT)
Date: Wed, 22 May 2013 17:44:06 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 00/10] uaccess: better might_sleep/might_fault behavior
Message-ID: <20130522144406.GB21886@redhat.com>
References: <cover.1368702323.git.mst@redhat.com>
 <201305221125.36284.arnd@arndb.de>
 <20130522134124.GD18614@n2100.arm.linux.org.uk>
 <201305221604.49185.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201305221604.49185.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-m32r-ja@ml.linux-m32r.org, kvm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-arch@vger.kernel.org, linux-am33-list@redhat.com, Hirokazu Takata <takata@linux-m32r.org>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, microblaze-uclinux@itee.uq.edu.au, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-m32r@ml.linux-m32r.org, linux-kernel@vger.kernel.org, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linuxppc-dev@lists.ozlabs.org

On Wed, May 22, 2013 at 04:04:48PM +0200, Arnd Bergmann wrote:
> On Wednesday 22 May 2013, Russell King - ARM Linux wrote:
> > On Wed, May 22, 2013 at 11:25:36AM +0200, Arnd Bergmann wrote:
> > > Given the most commonly used functions and a couple of architectures
> > > I'm familiar with, these are the ones that currently call might_fault()
> > > 
> > >                       x86-32  x86-64  arm     arm64   powerpc s390    generic
> > > copy_to_user          -       x       -       -       -       x       x
> > > copy_from_user        -       x       -       -       -       x       x
> > > put_user              x       x       x       x       x       x       x
> > > get_user              x       x       x       x       x       x       x
> > > __copy_to_user        x       x       -       -       x       -       -
> > > __copy_from_user      x       x       -       -       x       -       -
> > > __put_user            -       -       x       -       x       -       -
> > > __get_user            -       -       x       -       x       -       -
> > > 
> > > WTF?
> > 
> > I think your table is rather screwed - especially on ARM.  Tell me -
> > how can __copy_to_user() use might_fault() but copy_to_user() not when
> > copy_to_user() is implemented using __copy_to_user() ?  Same for
> > copy_from_user() but the reverse argument - there's nothing special
> > in our copy_from_user() which would make it do might_fault() when
> > __copy_from_user() wouldn't.
> 
> I think something went wrong with formatting of the tabstobs in
> the table. I've tried to correct it above to the same version I
> see on the mailing list.
> 
> > The correct position for ARM is: our (__)?(pu|ge)t_user all use
> > might_fault(), but (__)?copy_(to|from)_user do not.  Neither does
> > (__)?clear_user.  We might want to fix those to use might_fault().
> 
> Yes, that sounds like a good idea, especially since they are all
> implemented out-of-line.
> 
> For __get_user()/__put_user(), I would probably do the reverse and make
> them not call might_fault() though, like we do on most other architectures:
> 
> Look at the object code produced for setup_sigframe for instance, it calls
> might_fault() around 25 times where one should really be enough.

Well it depends on what config options you set.
But with VOLUNTARY you are right.
Also, look at memcpy_fromiovec and weep.

> Using
> __put_user() instead of put_user() is normally an indication that the
> author of that function has made performance considerations and move the
> (trivial) access_ok() call out, but now we add a more expensive
> call instead.
> 
> 	Arnd

I think exactly the same rules should apply to __XXX_user and
__copy_XXX_user - otherwise it's really confusing.

Maybe a preempt point in might_fault should go away?
Basically

#define might_fault() __might_sleep(__FILE__, __LINE__, 0)

Possibly adding the in_atomic() etc checks that Peter suggested.

Ingo, what do you think? And what testing would be appropriate
for such a change?


Thanks,

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
