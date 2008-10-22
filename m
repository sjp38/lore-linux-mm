In-reply-to: <48FE6306.6020806@linux-foundation.org> (message from Christoph
	Lameter on Tue, 21 Oct 2008 18:17:26 -0500)
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org> <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> <48FC9CCC.3040006@linux-foundation.org> <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu> <48FCCC72.5020202@linux-foundation.org> <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu> <48FCD7CB.4060505@linux-foundation.org> <E1Ks0QX-0002aC-SQ@pomaz-ex.szeredi.hu> <48FCE1C4.20807@linux-foundation.org> <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu> <48FE6306.6020806@linux-foundation.org>
Message-Id: <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 22 Oct 2008 09:10:36 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cl@linux-foundation.org
Cc: miklos@szeredi.hu, penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008, Christoph Lameter wrote:
> The only way that a secure reference can be established is if the
> slab page is locked. That requires a spinlock. The slab allocator
> calls the get() functions while the slab lock guarantees object
> existence. Then locks are dropped and reclaim actions can start with
> the guarantee that the slab object will not suddenly vanish.

Yes, you've made up your mind, that you want to do it this way.  But
it's the _wrong_ way, this "want to get a secure reference for use
later" leads to madness when applied to dentries or inodes.  Try for a
minute to think outside this template.

For example dcache_lock will protect against dentries moving to/from
d_lru.  So you can do this:

  take dcache_lock
  check if d_lru is non-empty
  take sb->s_umount
  free dentry
  release sb->s_umount
  release dcache_lock

Yeah, locking will be more complicated in reality.  Still, much less
complicated than trying to do the same across two separate phases.

Why can't something like that work?

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
