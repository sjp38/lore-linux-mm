Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m53LS3r9016536
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 17:28:03 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m53LS2iS108228
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 15:28:02 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m53LS2Pc021951
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 15:28:02 -0600
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080603205752.GK20824@one.firstfloor.org>
References: <20080603095956.781009952@amd.local0.net>
	 <20080603100939.967775671@amd.local0.net>
	 <1212515282.8505.19.camel@nimitz.home.sr71.net>
	 <20080603182413.GJ20824@one.firstfloor.org>
	 <1212519555.8505.33.camel@nimitz.home.sr71.net>
	 <20080603205752.GK20824@one.firstfloor.org>
Content-Type: text/plain
Date: Tue, 03 Jun 2008 14:27:59 -0700
Message-Id: <1212528479.7567.28.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-03 at 22:57 +0200, Andi Kleen wrote:
> > The downside of something like this is that you have yet another data
> > structure to manage.  Andi, do you think something like this would be
> > workable?
> 
> The reason I don't like your proposal is that it makes only sense
> with a lot of hugepage sizes being active at the same time. But the
> API (one mount per size) doesn't really scale to that anyways.
> It should support two (as on x86), three if you stretch it, but
> anything beyond would be difficult.
> If you really wanted to support a zillion sizes you would at least
> first need a different flexible interface that completely hides page
> sizes.
> Otherwise you would drive both sysadmins and programmers crazy and 
> overlong command lines would be the smallest of their problems
> With two or even three sizes only the whole thing is not needed and my original
> scheme works fine IMHO.
> 
> That is why I was also sceptical of the newly proposed sysfs interfaces. 
> For two or three numbers you don't need a sysfs interface.

So, I think what I've proposed can be useful even for only two page
sizes.  This boot parameter is really one of the very few places users
will actually interact with huge pages and what I've suggested is simply
the most intuitive interface for them to use.  Either a fixed number of
megabytes or a percentage of total RAM is likely to be how people
actually think about it.  I hate getting out calculators to figure out
my kernel cmdline. :)

Also, as I said, users doesn't really know what the OS or hardware will
support and can't tell until the OS is up.  Firmware revisions,
different kernel versions, and different hypervisors can change this
underneath them.

We're expecting users to predict, properly balance, and commit to
their huge page allocation choices before boot.  Why do this when we
don't have to?

I don't think this adds any complexity at *all* for sysadmins or
programmers.  The legacy hugepages= command and sysctl interfaces can
stay as-is, and they get an optional and much easier to use interface.
I think sysadmins seriously appreciate things that aren't carved into
stone at boot.  I'm not sure how this makes it more complex for
programmers.  Could you elaborate on that?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
