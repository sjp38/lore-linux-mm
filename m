Subject: Re: [patch 2/2] only allow nonlinear vmas for ram backed
	filesystems
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HZORc-0000UZ-00@dorka.pomaz.szeredi.hu>
References: <E1HZOHe-0000RL-00@dorka.pomaz.szeredi.hu>
	 <E1HZOIr-0000Rv-00@dorka.pomaz.szeredi.hu> <1175765760.6483.93.camel@twins>
	 <E1HZORc-0000UZ-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Thu, 05 Apr 2007 11:50:00 +0200
Message-Id: <1175766600.6483.100.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-05 at 11:39 +0200, Miklos Szeredi wrote:
> > > +		/*
> > > +		 * page_mkclean doesn't work on nonlinear vmas, so if dirty
> > > +		 * pages need to be accounted, emulate with linear vmas.
> > > +		 */
> > > +		if (mapping_cap_account_dirty(mapping)) {
> > 
> > Perhaps this should read:
> > 
> > 		if (vma_wants_writenotify(vma)) {
> > 
> 
> I looked at that, but IIRC vma_wants_writenotify() doesn't work after
> mmap(), because of the updated protection bits.

Right, bother, that again. I fudged it in mprotect by setting the pgprot
bits to what was expected although I had a parametrised version earlier.
But that was disliked.

> > That way we would even allow read only non-linear mappings of 'real'
> > filesystem files.
> 
> Well, we could do that, but is it really worth the hassle?  The real
> question is whether anyone would want to use non-linear
> shared-read-only mappings or not.

Hmm, yeah, I thought that was the case with that code snippet Andrew
pulled of the interweb, but on second inspection they do map it writable
too. I was led astray by the fact that they map the same file twice.

Oh well, lets just keep the patch as is then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
