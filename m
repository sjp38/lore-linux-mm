Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E52B96B004D
	for <linux-mm@kvack.org>; Sat, 23 May 2009 08:49:05 -0400 (EDT)
Date: Sat, 23 May 2009 14:49:44 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090523124944.GA23042@elte.hu>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090522113809.GB13971@oblivion.subreption.com>
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>


* Larry H. <research@subreption.com> wrote:

> NOTE: Let's keep the PaX Team on CC from now on, they might have further
> input to this discussion. (pageexec at freemail dot hu)
> 
> On 09:34 Fri 22 May     , Ingo Molnar wrote:
> > The whole kernel contains data that 'should not be leaked'.
> > _If_ any of this is done, i'd _very_ strongly suggest to describe it 
> > by what it does, not by what its subjective security attribute is.
> > 
> > 'PG_eyes_only' or 'PG_eagle_azf_compartmented' is silly naming. It 
> > is silly because it hardcodes one particular expectation/model of 
> > 'security'.
> > 
> > GFP_NON_PERSISTENT & PG_non_persistent is a _lot_ better, because it 
> > is a technical description of how information spreads. (which is the 
> > underlying principle of every security model)
> >
> > That name alone tells us everyting what this does: it does not 
> > allow this data to reach or touch persistent storage. It wont be 
> > swapped and it wont by saved by hibernation. It will also be 
> > cleared when freed, to achieve its goal of never touching 
> > persistent storage.
> 
> The problem is that these patches have a more broad purpose and I 
> never mentioned persistent storage as one of them (initially). 
> Check earlier messages to see what has been discussed so far.

You need to address my specific concerns instead of referring back 
to an earlier discussion. The patches touch code i maintain and i 
find them (and your latest resend) unacceptable.

> Regarding the naming changes, those have been done as of Rik's 
> comments and I would rather focus on the technical and 
> implementation side now.

Naming _is_ a technical issue. Especially here.

> > In-kernel crypto key storage using GFP_NON_PERSISTENT makes some 
> > sense - as long as the kernel stack itself is mared 
> > GFP_NON_PERSISTENT as well ... which is quite hairy from a 
> > performance point of view: we _dont_ want to clear the full 
> > stack page for every kernel thread exiting.
> 
> Burning the stack there is beyond overkill.

What you are missing is that your patch makes _no technical sense_ 
if you allow the same information to leak over the kernel stack. 
Kernel stacks can be freed and reused, swapped out and thus 
'exposed'.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
