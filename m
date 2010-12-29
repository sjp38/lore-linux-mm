Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4844F6B009E
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 15:54:42 -0500 (EST)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id oBTKsc0W008797
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 12:54:38 -0800
Received: from iwn2 (iwn2.prod.google.com [10.241.68.66])
	by hpaq7.eem.corp.google.com with ESMTP id oBTKsT5g027330
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 12:54:37 -0800
Received: by iwn2 with SMTP id 2so12289000iwn.2
        for <linux-mm@kvack.org>; Wed, 29 Dec 2010 12:54:29 -0800 (PST)
Date: Wed, 29 Dec 2010 12:54:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
In-Reply-To: <alpine.LSU.2.00.1011300939520.6633@tigran.mtv.corp.google.com>
Message-ID: <alpine.LSU.2.00.1012291231540.22566@sister.anvils>
References: <AANLkTinbqG7sXxf82wc516snLoae1DtCWjo+VtsPx2P3@mail.gmail.com> <20101122154754.e022d935.akpm@linux-foundation.org> <AANLkTi=AiJ1MekBXZbVj3f2pBtFe52BtCxtbRq=u-YOR@mail.gmail.com> <20101129152500.000c380b.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1011300939520.6633@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: robert@swiecki.net
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, Hugh Dickins wrote:
> On Mon, 29 Nov 2010, Andrew Morton wrote:
> > On Tue, 23 Nov 2010 15:55:31 +0100
> > Robert  wi cki <robert@swiecki.net> wrote:
> > > >> [25142.286531] kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
> > > >
> > > > That's
> > > >
> > > >        BUG_ON(page_mapped(page));
> > > >
> > > > in  remove_from_page_cache().  That state is worth a BUG().
> > 
> > At a guess I'd say that another thread came in and established a
> > mapping against a page in the to-be-truncated range while
> > vmtruncate_range() was working on it.  In fact I'd be suspecting that
> > the mapping was established after truncate_inode_page() ran its
> > page_mapped() test.
> 
> It looks that way, but I don't see how it can be: the page is locked
> before calling truncate_inode_page() and unlocked after it: and the
> page (certainly in this tmpfs case, perhaps not for every filesystem)
> cannot be faulted into an address space without holding its page lock.
> 
> Either we've made a change somewhere, and are now dropping and retaking
> page lock in a way which exposes this bug?  Or truncate_inode_page()'s
> unmap_mapping_range() call is somehow missing the page it's called for?
> 
> I guess the latter is the more likely: maybe the truncate_count/restart
> logic isn't working properly.  I'll try to check over that again later -
> but will be happy if someone else beats me to it.

I have since found an omission in the restart_addr logic: looking back
at the October 2004 history of vm_truncate_count, I see that originally
I designed it to work one way, but hurriedly added a 7/6 redesign when
vma splitting turned out to leave an ambiguity.  I should have updated
the protection in mremap move at that time, but missed it.

Robert, please try out the patch below (should apply fine to 2.6.35):
I'm hoping this will fix what the fuzzer found, but it's still quite
possible that it found something else wrong that I've not yet noticed.
The patch could probably be cleverer (if we exported the notion of
restart_addr out of mm/memory.c), but I'm more in the mood for being
safe than clever at the moment.

I didn't hear whether you'd managed to try out Miklos's patch; but
this one is a better bet to be the fix for your particular issue.

Thanks,
Hugh

--- 2.6.37-rc8/mm/mremap.c	2010-11-01 13:01:32.000000000 -0700
+++ linux/mm/mremap.c	2010-12-29 12:25:46.000000000 -0800
@@ -91,9 +91,7 @@ static void move_ptes(struct vm_area_str
 		 */
 		mapping = vma->vm_file->f_mapping;
 		spin_lock(&mapping->i_mmap_lock);
-		if (new_vma->vm_truncate_count &&
-		    new_vma->vm_truncate_count != vma->vm_truncate_count)
-			new_vma->vm_truncate_count = 0;
+		new_vma->vm_truncate_count = 0;
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
