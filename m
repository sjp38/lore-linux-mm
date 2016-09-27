Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7B8F28027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:42:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n24so23609113pfb.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:42:36 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g79si2474077pfg.60.2016.09.27.04.42.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 04:42:36 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id n24so644510pfb.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:42:36 -0700 (PDT)
Date: Tue, 27 Sep 2016 21:42:29 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
Message-ID: <20160927214229.2b0b49ac@roar.ozlabs.ibm.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB010A97D@AcuExch.aculab.com>
References: <20160922152831.24165-1-vbabka@suse.cz>
	<006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
	<20160923172434.7ad8f2e0@roar.ozlabs.ibm.com>
	<57E55CBB.5060309@akamai.com>
	<5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
	<20160927212458.3ab42b41@roar.ozlabs.ibm.com>
	<063D6719AE5E284EB5DD2968C1650D6DB010A97D@AcuExch.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jason Baron <jbaron@akamai.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Michal Hocko' <mhocko@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, 27 Sep 2016 11:37:24 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Nicholas Piggin
> > Sent: 27 September 2016 12:25
> > On Tue, 27 Sep 2016 10:44:04 +0200
> > Vlastimil Babka <vbabka@suse.cz> wrote:
> >   
> > > On 09/23/2016 06:47 PM, Jason Baron wrote:  
> > > > Hi,
> > > >
> > > > On 09/23/2016 03:24 AM, Nicholas Piggin wrote:  
> > > >> On Fri, 23 Sep 2016 14:42:53 +0800
> > > >> "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:
> > > >>  
> > > >>>>
> > > >>>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
> > > >>>> with the number of fds passed. We had a customer report page allocation
> > > >>>> failures of order-4 for this allocation. This is a costly order, so it might
> > > >>>> easily fail, as the VM expects such allocation to have a lower-order fallback.
> > > >>>>
> > > >>>> Such trivial fallback is vmalloc(), as the memory doesn't have to be
> > > >>>> physically contiguous. Also the allocation is temporary for the duration of the
> > > >>>> syscall, so it's unlikely to stress vmalloc too much.
> > > >>>>
> > > >>>> Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
> > > >>>> it doesn't need this kind of fallback.  
> > > >>
> > > >> How about something like this? (untested)  
> > >
> > > This pushes the limit further, but might just delay the problem. Could be an
> > > optimization on top if there's enough interest, though.  
> > 
> > What's your customer doing with those selects? If they care at all about
> > performance, I doubt they want select to attempt order-4 allocations, fail,
> > then use vmalloc :)  
> 
> If they care about performance they shouldn't be passing select() lists that
> are anywhere near that large.
> If the number of actual fd is small - use poll().

Right. Presumably it's some old app they're still using, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
