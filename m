Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A16E86B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 19:40:47 -0400 (EDT)
Date: Fri, 22 May 2009 16:40:31 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090522234031.GH13971@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090522143914.2019dd47@lxorguk.ukuu.org.uk> <20090522180351.GC13971@oblivion.subreption.com> <20090522192158.28fe412e@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090522192158.28fe412e@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On 19:21 Fri 22 May     , Alan Cox wrote:
> Which patch are we talking about ? I'm all for a security option which
> clears *all* objects on freeing them (actually the poison debug is pretty
> close to this). That would fix these examples too.

Enabling SLAB poisoning by default will be a bad idea, let's stick to
zeroing these like I do in the current patch. I haven't figured out a
way to do the clearing in caches which don't have the SLAB_CONFIDENTIAL
flag when GFP_CONFIDENTIAL was used to allocate the object, and
sanitize_mem is disabled. That was the point of the page flag...

I looked for unused/re-usable flags too, but found none. It's
interesting to see SLUB and SLOB have their own page flags. Did anybody
oppose those when they were proposed? We should ask Lameter if he would
be keen on adding the confidential bit support there, or we will have to
figure out some other way to track the GFP_CONFIDENTIAL usage and clear
the data properly. We can't do that within SLAB/SLUB because they don't
store this information anywhere.

> Which could be another task stack you didn't clear - yes ?
> Including task stacks yes ? 
> And task stacks contain copies of important data yes ?

I haven't looked at the vma flag possibilities yet given the new
circumstances. But when we had the page flag, I was thinking about
making mlock() pages get automatically cleared upon release by setting
the bit on them. Just another example of a painless feature deriving
from the old patch.

Again a workaround must be found to do this without the page flag.

> Ditto - which is why I'm coming from the position of an "if we free it
> clear it" option. If you need that kind of security the cost should be
> more than acceptable - especially with modern processors that can do
> cache bypass on the clears.

Are you proposing that we should simply remove the confidential flags
and just stick to the unconditional sanitization when the boot option is
enabled? If positive, it will make things more simple and definitely is
better than nothing. I would have (still) preferred the other old
approach to be merged, but whatever works at this point.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
