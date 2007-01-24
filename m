Received: by wx-out-0506.google.com with SMTP id s8so53511wxc
        for <linux-mm@kvack.org>; Tue, 23 Jan 2007 19:51:39 -0800 (PST)
Message-ID: <6d6a94c50701231951o66487813vcd078fc25e25ffa0@mail.gmail.com>
Date: Wed, 24 Jan 2007 11:51:39 +0800
From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <Pine.LNX.4.64.0701231908420.6123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	 <45B6CBD9.80600@yahoo.com.au>
	 <Pine.LNX.4.64.0701231908420.6123@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On 1/24/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Wed, 24 Jan 2007, Nick Piggin wrote:
>
> > > 1. Insure that anonymous pages that may contain performance
> > >    critical data is never subject to swap.
> > >
> > > 2. Insure rapid turnaround of pages in the cache.
> >
> > So if these two aren't working properly at 100%, then I want to know the
> > reason why. Or at least see what the workload and the numbers look like.
>
> The reason for the anonymous page may be because data is rarely touched
> but for some reason the pages must stay in memory. Rapid turnaround is
> just one of the reason that I vaguely recall but I never really
> understood what the purpose was.
>
> > > 3. Reserve memory for other uses? (Aubrey?)
> >
> > Maybe. This is still a bad hack, and I don't like to legitimise such use
> > though. I hope Aubrey isn't relying on this alone for his device to work
> > because his customers might end up hitting fragmentation problems sooner
> > or later.
>
> I surely wish that Aubrey would give us some more clarity on
> how this should work. Maybe the others who want this feature could also
> speak up? I am not that clear on its purpose.
>
Sorry for the delay. Somehow this thread was put into the spam folder
of my gmail box. :(
The patch I posted several days ago works properly on my side. I'm
working on blackfin-uclinux platform. So I'm not sure it works 100% on
the other arch platform. From O_DIRECT threads, I know different
people suffer from VFS pagecache issue for different reason. So I
really hope the patch can be improved.

On my side, When VFS pagecache eat up all of the available memory,
applications who want to allocate the largeish block(order =4 ?) will
fail. So the logic is as follows:

if request pagecache
      watermark =  min + reserved_pagecache.
else
      watermark =  min.

Here, assume min=123 pages, reserved_pagecache = 200 pages. That means
when VFS pagecache eat up its all of available memory, there are still
200 pages available for the allocation of the application. Does that
make sense?

> I hope Aubrey isn't relying on this alone for his device to work
> because his customers might end up hitting fragmentation problems sooner
> or later.

That's true. I wrote a replacement of buddy system, it's here:
http://lkml.org/lkml/2006/12/30/36.

That can improve the fragmentation problems on our platform.

Christoph - I can't find your original patch, Can you send me again?
it would be great if you merged all of the  enhancement.

Thanks,
-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
