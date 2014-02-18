Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f181.google.com (mail-ve0-f181.google.com [209.85.128.181])
	by kanga.kvack.org (Postfix) with ESMTP id 694516B0036
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 13:02:27 -0500 (EST)
Received: by mail-ve0-f181.google.com with SMTP id cz12so13573676veb.26
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:02:27 -0800 (PST)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id y3si5705189vdo.97.2014.02.18.10.02.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 10:02:26 -0800 (PST)
Received: by mail-vc0-f178.google.com with SMTP id ik5so13189277vcb.23
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:02:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <100D68C7BA14664A8938383216E40DE04062DEA1@FMSMSX114.amr.corp.intel.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
	<CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
	<53035FE2.4080300@redhat.com>
	<100D68C7BA14664A8938383216E40DE04062DEA1@FMSMSX114.amr.corp.intel.com>
Date: Tue, 18 Feb 2014 10:02:26 -0800
Message-ID: <CA+55aFzqZ2S==NyWG67hNV1YsY-oXLjLvCR0JeiHGJOfnoGJBg@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 18, 2014 at 6:15 AM, Wilcox, Matthew R
<matthew.r.wilcox@intel.com> wrote:
> We don't really need to lock all the pages being returned to protect against truncate.  We only need to lock the one at the highest index, and check i_size while that lock is held since truncate_inode_pages_range() will block on any page that is locked.
>
> We're still vulnerable to holepunches, but there's no locking currently between holepunches and truncate, so we're no worse off now.

It's not "holepunches and truncate", it's "holepunches and page
mapping", and I do think we currently serialize the two - the whole
"check page->mapping still being non-NULL" before mapping it while
having the page locked does that.

Besides, that per-page locking should serialize against truncate too.
No, there is no "global" serialization, but there *is* exactly that
page-level serialization where both truncation and hole punching end
up making sure that the page no longer exists in the page cache and
isn't mapped.

I'm just claiming that *because* of the way rmap works for file
mappings (walking the i_mapped list and page tables), we should
actually be ok.  The anonymous rmap list is protected by the page
lock, but the file-backed rmap is protected by the pte lock (well, and
the "i_mmap_mutex" that in turn protects the i_mmap list etc).

       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
