Date: Tue, 10 Jun 2008 23:06:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 7/7] powerpc: lockless get_user_pages_fast
Message-Id: <20080610230622.abed7b55.akpm@linux-foundation.org>
In-Reply-To: <20080611044902.GB11545@wotan.suse.de>
References: <20080605094300.295184000@nick.local0.net>
	<20080605094826.128415000@nick.local0.net>
	<Pine.LNX.4.64.0806101159110.17798@schroedinger.engr.sgi.com>
	<20080611031822.GA8228@wotan.suse.de>
	<Pine.LNX.4.64.0806102138380.19967@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0806102141010.19967@schroedinger.engr.sgi.com>
	<20080611044902.GB11545@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 06:49:02 +0200 Nick Piggin <npiggin@suse.de> wrote:

> On Tue, Jun 10, 2008 at 09:41:33PM -0700, Christoph Lameter wrote:
> > And yes slab defrag is part of linux-next. So it would break.

No, slab defreg[*] isn't in linux-next.

y:/usr/src/25> diffstat patches/linux-next.patch| grep mm/slub.c
 mm/slub.c                                                    |    4 

That's two spelling fixes in comments.

I have git-pekka in -mm too.  Here it is:

--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2765,6 +2765,7 @@ void kfree(const void *x)
 
 	page = virt_to_head_page(x);
 	if (unlikely(!PageSlab(page))) {
+		BUG_ON(!PageCompound(page));
 		put_page(page);
 		return;
 	}


> Can memory management patches go though mm/? I dislike the cowboy
> method of merging things that some other subsystems have adopted :)

I think I'd prefer that.  I may be a bit slow, but we're shoving at
least 100 MM patches through each kernel release and I think I review
things more closely than others choose to.  At least, I find problems
and I've seen some pretty wild acked-bys...


[*] It _isn't_ "slab defrag".  Or at least, it wasn't last time I saw
it.  It's "slub defrag".  And IMO it is bad to be adding slub-only
features because afaik slub still isn't as fast as slab on some things
and so some people might want to run slab rather than slub.  And
because if this the decision whether to retain slab or slub STILL
hasn't been made.  Carrying both versions was supposed to be a
short-term transitional thing :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
