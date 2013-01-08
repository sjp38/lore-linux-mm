Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 82DB76B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 12:39:11 -0500 (EST)
Received: by mail-vb0-f50.google.com with SMTP id ft2so655115vbb.37
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 09:39:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130108173058.GA27727@shutemov.name>
References: <20130105152208.GA3386@redhat.com> <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
 <alpine.LNX.2.00.1301061037140.28950@eggly.anvils> <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
 <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
 <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
 <20130108163141.GA27555@shutemov.name> <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
 <20130108173058.GA27727@shutemov.name>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 8 Jan 2013 09:38:50 -0800
Message-ID: <CA+55aFyu6kjrZY6XyTGPcTpg2oTKN1BwCucLW6PWKzowpV=UOw@mail.gmail.com>
Subject: Re: oops in copy_page_rep()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On Tue, Jan 8, 2013 at 9:30 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> Check difference between patch above and merged one -- a1dd450.
> Merged patch is obviously broken: huge_pmd_set_accessed() can be called
> only if the pmd is under splitting.

Ok, that's a totally different issue, and seems to be due to different
versions (Andrew - any idea why

  http://lkml.org/lkml/2012/10/25/402

and commit a1dd450bcb1a ("mm: thp: set the accessed flag for old pages
on access fault") are different?

That said, I actually think that commit a1dd450bcb1a is correct:
huge_pmd_set_accessed() can not *possibly* need to check the splitting
issue, since it takes the page table lock and re-verifies that the pmd
entry is identical, before just setting the access flags.

So that whole thing is irrelevant. huge_pmd_set_accessed() almost
certainly simply doesn't care about splitting.

But look at commit d10e63f29488. That's the one that removes
pmd_trans_splitting() entirely, and does it for the case that *does*
seem to care, namely do_huge_pmd_wp_page().

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
