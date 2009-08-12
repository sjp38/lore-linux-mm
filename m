Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 174AC6B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 03:46:12 -0400 (EDT)
Date: Wed, 12 Aug 2009 09:46:11 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration aware file systems
Message-ID: <20090812074611.GC28848@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <4A7FBFD1.2010208@hitachi.com> <20090810074421.GA6838@basil.fritz.box> <4A80EAA3.7040107@hitachi.com> <20090811071756.GC14368@basil.fritz.box> <4A822DD4.1050202@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A822DD4.1050202@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 12, 2009 at 11:49:56AM +0900, Hidehiro Kawai wrote:
> > I don't think there's much we can do if the application doesn't
> > check for IO errors properly. What would you do if it doesn't
> > check for IO errors at all? If it checks for IO errors it simply
> > has to check for them on all IO operations -- if they do 
> > they will detect hwpoison errors correctly too.
> 
> I believe it's not uncommon for applications to do buffered write
> and then exit without fsync().  And I think it's difficult to
> preclude such applications and commands from the system perfectly.

That's true, but for anything mission critical you would expect them
to use some transactional mechanism, either with O_SYNC or fsync().
Otherwise they always risk data loss anyways.

> > It's unclear to me this special mode is really desirable.
> > Does it bring enough value to the user to justify the complexity
> > of another exotic option?  The case is relatively exotic,
> > as in dirty write cache that is mapped to a file.
> > 
> > Try to explain it in documentation and you see how ridiculous it sounds; u
> > it simply doesn't have clean semantics
> > 
> > ("In case you have applications with broken error IO handling on
> > your mission critical system ...") 
> 
> Generally, dropping unwritten dirty page caches is considered to be
> risky.  So the "panic on IO error" policy has been used as usual
> practice for some systems.  I just suggested that we adopted
> this policy into machine check errors. 

Hmm, what we could possibly do -- as followon patches -- would be to
let error_remove_page check the per file system panic-on-io-error
super block setting for dirty pages and panic in this case too.  
Unfortunately this setting is currently per file system, not generic,
so it would need to be a fs specific check (or the flag would need
to be moved into a generic fs superblock field first)

I think that would be relatively clean semantics wise. Would you be 
interested in working on patches for that? 

> Another option is to introduce "ignore all" policy instead of
> panicking at the beginig of memory_failure().  Perhaps it finally
> causes SRAR machine check, and then kernel will panic or a process
> will be killed.  Anyway, this is a topic for the next stage.

The problem is memory_failure() would then need to start distingushing
between AR=1 and AR=0 which it doesn't today.

It could be done, but would need some more work. 

> > If you want to have improved IO error handling feel free to
> > submit it separately. I agree this area could use some work.
> > But it probably needs more design work first.
> 
> Well, this patch set itself looks good to me.
> I also looked into the other patches, I couldn't find any
> problems (although I'm not good judge of reviewing).
> 
> Reviewed-by: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>

Thanks for your review and your comments.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
