Subject: Re: [PATCH 6/6] Mlock: make mlock error return Posixly Correct
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <2f11576a0808201058u3b0e032atd73cd62730151147@mail.gmail.com>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
	 <20080819210545.27199.5276.sendpatchset@lts-notebook>
	 <20080820163559.12D9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1219249441.6075.14.camel@lts-notebook>
	 <2f11576a0808201058u3b0e032atd73cd62730151147@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 20 Aug 2008 15:04:52 -0400
Message-Id: <1219259092.6075.45.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-08-21 at 02:58 +0900, KOSAKI Motohiro wrote:
> >> mlock() need error code if vma permission failure happend.
> >> but mmap() (and remap_pages_range(), etc..) should ignore it.
> >>
> >> So, mlock_vma_pages_range() should ignore __mlock_vma_pages_range()'s error code.
> >
> > Well, I don't know whether we can trigger a vma permission failure
> > during mmap(MAP_LOCKED) or a remap within a VM_LOCKED vma, either of
> > which will end up calling mlock_vma_pages_range().  However, [after
> > rereading the man page] looks like we DO want to return any ENOMEM w/o
> > translating to EAGAIN.
> 
> Linus-tree implemetation does it?
> Can we make reproduce programs?

> So, I think implimentation compatibility is important than man pages
> because many person think imcompatibility is bug ;-)

Currently, the upstream kernel uses make_pages_present() and ignores the
return value.  However, the mmap(2) man page does say that it can return
ENOMEM for "no memory is available"--which is what get_user_pages() will
return in that situation and which I propose we pass on untranslated.

To make a reproducer, we'd need to call mmap() with MAP_LOCKED from a
program running on a system or in a mem control group with insufficient
available memory to satisfy the mapping.  [I think that's really the
only get_user_pages() error we should get back from
mlock_vma_pages_range().  We shouldn't get the 'EFAULT' as we're
mlocking know good vma addresses and we filter out VM_IO|VM_PFNMAP
vmas.]  If the system/container is close enough to its memory capacity
that mmap(MAP_LOCKED) is returning ENOMEM, the application probably has
other more important problems to deal with.

In any case, we'd only return an error when one occurs.  This might be
different from today's behavior which is to not tell the application
about the condition, even tho' it has occurred--e.g., insufficient
memory to satisfy MAP_LOCKED--but I think it's better for the
application to know about it than to pretend it didn't happen.  

So, I think we're OK, after I move the posix error return translation to
mlock_fixup().  [I'm testing the patch now.]

Lee
> 

> 
> > Guess that means I should do the translation
> > from within for mlock() from within mlock_fixup().  remap_pages_range()
> > probably wants to explicitly ignore any error from the mlock callout.
> >
> > Will resend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
