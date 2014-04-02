Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1166B00BD
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 12:36:59 -0400 (EDT)
Received: by mail-bk0-f50.google.com with SMTP id w10so67663bkz.9
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 09:36:58 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id j9si1246031bko.217.2014.04.02.09.36.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 09:36:58 -0700 (PDT)
Date: Wed, 2 Apr 2014 12:36:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
Message-ID: <20140402163638.GQ14688@cmpxchg.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
 <20140401212102.GM4407@cmpxchg.org>
 <533B313E.5000403@zytor.com>
 <533B4555.3000608@sr71.net>
 <533B8E3C.3090606@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533B8E3C.3090606@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Apr 01, 2014 at 09:12:44PM -0700, John Stultz wrote:
> On 04/01/2014 04:01 PM, Dave Hansen wrote:
> > On 04/01/2014 02:35 PM, H. Peter Anvin wrote:
> >> On 04/01/2014 02:21 PM, Johannes Weiner wrote:
> >>> Either way, optimistic volatile pointers are nowhere near as
> >>> transparent to the application as the above description suggests,
> >>> which makes this usecase not very interesting, IMO.
> >> ... however, I think you're still derating the value way too much.  The
> >> case of user space doing elastic memory management is more and more
> >> common, and for a lot of those applications it is perfectly reasonable
> >> to either not do system calls or to have to devolatilize first.
> > The SIGBUS is only in cases where the memory is set as volatile and
> > _then_ accessed, right?
> Not just set volatile and then accessed, but when a volatile page has
> been purged and then accessed without being made non-volatile.
> 
> 
> > John, this was something that the Mozilla guys asked for, right?  Any
> > idea why this isn't ever a problem for them?
> So one of their use cases for it is for library text. Basically they
> want to decompress a compressed library file into memory. Then they plan
> to mark the uncompressed pages volatile, and then be able to call into
> it. Ideally for them, the kernel would only purge cold pages, leaving
> the hot pages in memory. When they traverse a purged page, they handle
> the SIGBUS and patch the page up.

How big are these libraries compared to overall system size?

> Now.. this is not what I'd consider a normal use case, but was hoping to
> illustrate some of the more interesting uses and demonstrate the
> interfaces flexibility.

I'm just dying to hear a "normal" use case then. :)

> Also it provided a clear example of benefits to doing LRU based
> cold-page purging rather then full object purging. Though I think the
> same could be demonstrated in a simpler case of a large cache of objects
> that the applications wants to mark volatile in one pass, unmarking
> sub-objects as it needs.

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
