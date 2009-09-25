Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EB5756B009E
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:30:25 -0400 (EDT)
Message-ID: <4ABC7FBC.4050409@crca.org.au>
Date: Fri, 25 Sep 2009 18:30:52 +1000
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: No more bits in vm_area_struct's vm_flags.
References: <4AB9A0D6.1090004@crca.org.au> <Pine.LNX.4.64.0909232056020.3360@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909232056020.3360@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

Hugh Dickins wrote:
> On Wed, 23 Sep 2009, Nigel Cunningham wrote:
>> With the addition of the VM_MERGEABLE flag to vm_flags post-2.6.31, the
>> last bit in vm_flags has been used.
> 
> Yes, it was rather selfish to take that, without even pointing out
> that was the last of 32 bits in the changelog, and without mapping
> out where to go next - sorry.

Not at all! I'm only asking because I wasn't sure where to go next.

>> I have some code in TuxOnIce that needs a bit too (explicitly mark the
>> VMA as needing to be atomically copied, for GEM objects), and am not
> 
> (I wonder what atomically copied means there.)

Copied together, with interrupts disabled (to get as consistent an image
as possible). Swsusp and uswsusp atomically copy everything, and so
don't need this flag. TuxOnIce relies on the freezer to stop userspace
pages changing, and saves them separately in order to get a full image
of memory. The flag is needed because these pages would otherwise not be
included in the set of pages that are atomic copied.

>> sure what the canonical way to proceed is. Should a new unsigned long be
>> added? The difficulty I see with that is that my flag was used in
>> shmem_file_setup's flags parameter (drm_gem_object_alloc), so that
>> function would need an extra parameter too..
> 
> I've assumed that, when necessary, we'll retype vm_flags from
> unsigned long to unsigned long long (or u64).  But I've not yet
> checked how much bloat that would add to 32-bit code: whether we
> should put it off as long as we can, or be lazy and do it soon.
> 
> I'm thinking that we should use the full 32-bit vm_flags as a
> prompt to dispose of a few.  VM_RESERVED is the one I always claim
> I'm going to remove, then more important jobs intervene; and we seem
> to have grown more weird variants of VM_PFNMAP than I care for in
> the last year or two.  Suspect VM_PFN_AT_MMAP could make reasonable
> use of VM_NONLINEAR, but probably not without some small change.
> 
> Does TuxOnIce rely on CONFIG_MMU?  If so, then the TuxOnIce patch
> could presumably reuse VM_MAPPED_COPY for now - but don't be
> surprised if that's one we clean away later on.

Hmm. I'm not sure. The requirements are the same as for swsusp and
uswsusp. Is there some tool to graph config dependencies?

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
