Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA19296
	for <linux-mm@kvack.org>; Wed, 29 Jan 2003 18:03:06 -0800 (PST)
Date: Wed, 29 Jan 2003 18:19:59 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Linus rollup
Message-Id: <20030129181959.66111da0.akpm@digeo.com>
In-Reply-To: <20030130015427.GU1237@dualathlon.random>
References: <20030129022617.62800a6e.akpm@digeo.com>
	<1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
	<20030129151206.269290ff.akpm@digeo.com>
	<20030129.163034.130834202.davem@redhat.com>
	<20030129172743.1e11d566.akpm@digeo.com>
	<20030130013522.GP1237@dualathlon.random>
	<20030129180054.03ac0d48.akpm@digeo.com>
	<20030130015427.GU1237@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: davem@redhat.com, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> On Wed, Jan 29, 2003 at 06:00:54PM -0800, Andrew Morton wrote:
> > Andrea Arcangeli <andrea@suse.de> wrote:
> > >
> > > On Wed, Jan 29, 2003 at 05:27:43PM -0800, Andrew Morton wrote:
> > > > @@ -82,11 +85,12 @@ static inline int fr_write_trylock(frloc
> > > >  
> > > >  	if (ret) {
> > > >  		++rw->pre_sequence;
> > > > -		wmb();
> > > > +		mb();
> > > >  	}
> > > 
> > > this isn't needed
> > > 
> > > 
> > > if we hold the spinlock, the serialized memory can't be change under us,
> > > so there's no need to put a read barrier, we only care that pre_sequence
> > > is visible before the chagnes are visible and before post_sequence is
> > > visible, hence only wmb() (after spin_lock and pre_sequence++) is
> > > needed there and only rmb() is needed in the read-side.
> > > 
> > 
> > OK, thanks muchly.
> > 
> > Lots more updates.  Here's the version which I currently have.  Looks like
> > fr_write_lock() and fr_write_unlock() need to be switched back to rmb()?
> 
> you certainly mean wmb() not rmb(), right? If yes, then yes.

Yup.


> I actually didn't notice the write_begin/end, not sure who could need
> them, I would suggest removing them, rather than to revert the mb()
> there too.

The intent here was to use them for i_size updates.  In situations where
writer serialisation was provided by external means (i_sem), and the spinlock
is not needed.

It's causing confusion so yeah, I'll probably pull them out.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
