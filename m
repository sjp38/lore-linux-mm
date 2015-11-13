Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 86AEE6B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 04:13:02 -0500 (EST)
Received: by wmdw130 with SMTP id w130so20343199wmd.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:13:02 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id gd4si24601737wjb.2.2015.11.13.01.13.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 01:13:01 -0800 (PST)
Received: by wmdw130 with SMTP id w130so20342726wmd.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:13:01 -0800 (PST)
Date: Fri, 13 Nov 2015 11:12:59 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RESEND] ipc/shm: handle removed segments gracefully in
 shm_mmap()
Message-ID: <20151113091259.GB28904@node.shutemov.name>
References: <1447232220-36879-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151111170347.GA3502@linux-uzut.site>
 <20151111195023.GA17310@node.shutemov.name>
 <20151113053137.GB3502@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151113053137.GB3502@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>

On Thu, Nov 12, 2015 at 09:31:37PM -0800, Davidlohr Bueso wrote:
> On Wed, 11 Nov 2015, Kirill A. Shutemov wrote:
> >And I had concern about your approach:
> >
> >	If I read it correctly, with the patch we would ignore locking
> >	failure inside shm_open() and mmap will succeed in this case. So
> >	the idea is to have shm_close() no-op and therefore symmetrical.
> 
> Both open and close are no-ops in the case the segment has been removed,

The part I disagree is that shm_open() shouldn't be allowed for removed
segment. Basically, I prefer to keep the policy we have now.

> that's the symmetrical, and I'm not sure I follow -- we don't ignore locking
> failure in shm_open _at all_. Just like your approach, all I do is return if
> there's an error...

As you wrote in the comment, shm_check_vma_validity() check is racy. It's
just speculative check which doesn't guarantee that shm_lock() in
shm_open() will succeed. If this race happen, you just ignore this locking
failure and proceed. You compensate this, essentially failed shm_open(),
by no-op in shm_close().

In my opinion, failed shm_lock() in shm_open() should lead to returning
error from shm_mmap(). And there's no need in shm_close() hackery.
My patch tries to implement this.

> 
> >	That's look fragile to me. We would silently miss some other
> >	broken open/close pattern.
> 
> Such cases, if any, should be fixed and handled appropriately, not hide
> it under the rung, methinks.

But, don't you think you *do* hide such cases? With you patch pattern like
shm_open()-shm_close()-shm_close() will not trigger any visible effect.

> >>o My no-ops explicitly pair.
> >
> >As I said before, I don't think we should ignore locking error in
> >shm_open(). If we propagate the error back to caller shm_close() should
> >never happen, therefore no-op is unneeded in shm_close(): my patch trigger
> >WARN() there.
> 
> Yes, you WARN() in shm_close, but you still make it a no-op...

We can crash kernel with BUG_ON() there, but would it help anyone?
The WARN() is just to make broken open/close visible.

> >>>	ret = sfd->file->f_op->mmap(sfd->file, vma);
> >>>-	if (ret != 0)
> >>>+	if (ret) {
> >>>+		shm_close(vma);
> >>>		return ret;
> >>>+	}
> >>
> >>Hmm what's this shm_close() about?
> >
> >Undo shp->shm_nattch++ in successful __shm_open().
> 
> Yeah that's just nasty.

I don't see why: we successfully opened the segment, but f_op->mmap
failed -- let's close the segment. It's normal error path.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
