Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F3D6F6B005A
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 18:29:00 -0500 (EST)
Date: Fri, 13 Feb 2009 15:28:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Message-Id: <20090213152836.0fbbfa7d.akpm@linux-foundation.org>
In-Reply-To: <1234462282.30155.171.camel@nimitz>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: mingo@elte.hu, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Thu, 12 Feb 2009 10:11:22 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> 
> ...
>
> > - In bullet-point form, what features are missing, and should be added?
> 
>  * support for more architectures than i386
>  * file descriptors:
>   * sockets (network, AF_UNIX, etc...)
>   * devices files
>   * shmfs, hugetlbfs
>   * epoll
>   * unlinked files
>  * Filesystem state
>   * contents of files
>   * mount tree for individual processes
>  * flock
>  * threads and sessions
>  * CPU and NUMA affinity
>  * sys_remap_file_pages()
> 
> This is a very minimal list that is surely incomplete and sure to grow.

That's a worry.

> 
> > For extra marks:
> > 
> > - Will any of this involve non-trivial serialisation of kernel
> >   objects?  If so, that's getting into the
> >   unacceptably-expensive-to-maintain space, I suspect.
> 
> We have some structures that are certainly tied to the kernel-internal
> ones.  However, we are certainly *not* simply writing kernel structures
> to userspace.  We could do that with /dev/mem.  We are carefully pulling
> out the minimal bits of information from the kernel structures that we
> *need* to recreate the function of the structure at restart.  There is a
> maintenance burden here but, so far, that burden is almost entirely in
> checkpoint/*.c.  We intend to test this functionality thoroughly to
> ensure that we don't regress once we have integrated it.

I guess my question can be approximately simplified to: "will it end up
looking like openvz"?  (I don't believe that we know of any other way
of implementing this?)

Because if it does then that's a concern, because my assessment when I
looked at that code (a number of years ago) was that having code of
that nature in mainline would be pretty costly to us, and rather
unwelcome.

The broadest form of the question is "will we end up regretting having
done this".

If we can arrange for the implementation to sit quietly over in a
corner with a team of people maintaining it and not screwing up other
people's work then I guess we'd be OK - if it breaks then the breakage
is localised.



And it's not just a matter of "does the diffstat only affect a single
subdirectory".  We also should watch out for the imposition of new
rules which kernel code must follow.  "you can't do that, because we
can't serialise it", or something.

Similar to the way in which perfectly correct and normal kernel
sometimes has to be changed because it unexpectedly upsets the -rt
patch.

Do you expect that any restrictions of this type will be imposed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
