Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 789246B004A
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 18:07:54 -0400 (EDT)
Date: Sun, 18 Mar 2012 22:07:51 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [rfc][patches] fix for munmap/truncate races
Message-ID: <20120318220751.GD6589@ZenIV.linux.org.uk>
References: <20120318190744.GA6589@ZenIV.linux.org.uk>
 <CA+55aFwBEoD167oD=X9d6jR+wn6Tb-QFgZR+wGwdej4qakCMgg@mail.gmail.com>
 <20120318220610.GC6589@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120318220610.GC6589@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 18, 2012 at 10:06:10PM +0000, Al Viro wrote:
> On Sun, Mar 18, 2012 at 03:01:08PM -0700, Linus Torvalds wrote:
> > On Sun, Mar 18, 2012 at 12:07 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > > - ? ? ? tlb_finish_mmu(&tlb, 0, end);
> > > + ? ? ? tlb_finish_mmu(&tlb, 0, -1);
> > 
> > Hmm. The fact that you drop the end pointer means that some
> > architectures that optimize the TLB flushing for ranges now
> > effectively can't do it any more.
> > 
> > Now, I think it's only ia64 that really is affected, but it *might* matter.
> > 
> > In particular, ia64 has some logic for "if you only flush one single
> > region, you can optimize it", and the region sizes are in the
> > terabytes. And I'm pretty sure you broke that - I'm just not entirely
> > sure how much we care.
> 
> Nope - ia64 check explicitly for precisely that case:
[snip]
... and everything else doesn't look at start or end at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
