Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 653EA6B0068
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 00:08:12 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so6299888wib.2
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 21:08:11 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id la10si245023wjb.31.2014.04.01.21.08.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Apr 2014 21:08:09 -0700 (PDT)
Message-ID: <533B8CE6.8090401@zytor.com>
Date: Tue, 01 Apr 2014 21:07:02 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B8C2D.9010108@linaro.org>
In-Reply-To: <533B8C2D.9010108@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/01/2014 09:03 PM, John Stultz wrote:
> 
> So, maybe its best to ignore the fact that folks want to do semi-crazy
> user-space faulting via SIGBUS. At least to start with. Lets look at the
> semantic for the "normal" mark volatile, never touch the pages until you
> mark non-volatile - basically where accessing volatile pages is similar
> to a use-after-free bug.
> 
> So, for the most part, I'd say the proposed SIGBUS semantics don't
> complicate things for this basic use-case, at least when compared with
> things like zero-fill.  If an applications accidentally accessed a
> purged volatile page, I think SIGBUS is the right thing to do. They most
> likely immediately crash, but its better then them moving along with
> silent corruption because they're mucking with zero-filled pages.
> 
> So between zero-fill and SIGBUS, I think SIGBUS makes the most sense. If
> you have a third option you're thinking of, I'd of course be interested
> in hearing it.
> 

People already do SIGBUS for mmap, so there is nothing new here.

> Now... once you've chosen SIGBUS semantics, there will be folks who will
> try to exploit the fact that we get SIGBUS on purged page access (at
> least on the user-space side) and will try to access pages that are
> volatile until they are purged and try to then handle the SIGBUS to fix
> things up. Those folks exploiting that will have to be particularly
> careful not to pass volatile data to the kernel, and if they do they'll
> have to be smart enough to handle the EFAULT, etc. That's really all
> their problem, because they're being clever. :)

Yep.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
