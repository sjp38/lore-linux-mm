Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 53D596B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 01:24:21 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so6041110pdj.37
        for <linux-mm@kvack.org>; Sun, 06 Apr 2014 22:24:21 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id a8si7779320pbs.414.2014.04.06.22.24.18
        for <linux-mm@kvack.org>;
        Sun, 06 Apr 2014 22:24:20 -0700 (PDT)
Date: Mon, 7 Apr 2014 14:24:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
Message-ID: <20140407052429.GB12144@bbox>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
 <20140401212102.GM4407@cmpxchg.org>
 <533B313E.5000403@zytor.com>
 <533B4555.3000608@sr71.net>
 <533B8E3C.3090606@linaro.org>
 <20140402163638.GQ14688@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402163638.GQ14688@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: John Stultz <john.stultz@linaro.org>, Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 02, 2014 at 12:36:38PM -0400, Johannes Weiner wrote:
> On Tue, Apr 01, 2014 at 09:12:44PM -0700, John Stultz wrote:
> > On 04/01/2014 04:01 PM, Dave Hansen wrote:
> > > On 04/01/2014 02:35 PM, H. Peter Anvin wrote:
> > >> On 04/01/2014 02:21 PM, Johannes Weiner wrote:
> > >>> Either way, optimistic volatile pointers are nowhere near as
> > >>> transparent to the application as the above description suggests,
> > >>> which makes this usecase not very interesting, IMO.
> > >> ... however, I think you're still derating the value way too much.  The
> > >> case of user space doing elastic memory management is more and more
> > >> common, and for a lot of those applications it is perfectly reasonable
> > >> to either not do system calls or to have to devolatilize first.
> > > The SIGBUS is only in cases where the memory is set as volatile and
> > > _then_ accessed, right?
> > Not just set volatile and then accessed, but when a volatile page has
> > been purged and then accessed without being made non-volatile.
> > 
> > 
> > > John, this was something that the Mozilla guys asked for, right?  Any
> > > idea why this isn't ever a problem for them?
> > So one of their use cases for it is for library text. Basically they
> > want to decompress a compressed library file into memory. Then they plan
> > to mark the uncompressed pages volatile, and then be able to call into
> > it. Ideally for them, the kernel would only purge cold pages, leaving
> > the hot pages in memory. When they traverse a purged page, they handle
> > the SIGBUS and patch the page up.
> 
> How big are these libraries compared to overall system size?

One of the example about jit I had is 5M bytes for just simple node.js
service. Acutally I'm not sure it was JIT or something. Just what I saw
was it was rwxp vmas so I guess they are JIT.
Anyway, it's really simple script but consumed 5M bytes. It's really
big for Embedded WebOS because other more complicated service could be
executed in parallel on the system.

> 
> > Now.. this is not what I'd consider a normal use case, but was hoping to
> > illustrate some of the more interesting uses and demonstrate the
> > interfaces flexibility.
> 
> I'm just dying to hear a "normal" use case then. :)
> 
> > Also it provided a clear example of benefits to doing LRU based
> > cold-page purging rather then full object purging. Though I think the
> > same could be demonstrated in a simpler case of a large cache of objects
> > that the applications wants to mark volatile in one pass, unmarking
> > sub-objects as it needs.
> 
> Agreed.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
