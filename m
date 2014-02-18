Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id EA7476B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 09:16:32 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so16733125pbb.7
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 06:16:32 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vw10si18506488pbc.77.2014.02.18.06.16.31
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 06:16:32 -0800 (PST)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [RFC, PATCHv2 0/2] mm: map few pages around fault address if
 they are in page cache
Date: Tue, 18 Feb 2014 14:15:59 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE04062DEA1@FMSMSX114.amr.corp.intel.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>,<53035FE2.4080300@redhat.com>
In-Reply-To: <53035FE2.4080300@redhat.com>
Content-Language: en-CA
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

We don't really need to lock all the pages being returned to protect agains=
t truncate.  We only need to lock the one at the highest index, and check i=
_size while that lock is held since truncate_inode_pages_range() will block=
 on any page that is locked.=0A=
=0A=
We're still vulnerable to holepunches, but there's no locking currently bet=
ween holepunches and truncate, so we're no worse off now.=0A=
________________________________________=0A=
From: Rik van Riel [riel@redhat.com]=0A=
Sent: February 18, 2014 5:28 AM=0A=
To: Linus Torvalds; Kirill A. Shutemov=0A=
Cc: Andrew Morton; Mel Gorman; Andi Kleen; Wilcox, Matthew R; Dave Hansen; =
Alexander Viro; Dave Chinner; linux-mm; linux-fsdevel; Linux Kernel Mailing=
 List=0A=
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if t=
hey are in page cache=0A=
=0A=
On 02/17/2014 02:01 PM, Linus Torvalds wrote:=0A=
=0A=
>  - increment the page _mapcount (iow, do "page_add_file_rmap()"=0A=
> early). This guarantees that any *subsequent* unmap activity on this=0A=
> page will walk the file mapping lists, and become serialized by the=0A=
> page table lock we hold.=0A=
>=0A=
>  - mb_after_atomic_inc() (this is generally free)=0A=
>=0A=
>  - test that the page is still unlocked and uptodate, and the page=0A=
> mapping still points to our page.=0A=
>=0A=
>  - if that is true, we're all good, we can use the page, otherwise we=0A=
> decrement the mapcount (page_remove_rmap()) and skip the page.=0A=
>=0A=
> Hmm? Doing something like this means that we would never lock the=0A=
> pages we prefault, and you can go back to your gang lookup rather than=0A=
> that "one page at a time". And the race case is basically never going=0A=
> to trigger.=0A=
>=0A=
> Comments?=0A=
=0A=
What would the direct io code do when it runs into a page with=0A=
elevated mapcount, but for which a mapping cannot be found yet?=0A=
=0A=
Looking at the code, it looks like the above scheme could cause=0A=
some trouble with invalidate_inode_pages2_range(), which has=0A=
the following sequence:=0A=
=0A=
                        if (page_mapped(page)) {=0A=
                                ... unmap page=0A=
                        }=0A=
                        BUG_ON(page_mapped(page));=0A=
=0A=
In other words, it looks like incrementing _mapcount first could=0A=
lead to an oops in the truncate and direct IO code.=0A=
=0A=
The page lock is used to prevent such races.=0A=
=0A=
*sigh*=0A=
=0A=
--=0A=
All rights reversed=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
