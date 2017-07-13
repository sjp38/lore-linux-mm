Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6781F440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 14:12:25 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i71so76022473itf.2
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 11:12:25 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c187si19273ith.132.2017.07.13.11.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 11:12:24 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170711123642.GC11936@dhcp22.suse.cz>
 <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
 <20170712114655.GG28912@dhcp22.suse.cz>
 <3a2cfeae-520c-b6e5-2808-cf1bcf62b067@oracle.com>
 <20170713061651.GA14492@dhcp22.suse.cz>
 <21b264e7-b879-f072-03d2-f6f4aec5c957@oracle.com>
 <20170713163054.GK22628@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <28a8da13-bdc2-3f23-dee9-607377ac1cc3@oracle.com>
Date: Thu, 13 Jul 2017 11:11:37 -0700
MIME-Version: 1.0
In-Reply-To: <20170713163054.GK22628@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 07/13/2017 09:30 AM, Andrea Arcangeli wrote:
> On Thu, Jul 13, 2017 at 09:01:54AM -0700, Mike Kravetz wrote:
>> Sent a patch (in separate e-mail thread) to return EINVAL for private
>> mappings.
> 
> The way old_len == 0 behaves for MAP_PRIVATE seems more sane to me
> than the alternative of copying pagetables for anon pages (as behaving
> the way that way avoids to break anon pages invariants), despite it's
> not creating an exact mirror of what was in the original vma as it
> excludes any modification done to cowed anon pages.
> 
> By nullifying move_page_tables old_len == 0 is simply duping the vma
> which is equivalent to a new mmap on the file for the MAP_PRIVATE
> case, it has a deterministic result. The real question is if it
> anybody is using it.

As previously discussed, copying pagetables (via move_page_tables) does
not happen if old_len == 0.  This is true for both for private and shared
mappings.

Here is my understanding of how things work for old_len == 0 of anon
mappings:
- shared mappings
	- New vma is created at new virtual address
	- vma refers to the same underlying object/pages as old vma
	- after mremap, no page tables exist for new vma, they are
	  created as pages are accessed/faulted
	- page at new_address is same as page at old_address
- private mappings
	- New vma is created at new virtual address
	- vma does not refer to same pages as old vma.  It is a 'new'
	  private anon mapping.
	- after mremap, no page tables exist for new vma.  access to
	  the range of the new vma will result in faults that allocate
	  a new page.
	- page at new_address is different than  page at old_address
	  the new vma will result in new 

So, the result of mremap(old_len == 0) on a private mapping is that it
simply creates a new private mapping.  IMO, this is contrary to the purpose
of mremap.  mremap should return a mapping that is somehow related to
the original mapping.

Perhaps you are thinking about mremap of a private file mapping?  I was
not considering that case.  I believe you are right.  In this case a
private COW mapping based on the original mapping would be created.  So,
this seems more in line with the intent of mremap.  The new mapping is
still related to the old mapping.

With this in mind, what about returning EINVAL only for the anon private
mapping case?

However, if you have a fd (for a file mapping) then I can not see why
someone would be using the old_len == 0 trick.  It would be more straight
forward to simply use mmap to create the additional mapping.

> So an alternative would be to start by adding a WARN_ON_ONCE deprecation
> warning instead of -EINVAL right away.
> 
> The vma->vm_flags VM_ACCOUNT being wiped on the original vma as side
> effect of using the old_len == 0 trick looks like a bug, I guess it
> should get fixed if we intend to keep old_len and document it for the
> long term.

Others seem to think we should keep old_len == 0 and document.

> Overall I'm more concerned about the fact an allocation failure in
> do_munmap is unreported to userland and it will leave the old vma
> intact like old_len == 0 would do (unless I'm misreading something
> there). The VM_ACCOUNT wipe as side effect of old_len == 0 is not
> major short term concern.

I assume you are concerned about the do_munmap call in move_vma?  That
does indeed look to be of concern.  This happens AFTER setting up the
new mapping.  So, I'm thinking we should tear down the new mapping in
the case do_munmap of the old mapping fails?  That 'should' simply
be a matter of:
- moving page tables back to original mapping
- remove/delete new vma
- I don't think we need to 'unmap' the new vma as there should be no
  associated pages.

I'll look into doing this as well.

Just curious, do those userfaultfd callouts still work as desired in the
case of map duplication (old_len == 0)?
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
