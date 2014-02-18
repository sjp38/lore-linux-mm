Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 430F66B0035
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:07:10 -0500 (EST)
Received: by mail-ve0-f182.google.com with SMTP id jy13so14276858veb.27
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 11:07:09 -0800 (PST)
Received: from mail-ve0-x230.google.com (mail-ve0-x230.google.com [2607:f8b0:400c:c01::230])
        by mx.google.com with ESMTPS id t4si5763441vcz.133.2014.02.18.11.07.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 11:07:09 -0800 (PST)
Received: by mail-ve0-f176.google.com with SMTP id jx11so6516844veb.7
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 11:07:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140218185323.GB5744@linux.intel.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
	<53035FE2.4080300@redhat.com>
	<100D68C7BA14664A8938383216E40DE04062DEA1@FMSMSX114.amr.corp.intel.com>
	<CA+55aFzqZ2S==NyWG67hNV1YsY-oXLjLvCR0JeiHGJOfnoGJBg@mail.gmail.com>
	<20140218185323.GB5744@linux.intel.com>
Date: Tue, 18 Feb 2014 11:07:09 -0800
Message-ID: <CA+55aFySHoOkTUDVpWPxq9PZtwXKxhS=Wz757fM7oyQazfKpfw@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 18, 2014 at 10:53 AM, Matthew Wilcox <willy@linux.intel.com> wrote:
>
> Yes, I did mean "holepunches and page faults".  But here's the race I see:

Hmm. With truncate, we should be protected by i_size being changed
first (iirc - I didn't actually check), but I think you're right that
hole punching might race with a page being mapped at the same time.

> What I'm suggesting is going back to Kirill's earlier patch, but only
> locking the page with the highest index instead of all of the pages.
> truncate() will block on that page and then we'll notice that some or
> all of the other pages are also now past i_size and give up.

Actually, Kirill's latest patch seems to solve the problem with
locking - by simply never locking more than one page at a time. So I
guess it's all moot at least wrt the page preload..

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
