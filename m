Subject: Re: [PATCH 6/6] Mlock: make mlock error return Posixly Correct
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1219259092.6075.45.camel@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
	 <20080819210545.27199.5276.sendpatchset@lts-notebook>
	 <20080820163559.12D9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1219249441.6075.14.camel@lts-notebook>
	 <2f11576a0808201058u3b0e032atd73cd62730151147@mail.gmail.com>
	 <1219259092.6075.45.camel@lts-notebook>
Content-Type: text/plain
Date: Fri, 22 Aug 2008 16:48:26 -0400
Message-Id: <1219438107.9576.38.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-08-20 at 15:04 -0400, Lee Schermerhorn wrote:
> On Thu, 2008-08-21 at 02:58 +0900, KOSAKI Motohiro wrote:
> > >> mlock() need error code if vma permission failure happend.
> > >> but mmap() (and remap_pages_range(), etc..) should ignore it.
> > >>
> > >> So, mlock_vma_pages_range() should ignore __mlock_vma_pages_range()'s error code.
> > >
> > > Well, I don't know whether we can trigger a vma permission failure
> > > during mmap(MAP_LOCKED) or a remap within a VM_LOCKED vma, either of
> > > which will end up calling mlock_vma_pages_range().  However, [after
> > > rereading the man page] looks like we DO want to return any ENOMEM w/o
> > > translating to EAGAIN.
> > 
> > Linus-tree implemetation does it?
> > Can we make reproduce programs?
> 
> > So, I think implimentation compatibility is important than man pages
> > because many person think imcompatibility is bug ;-)
> 
> Currently, the upstream kernel uses make_pages_present() and ignores the
> return value.  However, the mmap(2) man page does say that it can return
> ENOMEM for "no memory is available"--which is what get_user_pages() will
> return in that situation and which I propose we pass on untranslated.
> 
> To make a reproducer, we'd need to call mmap() with MAP_LOCKED from a
> program running on a system or in a mem control group with insufficient
> available memory to satisfy the mapping.  [I think that's really the
> only get_user_pages() error we should get back from
> mlock_vma_pages_range().  We shouldn't get the 'EFAULT' as we're
> mlocking know good vma addresses and we filter out VM_IO|VM_PFNMAP
> vmas.]  If the system/container is close enough to its memory capacity
> that mmap(MAP_LOCKED) is returning ENOMEM, the application probably has
> other more important problems to deal with.
> 
> In any case, we'd only return an error when one occurs.  This might be
> different from today's behavior which is to not tell the application
> about the condition, even tho' it has occurred--e.g., insufficient
> memory to satisfy MAP_LOCKED--but I think it's better for the
> application to know about it than to pretend it didn't happen.  
> 
> So, I think we're OK, after I move the posix error return translation to
> mlock_fixup().  [I'm testing the patch now.]
> 

After further examination of the code and thinking about separating
issues, I agree with you that we should hide any pte population error
[returned by get_user_pages()] from mmap() callers and just return the
address altho' the range may not be fully populated.  

I reread the Single Unix Specification mmap() page:

	http://www.opengroup.org/onlinepubs/007908799/xsh/mmap.html

It appears that, technically, we should be returning the error code when
we can't mlock the pages, at least in the case where mlockall() has
previously been called for the process--the MAP_LOCKED flag is not
defined in the standard.  Since the current upstream code doesn't do
this, it's not a regression nor otherwise directly related to the
unevictable mlocked pages patches, so I'd like to handle it as a
separate patch.  It will require backing out the already mmap()ed vma.

mlock_vma_pages_range() still returns the error in the case where the
vma goes away when it switches the mmap_sem back to write.  This should
be VERY unlikely, and I suppose we could return the virtual address of a
missing vma to the application and let it find out via SIGSEGV that the
address is invalid when it tries to access the memory.  I chose to
return the error.

I'm sending out the revised series shortly.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
