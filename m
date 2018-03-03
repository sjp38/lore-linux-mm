Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3546B0003
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 11:57:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q65so5550279pga.15
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 08:57:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q29si4787795pfg.318.2018.03.03.08.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 03 Mar 2018 08:57:32 -0800 (PST)
Date: Sat, 3 Mar 2018 08:57:28 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 08/61] xarray: Add the xa_lock to the radix_tree_root
Message-ID: <20180303165727.GA29990@bombadil.infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
 <20180219194556.6575-9-willy@infradead.org>
 <1520088922.4280.47.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1520088922.4280.47.camel@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sat, Mar 03, 2018 at 09:55:22AM -0500, Jeff Layton wrote:
> On Mon, 2018-02-19 at 11:45 -0800, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > This results in no change in structure size on 64-bit x86 as it fits in
> > the padding between the gfp_t and the void *.
> > 
> 
> While the patch itself looks fine, we should take note that this will
> likely increase the size of radix_tree_root on 32-bit arches.
> 
> I don't think that's necessarily a deal breaker, but there are a lot of
> users of radix_tree_root. Many of those users have their own spinlock
> for radix tree accesses, and could be trivially changed to use the
> xa_lock. That would need to be done piecemeal though.
> 
> A less disruptive idea might be to just create some new struct that's a
> spinlock + radix_tree_root, and then use that going forward in the
> xarray conversion. That might be better anyway if you're considering a
> more phased approach for getting this merged.

Well, it's a choice.  If we do:

struct xarray {
	spinlock_t xa_lock;
	struct radix_tree_root root;
};

then the padding on 64-bit turns that into a 24-byte struct.  So do we
spend the extra 4 bytes on 32-bit and have the struct the way we want it
to look from the beginning, or do we spend the extra 8 bytes on 64-bit
and have to redo the struct accessors after the conversions are complete?
I chose option (a), but reasonable people can disagree on that choice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
