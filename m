Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id ECDD86B006E
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:25:58 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so163251045pab.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 19:25:58 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id hf1si8206790pbc.134.2015.03.22.19.25.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 19:25:58 -0700 (PDT)
Received: by pdbop1 with SMTP id op1so172158118pdb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 19:25:57 -0700 (PDT)
Date: Sun, 22 Mar 2015 19:25:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 00/24] huge tmpfs: an alternative approach to
 THPageCache
In-Reply-To: <20150223134810.GB7322@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1503221811250.4290@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils> <20150223134810.GB7322@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 23 Feb 2015, Kirill A. Shutemov wrote:
> 
> I scanned through the patches to get general idea on how it works.

Thanks!

> I'm not
> sure that I will have time and will power to do proper code-digging before
> the summit. I found few bugs in my patchset which I want to troubleshoot
> first.

Yes, I agree that should take priority.

> 
> One thing I'm not really comfortable with is introducing yet another way
> to couple pages together. It's less risky in short term than my approach
> -- fewer existing codepaths affected, but it rises maintaining cost later.
> Not sure it's what we want.

Yes, I appreciate your reluctance to add another way of achieving the
same thing.  I still believe that compound pages were a wrong direction
for THP; but until I've posted an implementation of anon THP my way,
and you've posted an implementation of huge tmpfs your way, it's going
to be hard to compare the advantages and disadvantages of each, to
decide between them.

And (as we said at LSF/MM) we each have a priority to attend to before
that: I need to support page migration, and recovery of hugeness after
swap; and you your bugfixes.  (The only bug I've noticed in mine since
posting, a consequence of developing on an earlier release then not
reauditing pmd_trans, is that I need to relax your VM_BUG_ON_VMA in
mm/mremap.c move_page_tables().)

For now, huge tmpfs is giving us useful "transparent hugetlbfs"
functionality, and we're happy to continue developing it that way;
but can switch it over to compound pages, if they win the argument
without sacrificing too much.

> 
> After Johannes' work which added exceptional entries to normal page cache
> I hoped to see shmem/tmpfs implementation moving toward generic page
> cache. But this patchset is step in other direction -- it makes
> shmem/tmpfs even more special-cased. :(

Well, Johannes's use for the exceptional entries was rather different
from tmpfs's.  I think tmpfs will always be a special case, and one
especially entitled to huge pages, and that does not distress me at
all - though I wasn't deaf to Chris Mason asking for huge pages too.

(I do wonder if Boaz and persistent memory and the dynamic 4k struct
pages discussion will overtake and re-inform both of our designs.)

> 
> Do you have any insights on how this approach applies to real filesystems?
> I don't think there's any show stopper, but better to ask early ;)

The not-quite-a-show-stopper is my use of page->private, as Konstantin
observes in other mail: I'll muse on that a little in replying to him.

Aside from the page->private issue, the changes outside of shmem.c
should be easily applicable to other filesystems, and some of them
perhaps already useful to you.

But frankly I've given next to no thought as to how easily the code
added in shmem.c could be moved out and used for others: tmpfs was
where we wanted it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
