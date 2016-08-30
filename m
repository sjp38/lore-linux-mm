Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3C776B0038
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 18:39:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so70077150pfd.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 15:39:33 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id mu1si46997622pab.286.2016.08.30.15.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 15:39:32 -0700 (PDT)
Date: Tue, 30 Aug 2016 16:39:20 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH RFC 1/4] lib/radix: add universal radix_tree_fill_range
Message-ID: <20160830223920.GA7999@linux.intel.com>
References: <147230727479.9957.1087787722571077339.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <147230727479.9957.1087787722571077339.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sat, Aug 27, 2016 at 05:14:34PM +0300, Konstantin Khlebnikov wrote:
> Tags should be set only for last index of THP range: this way iterator
> will find them regardless of starting index.

I don't think this works well for DAX.  We really want to to have the tags be
consistent for all indices within a multi-order range.  Meaning, if I fault in
an order-9 fault, and then I get a PTE write fault to anywhere within that
range, I want to be able to do a lookup, find the one canonical entry that has
my dirty tags, flush, and eventually I want to be able to clear that one tag.

I agree that it's *possible* to do all of this with your code, but it puts a
lot of onus on the user.  I now have to have two paths, one for order-0
entries, and one for multi-order entries where I know to use a specific entry
as my canonical entry where I can count on the log bit, on tags, etc.

This was actually the way that it was done with the old PMD code.   We used
the first aligned index for the PMD to be the one source of truth.  On every
fault I would first check to see if there was a PMD aligned entry, and then if
not I would treat it like a normal 4k fault.  The multi-order radix tree with
sibling entries was a huge step forward.

I guess my question is the same as Matthew's: what is the problem you need to
solve with this code, and why can't the current code be made to solve it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
