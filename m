Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A681D6B0033
	for <linux-mm@kvack.org>; Tue, 26 Dec 2017 22:05:40 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f8so21912598pgs.9
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 19:05:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y15si23875675pfe.78.2017.12.26.19.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Dec 2017 19:05:39 -0800 (PST)
Date: Tue, 26 Dec 2017 19:05:34 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 05/78] xarray: Replace exceptional entries
Message-ID: <20171227030534.GA24828@bombadil.infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
 <20171215220450.7899-6-willy@infradead.org>
 <20171226171542.v25xieedd46y5peu@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171226171542.v25xieedd46y5peu@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

On Tue, Dec 26, 2017 at 08:15:42PM +0300, Kirill A. Shutemov wrote:
> >  28 files changed, 249 insertions(+), 240 deletions(-)
> 
> Everything looks fine to me after quick scan, but hat's a lot of changes for
> one patch...

Yeah.  It's pretty mechanical though.

> > -			if (radix_tree_exceptional_entry(page)) {
> > +			if (xa_is_value(page)) {
> >  				if (!invalidate_exceptional_entry2(mapping,
> >  								   index, page))
> >  					ret = -EBUSY;
> 
> invalidate_exceptional_entry? Are we going to leave the terminology here as is?

That is a great question.  If the page cache wants to call its value
entries exceptional entries, it can continue to do that.  I think there's
a better name for them, but I'm not sure what it is.  Right now, the
page cache uses value entries to store:

1. Shadow entries (for workingset)
2. Swap entries (for shmem)
3. DAX entries

I can't come up with a good name for these three things.  'nonpage' is
the only thing which hasn't immediately fallen off my ideas list.  But
I think renaming exceptional entries in the page cache is a great idea,
and I don't want to do it as part of this patch set ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
