Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD68C6B028B
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:46:07 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x10so4418087pgx.12
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:46:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k4si10789942pls.297.2017.12.19.04.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 04:46:06 -0800 (PST)
Date: Tue, 19 Dec 2017 04:46:05 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 5/8] mm: Introduce _slub_counter_t
Message-ID: <20171219124605.GA13680@bombadil.infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-6-willy@infradead.org>
 <20171219080731.GB2787@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219080731.GB2787@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 09:07:31AM +0100, Michal Hocko wrote:
> On Sat 16-12-17 08:44:22, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Instead of putting the ifdef in the middle of the definition of struct
> > page, pull it forward to the rest of the ifdeffery around the SLUB
> > cmpxchg_double optimisation.
> > 
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The definition of struct page looks better now. I think that slub.c
> needs some love as well. I haven't checked too deeply but it seems that
> it assumes counters to be unsigned long in some places. Maybe I've
> missed some ifdef-ery but using the native type would be much better

I may have missed something, but I checked its use of 'counters' while
I was working on this patch, and I didn't *see* a problem.  The only
problem I really see is that it uses a bitfield for { inuse, objects,
frozen } and if the architecture has big-endian bitfields, it's possible
that slub's counters might end up conflicting with the special values we
use for PageBuddy, PageKmemcg and PageBalloon.  I always get confused
by big endian, so I can't even figure out how likely it is ... would
'frozen' end up as bit 31?  And if so, would _mapcount have its sign
bit at bit 31, or at bit 7?

> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
