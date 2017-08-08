Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id F40E86B0292
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 14:45:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u19so19291519qtc.14
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 11:45:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p2si1520370qke.406.2017.08.08.11.45.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 11:45:19 -0700 (PDT)
Message-ID: <1502217914.6577.32.camel@redhat.com>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Tue, 08 Aug 2017 14:45:14 -0400
In-Reply-To: <20170808165211.GE31390@bombadil.infradead.org>
References: <20170806140425.20937-1-riel@redhat.com>
	 <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
	 <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
	 <1502198148.6577.18.camel@redhat.com>
	 <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com>
	 <1502207168.6577.25.camel@redhat.com>
	 <20170808165211.GE31390@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Florian Weimer <fweimer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On Tue, 2017-08-08 at 09:52 -0700, Matthew Wilcox wrote:
> On Tue, Aug 08, 2017 at 11:46:08AM -0400, Rik van Riel wrote:
> > On Tue, 2017-08-08 at 08:19 -0700, Mike Kravetz wrote:
> > > If the use case is fairly specific, then perhaps it makes sense
> > > to
> > > make MADV_WIPEONFORK not applicable (EINVAL) for mappings where
> > > the
> > > result is 'questionable'.
> > 
> > That would be a question for Florian and Colm.
> > 
> > If they are OK with MADV_WIPEONFORK only working on
> > anonymous VMAs (no file mapping), that certainly could
> > be implemented.
> > 
> > On the other hand, I am not sure that introducing cases
> > where MADV_WIPEONFORK does not implement wipe-on-fork
> > semantics would reduce user confusion...
> 
> It'll simply do exactly what it does today, so it won't introduce any
> new fallback code.

Sure, but actually implementing MADV_WIPEONFORK in a
way that turns file mapped VMAs into zero page backed
anonymous VMAs after fork takes no more code than
implementing it in a way that refuses to work on VMAs
that have a file backing.

There is no complexity argument for or against either
approach.

The big question is, what is the best for users?

Should we return -EINVAL when MADV_WIPEONFORK is called
on a VMA that has a file backing, and only succeed on
anonymous VMAs?

Or, should we simply turn every memory range that has
MADV_WIPEONFORK done to it into an anonymous VMA in the
child process?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
