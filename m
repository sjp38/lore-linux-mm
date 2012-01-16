Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C154C6B009C
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 11:31:08 -0500 (EST)
Date: Mon, 16 Jan 2012 16:31:06 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
Message-ID: <20120116163106.GC7180@jl-vm1.vm.bytemark.co.uk>
References: <1326544511-6547-1-git-send-email-siddhesh.poyarekar@gmail.com>
 <20120116112802.GB7180@jl-vm1.vm.bytemark.co.uk>
 <CAAHN_R1u_btMuF+WhHu0G895EJ=mbOPNRp7NcXEgTKv3Vs-B1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAHN_R1u_btMuF+WhHu0G895EJ=mbOPNRp7NcXEgTKv3Vs-B1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

Siddhesh Poyarekar wrote:
> On Mon, Jan 16, 2012 at 4:58 PM, Jamie Lokier <jamie@shareable.org> wrote:
> > Is there a reason the names aren't consistent - i.e. not vma_is_stack_guard()?
> 
> Ah, that was an error on my part; I did not notice the naming convention.
> 
> > How about simply calling it vma_is_guard(), return 1 if it's PROT_NONE
> > without checking vma_is_stack() or ->vm_next/prev, and annotate the
> > maps output like this:
> >
> >   is_stack              => "[stack]"
> >   is_guard & is_stack   => "[stack guard]"
> >   is_guard & !is_stack  => "[guard]"
> >
> > What do you think?
> 
> Thanks for the review. We're already marking permissions in the maps
> output to convey protection, so isn't marking those vmas as [guard]
> redundant?

Yes it's redundant, I just think it's a bit clearer at showing the
intent.  After all that's also the reason for "[stack]", "[heap]" etc.
It's not important though.

> Following that, we could just mark the thread stack guard as [stack]
> without any permissions. The process stack guard page probably
> deserves the [stack guard] label since it is marked differently from
> the thread stack guard and will otherwise have the permissions that
> the process stack has. Will that be good?

I don't have any strong opinions about what the test looks like; mainly I
was pointing out the ->vm_next/prev check seemed dubious, that Glibc's
layout shouldn't be assumed, and that hiding ranges from /maps may
mislead some programs.

Aesthetically I think if the main process stack has "[stack guard]",
it makes sense for the thread stack guards to be labelled the same.

One more technical thing: Now that you're using VM_STACK to change the
text, why not set that flag for the process stack vma as well, when
the stack is set up by exec, and get rid of the special case for
process stack in printing?

All the best,
-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
