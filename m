Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 04FC26B0264
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 11:35:20 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n5so33329272pfn.2
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:35:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 24si4144088pfn.204.2016.03.15.08.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 08:35:19 -0700 (PDT)
Date: Tue, 15 Mar 2016 08:35:15 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Page migration issue with UBIFS
Message-ID: <20160315153515.GA28522@infradead.org>
References: <56E8192B.5030008@nod.at>
 <20160315151727.GA16462@node.shutemov.name>
 <56E8297E.80708@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E8297E.80708@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Kaplan <alex@nextthing.co>

On Tue, Mar 15, 2016 at 04:25:50PM +0100, Richard Weinberger wrote:
> Thanks for your quick response!
> 
> I also don't think that the root cause is CMA or migration but it seems
> to be the messenger.
> 
> Can you confirm that UBIFS's assumptions are valid?
> I'm trying to rule out possible issues and hunt down the root cause...

FYI, XFS would blow up unless either ->write_begin or ->page_mkwrite
were called before dirtying a page.  We do an assert that the page has
buffers as the first thing in writepage, and those are the only
two places that should create buffers.

So either no one is using CMA with XFS, or there is another weird
interaction involved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
