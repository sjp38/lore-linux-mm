Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17D266B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 07:42:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t188so16149821pfd.20
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 04:42:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si3972646pli.234.2017.10.23.04.42.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 04:42:14 -0700 (PDT)
Date: Mon, 23 Oct 2017 13:42:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
Message-ID: <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Fri 20-10-17 15:42:25, Mike Kravetz wrote:
> On 10/19/2017 12:34 AM, C.Wehrmeyer wrote:
[...]
> > As for the specific use case: I've written my own allocator that is
> > not bound on the same limitations that usual malloc/realloc/free
> > allocators are bound. As such I want to be able to eliminate as many
> > page walks as possible.
> >
> > Just excepting the limitation would put Linux down on the same level
> > as the Windows API, where no VirtualRealloc exists. My allocator
> > needs to work with Linux and Windows; for the latter one I'm already
> > managing a table of consecutive mappings in user-space that, if
> > a relocation has to be made, creates an entirely new mapping
> > into which the data of the previous mappings is copied. This is
> > redundant, because the kernel and the process keep their own copies
> > of the mapping table, and this is slow because the kernel could just
> > re-adjust the position within the address space, whereas the process
> > has to memcpy all the data from the old to the new mappings.
> >
> > Those are the very problems mremap was supposed to remove in the
> > first place. Making the limitation documented is the lazy way that
> > will force implementers to workaround it.
> 
> mremap has never supported moving or growing hugetlb mappings.  Someone
> (before git history) added this explicit check to the mremap code.  Perhaps
> it was done when huge page support was introduced?

yes, that is the case.
 
> I am of the opinion that we should simply document this limitation.  AFAIK,
> this this the first time anyone has asked about it in 15 years.  What is the
> opinion of others?

I do not remember any such a request either. I can see some merit in the
described use case. It is not specific on why hugetlb pages are used for
the allocator memory because that comes with it own issues. If somebody
is really thrilled enough to implement this the remapping feature for
hugetlb I wouldn't be opposed as long as the implementation is clean and
wouldn't add an additional mess to the code base. I suspect that the vma
enlarging might be a hard deal. Anyway starting with a documentation
update sounds like a good thing anyway. In any case such a feature will
be available only for new kernels so people should be aware of the state
on older kernels.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
