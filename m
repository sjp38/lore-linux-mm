Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8850128027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:25:06 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu14so20153637pad.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:25:06 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id h15si2407451pfe.82.2016.09.27.04.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 04:25:05 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id oz2so611319pac.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:25:05 -0700 (PDT)
Date: Tue, 27 Sep 2016 21:24:58 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
Message-ID: <20160927212458.3ab42b41@roar.ozlabs.ibm.com>
In-Reply-To: <5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
References: <20160922152831.24165-1-vbabka@suse.cz>
	<006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
	<20160923172434.7ad8f2e0@roar.ozlabs.ibm.com>
	<57E55CBB.5060309@akamai.com>
	<5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jason Baron <jbaron@akamai.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 'Michal Hocko' <mhocko@kernel.org>, netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, 27 Sep 2016 10:44:04 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:

> On 09/23/2016 06:47 PM, Jason Baron wrote:
> > Hi,
> >
> > On 09/23/2016 03:24 AM, Nicholas Piggin wrote:  
> >> On Fri, 23 Sep 2016 14:42:53 +0800
> >> "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:
> >>  
> >>>>
> >>>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
> >>>> with the number of fds passed. We had a customer report page allocation
> >>>> failures of order-4 for this allocation. This is a costly order, so it might
> >>>> easily fail, as the VM expects such allocation to have a lower-order fallback.
> >>>>
> >>>> Such trivial fallback is vmalloc(), as the memory doesn't have to be
> >>>> physically contiguous. Also the allocation is temporary for the duration of the
> >>>> syscall, so it's unlikely to stress vmalloc too much.
> >>>>
> >>>> Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
> >>>> it doesn't need this kind of fallback.  
> >>
> >> How about something like this? (untested)  
> 
> This pushes the limit further, but might just delay the problem. Could be an 
> optimization on top if there's enough interest, though.

What's your customer doing with those selects? If they care at all about
performance, I doubt they want select to attempt order-4 allocations, fail,
then use vmalloc :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
