Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EE8FA6B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 14:26:31 -0400 (EDT)
Date: Wed, 12 Aug 2009 19:26:21 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: vma_merge issue
In-Reply-To: <a1b36c3a0908101347t796dedbat2ecb0535c32f325b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0908121841550.14314@sister.anvils>
References: <a1b36c3a0908101347t796dedbat2ecb0535c32f325b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bill Speirs <bill.speirs@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Aug 2009, Bill Speirs wrote:
> 
> I came across an issue where adjacent pages are not properly coalesced
> together when changing protections on them. This can be shown by doing
> the following:
> 
> 1) Map 3 pages with PROT_NONE and MAP_PRIVATE | MAP_ANONYMOUS
> 2) Set the middle page's protection to PROT_READ | PROT_WRITE
> 3) Set the middle page's protection back to PROT_NONE
> 
> You are left with 3 entries in /proc/self/map where you should only
> have 1. If you only change the protection to PROT_READ in step 2, then
> it is properly merged together. I noticed in mprotect.c the following
> comment in the function mprotect_fixup; I'm not sure if it applies or
> not:
>         /*
>          * If we make a private mapping writable we increase our commit;
>          * but (without finer accounting) cannot reduce our commit if we
>          * make it unwritable again.
[ the following lines of the comment are not relevant here so I'll delete ]
>          */
> 
> I think this only applies to setting charged = nrpages; however,
> VM_ACCOUNT is also added to newflags. Could it be that the adjacent
> blocks don't have VM_ACCOUNT and so the call to vma_merge cannot merge
> because the flags for the adjacent vma are not the same?

That's right, and it is working as intended.

To allow people to set up enormous PROT_READ,MAP_PRIVATE mappings 
"for free", we don't account those initially, but only as parts
are mprotected writable later: at that point they're accounted,
and marked VM_ACCOUNT so that we know it's been done (and don't
double account later on).

So your middle page has been accounted (one page added to
/proc/meminfo's Committed_AS, which isn't allowed to exceed CommitLimit
if /proc/sys/vm/overcommit_memory is 2 to disable overcommit), but the
neighbouring pages have not been accounted: so we need separate vmas
for them, I'm afraid, since that accounting is done per vma.

> 
> Can anyone shed some light on this? While it isn't an issue for 3
> pages, I'm mmaping 200K+ pages and changing the perms on random pages
> throughout and then back but I quickly run into the max_map_count when
> I don't actually need that many mappings.

But that's easily dealt with: just make your mmap PROT_READ|PROT_WRITE,
which will account for the whole extent; then mprotect it all PROT_NONE,
which will take you to your previous starting position; then proceed as
before - the vmas should get merged as they are reset back to PROT_NONE.
That works, doesn't it?

(I must offer a big thank you: replying to your mail just after writing
a mail about the ZERO_PAGE, brings me to realize - if I'm not mistaken -
that we broke the accounting of initially non-writable anonymous areas
when we stopped using the ZERO_PAGE there, but marked readfaulted pages
as dirty.  Looks like another argument to bring them back.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
