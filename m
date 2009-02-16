Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 14AF16B00AF
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 12:37:18 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1GHZct8020036
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:35:38 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1GHbGTK224310
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:37:16 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1GHbFeu020950
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:37:16 -0700
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090213152836.0fbbfa7d.akpm@linux-foundation.org>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz>
	 <20090213152836.0fbbfa7d.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 16 Feb 2009 09:37:13 -0800
Message-Id: <1234805833.30155.258.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@elte.hu, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-13 at 15:28 -0800, Andrew Morton wrote:
> > > For extra marks:
> > > 
> > > - Will any of this involve non-trivial serialisation of kernel
> > >   objects?  If so, that's getting into the
> > >   unacceptably-expensive-to-maintain space, I suspect.
> > 
> > We have some structures that are certainly tied to the kernel-internal
> > ones.  However, we are certainly *not* simply writing kernel structures
> > to userspace.  We could do that with /dev/mem.  We are carefully pulling
> > out the minimal bits of information from the kernel structures that we
> > *need* to recreate the function of the structure at restart.  There is a
> > maintenance burden here but, so far, that burden is almost entirely in
> > checkpoint/*.c.  We intend to test this functionality thoroughly to
> > ensure that we don't regress once we have integrated it.
> 
> I guess my question can be approximately simplified to: "will it end up
> looking like openvz"?  (I don't believe that we know of any other way
> of implementing this?)
> 
> Because if it does then that's a concern, because my assessment when I
> looked at that code (a number of years ago) was that having code of
> that nature in mainline would be pretty costly to us, and rather
> unwelcome.

With the current path, my guess is that we will end up looking
*something* like OpenVZ.  But, with all the input from the OpenVZ folks
and at least three other projects, I bet we can come up with something
better.  I do wish the OpenVZ folks were being more vocal and
constructive about Oren's current code but I guess silence is the
greatest complement...

> The broadest form of the question is "will we end up regretting having
> done this".
> If we can arrange for the implementation to sit quietly over in a
> corner with a team of people maintaining it and not screwing up other
> people's work then I guess we'd be OK - if it breaks then the breakage
> is localised.
> 
> And it's not just a matter of "does the diffstat only affect a single
> subdirectory".  We also should watch out for the imposition of new
> rules which kernel code must follow.  "you can't do that, because we
> can't serialise it", or something.
> 
> Similar to the way in which perfectly correct and normal kernel
> sometimes has to be changed because it unexpectedly upsets the -rt
> patch.
> 
> Do you expect that any restrictions of this type will be imposed?

Basically, yes.  But, practically, we haven't been thinking about
serializing stuff in the kernel, ever.  That's produced a few
difficult-to-serialize things like AF_UNIX sockets but absolutely
nothing that simply can't be done.  

Having this code in mainline and getting some of people's mindshare
should at least enable us to speak up if we see another thing like
AF_UNIX coming down the pipe.  We could hopefully catch it and at least
tweak it a bit to enhance how easily we can serialize it. 

Again, it isn't likely to be an all-or-nothing situation.  It is a
matter of how many hoops the checkpoint code itself has to jump
through. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
