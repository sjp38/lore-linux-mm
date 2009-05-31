Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 05ECE6B0085
	for <linux-mm@kvack.org>; Sun, 31 May 2009 03:17:17 -0400 (EDT)
Received: by fxm12 with SMTP id 12so9534628fxm.38
        for <linux-mm@kvack.org>; Sun, 31 May 2009 00:17:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090530213311.GM6535@oblivion.subreption.com>
References: <20090530075033.GL29711@oblivion.subreption.com>
	 <20090530082048.GM29711@oblivion.subreption.com>
	 <20090530173428.GA20013@elte.hu>
	 <20090530180333.GH6535@oblivion.subreption.com>
	 <20090530182113.GA25237@elte.hu>
	 <20090530184534.GJ6535@oblivion.subreption.com>
	 <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com>
	 <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com>
	 <20090530213311.GM6535@oblivion.subreption.com>
Date: Sun, 31 May 2009 10:17:31 +0300
Message-ID: <84144f020905310017o3c2b8c52s7d62187cf794e854@mail.gmail.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, May 31, 2009 at 12:33 AM, Larry H. <research@subreption.com> wrote:
> While we are at it, did any of you (Pekka, Ingo, Peter) bother reading
> the very first paper I referenced in the very first patch?:
>
> http://www.stanford.edu/~blp/papers/shredding.html/#kernel-appendix
>
> Could you _please_ bother your highness with an earthly five minutes
> read of that paper? If you don't have other magnificent obligations to
> attend to. _Please_.
>
> PS: I'm still thanking myself for not implementing the kthread /
> multiple page pool based approach. Lord, what could have happened if I
> did.

Something like that might make sense for fast-path code.

I think we could make GFP_SENSITIVE mean that allocations using it
force the actual slab pages to be cleaned up before they're returned
to the page allocator. As far as I can tell, we could then recycle
those slab pages to GFP_SENSITIVE allocations without any clearing
whatsoever as long as they're managed by slab. This ensures critical
data in kmalloc()'d memory is never leaked to userspace.

This doesn't fix all the cases Alan pointed out (unconditional
memset() in page free is clearly superior from security pov) but
should allow us to use GFP_SENSITIVE in fast-path cases where the
overhead of kzfree() is unacceptable.

                                      Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
