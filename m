Date: Mon, 1 Aug 2005 12:15:47 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
Message-ID: <20050801101547.GA5016@elte.hu>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com> <42EDDB82.1040900@yahoo.com.au> <20050801091956.GA3950@elte.hu> <42EDEAFE.1090600@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42EDEAFE.1090600@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Ingo Molnar wrote:
> >* Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> >>Feedback please, anyone.
> >
> >
> >it looks good to me, but wouldnt it be simpler (in terms of patch and 
> >architecture impact) to always retry the follow_page() in 
> >get_user_pages(), in case of a minor fault? The sequence of minor faults 
> 
> I believe this can break some things. Hugh posted an example in his 
> recent post to linux-mm (ptrace setting a breakpoint in read-only 
> text). I think?

Hugh's posting said:

 "it's trying to avoid an endless loop of finding the pte not writable 
  when ptrace is modifying a page which the user is currently protected 
  against writing to (setting a breakpoint in readonly text, perhaps?)"

i'm wondering, why should that case generate an infinite fault? The 
first write access should copy the shared-library page into a private 
page and map it into the task's MM, writable. If this make-writable 
operation races with a read access then we return a minor fault and the 
page is still readonly, but retrying the write should then break up the 
COW protection and generate a writable page, and a subsequent 
follow_page() success. If the page cannot be made writable, shouldnt the 
vma flags reflect this fact by not having the VM_MAYWRITE flag, and 
hence get_user_pages() should have returned with -EFAULT earlier?

in other words, can a named MAP_PRIVATE vma with VM_MAYWRITE set ever be 
non-COW-break-able and thus have the potential to induce an infinite 
loop?

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
