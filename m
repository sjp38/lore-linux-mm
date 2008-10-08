Date: Wed, 8 Oct 2008 11:11:12 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
Message-ID: <20081008091112.GK7971@one.firstfloor.org>
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name> <2f11576a0810070931k79eb72dfr838a96650563b93a@mail.gmail.com> <20081007211038.GQ20740@one.firstfloor.org> <20081008000518.13f48462@lxorguk.ukuu.org.uk> <20081007232059.GU20740@one.firstfloor.org> <20081008004030.7a0e9915@lxorguk.ukuu.org.uk> <20081007235737.GD7971@one.firstfloor.org> <20081008093424.4e88a3c2@lxorguk.ukuu.org.uk> <20081008084350.GI7971@one.firstfloor.org> <20081008095851.01790b6a@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081008095851.01790b6a@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 08, 2008 at 09:58:51AM +0100, Alan Cox wrote:
> > > 	shmat giving an address
> > > 	if error
> > > 		shmat giving no address
> > > 
> > > from user space.
> > 
> > No you can't here because shmat() starts searching from the wrong
> > start address.
> 
> If you are only hinting a desired address then that by the very meaning
> of the word "hint" means you will accept a different one.

The point is to be able to let the search start below the range
the kernel would normally start. It doesn't say that it has
to be at address X.

Yes hint is a little misleading, search hint is better.

> 
> > The only way would be to search manually in /proc/self/maps
> > and handle the races, but I hope you're not advocating that.
> 
> Gak, mmap a range to find a space and then shmat over the top of that.

That is racy when multi threaded because shmat() doesn't replace, so you 
would need to munmap() inbetween and someone else could steal the area
then. Yes you could stick a loop around it. It could livelock.
No, it's not a good interface I would advocate.

BTW the only alternative I would possiblye consider for the qemu case is to
force compat_shmat() to always allocate in 4GB (right now it relies
on the personality) and then let 64bit qemu use the int 0x80 entry point
for that.  But it's more hackish than the imho cleaner and more 
general flag.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
