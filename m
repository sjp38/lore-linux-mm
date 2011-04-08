Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7808D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 17:02:12 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p38KkEB1022230
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 14:46:14 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p38L26P3096086
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 15:02:06 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p38L25lq015534
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 15:02:06 -0600
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <BANLkTi=OnDX53nOZcaaMmqXRBcWicam0xg@mail.gmail.com>
References: <20110408202253.6D6D231C@kernel>
	 <BANLkTi=OnDX53nOZcaaMmqXRBcWicam0xg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Apr 2011 14:02:02 -0700
Message-ID: <1302296522.7286.1197.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Micha=C5=82?= Nazarewicz <mnazarewicz@gmail.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

On Fri, 2011-04-08 at 22:54 +0200, MichaA? Nazarewicz wrote:
> On Apr 8, 2011 10:23 PM, "Dave Hansen" <dave@linux.vnet.ibm.com> wrote:
> > +       if (fmt) {
> > +               printk(KERN_WARNING);
> > +               va_start(args, fmt);
> > +               r = vprintk(fmt, args);
> > +               va_end(args);
> > +       }
> 
> Could we make the "printk(KERN_WARNING);" go away and require caller
> to specify level?  

The core problem is this: I want two lines of output: one for the
order/mode gunk, and one for the user-specified message.

If we have the user pass in a string for the printk() level, we're stuck
doing what I have here.  If we have them _prepend_ it to the "fmt"
string, then it's harder to figure out below.  I guess we could fish in
the string for it.

> > +       printk(KERN_WARNING);
> > +       printk("%s: page allocation failure: order:%d, mode:0x%x\n",
> > +                       current->comm, order, gfp_mask);
> 
> Even more so here. Why not pr_warning instead of two non-atomic calls
> to printk?

It's a relic of an hour ago when I tried passing in the printk() level
to the function as a string.  It can go away now. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
