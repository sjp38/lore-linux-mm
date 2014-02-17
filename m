Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1626B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 15:24:05 -0500 (EST)
Received: by mail-vc0-f175.google.com with SMTP id ij19so12114446vcb.20
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 12:24:04 -0800 (PST)
Received: from mail-ve0-x232.google.com (mail-ve0-x232.google.com [2607:f8b0:400c:c01::232])
        by mx.google.com with ESMTPS id io9si4751935vcb.62.2014.02.17.12.24.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Feb 2014 12:24:04 -0800 (PST)
Received: by mail-ve0-f178.google.com with SMTP id oy12so12539199veb.37
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 12:24:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140217194955.GA30908@node.dhcp.inet.fi>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
	<20140217194955.GA30908@node.dhcp.inet.fi>
Date: Mon, 17 Feb 2014 12:24:04 -0800
Message-ID: <CA+55aFwSDxzvR=zWn=OtNmg5cYKaj8DzFTm+16xiHLKKR0xhWQ@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Feb 17, 2014 at 11:49 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> But it could be safer to keep locking in place and reduce lookup cost by
> exposing something like ->fault_iter_init() and ->fault_iter_next(). It
> will still return one page a time, but it will keep radix-tree context
> around for cheaper next-page lookup.

I really would prefer for the loop to be much smaller than that, and
not contain indirect calls to helpers that pretty much guarantee that
you can't generate nice code.

Plus I'd rather not have the mm layer know too much about the radix
tree iterations anyway, and try to use the existing page array
functions we already have (ie "find_get_pages()").

So I'd really prefer if we can do this with tight loops over explicit
pages, rather than some loop over an iterator.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
