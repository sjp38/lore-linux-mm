Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9E61790008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 13:43:53 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id i50so3484733qgf.29
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 10:43:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b10si13355610qaw.76.2014.10.30.10.43.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Oct 2014 10:43:52 -0700 (PDT)
Date: Thu, 30 Oct 2014 18:43:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/5] mm: gup: add __get_user_pages_unlocked to customize
 gup_flags
Message-ID: <20141030174309.GL19606@redhat.com>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-3-git-send-email-aarcange@redhat.com>
 <20141030121737.GB31134@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141030121737.GB31134@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Thu, Oct 30, 2014 at 02:17:37PM +0200, Kirill A. Shutemov wrote:
> On Wed, Oct 29, 2014 at 05:35:17PM +0100, Andrea Arcangeli wrote:
> > diff --git a/mm/gup.c b/mm/gup.c
> > index a8521f1..01534ff 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -591,9 +591,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
> >  						int write, int force,
> >  						struct page **pages,
> >  						struct vm_area_struct **vmas,
> > -						int *locked, bool notify_drop)
> > +						int *locked, bool notify_drop,
> > +						unsigned int flags)
> 
> Argument list getting too long. Should we consider packing them into a
> struct?

It's __always_inline, so it's certainly not a runtime concern. The
whole point of using __always_inline is to optimize away certain
branches at build time.

If this about cleaning it up and not for changing the runtime (which I
think couldn't get any better because of the __always_inline), we
should at least make certain gcc can still see through the structure
offsets to delete the same code blocks at build time if possible,
before doing the change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
