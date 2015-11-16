Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7DB6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:32:45 -0500 (EST)
Received: by wmvv187 with SMTP id v187so166216660wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:32:44 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id ko8si10404221wjb.26.2015.11.16.01.32.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 01:32:43 -0800 (PST)
Received: by wmdw130 with SMTP id w130so102339737wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:32:43 -0800 (PST)
Date: Mon, 16 Nov 2015 11:32:41 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RESEND] ipc/shm: handle removed segments gracefully in
 shm_mmap()
Message-ID: <20151116093241.GB9778@node.shutemov.name>
References: <1447232220-36879-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151111170347.GA3502@linux-uzut.site>
 <20151111195023.GA17310@node.shutemov.name>
 <20151113053137.GB3502@linux-uzut.site>
 <20151113091259.GB28904@node.shutemov.name>
 <20151113192310.GC3502@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151113192310.GC3502@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>, Manfred Spraul <manfred@colorfullife.com>

On Fri, Nov 13, 2015 at 11:23:10AM -0800, Davidlohr Bueso wrote:
> On Fri, 13 Nov 2015, Kirill A. Shutemov wrote:
> 
> >On Thu, Nov 12, 2015 at 09:31:37PM -0800, Davidlohr Bueso wrote:
> >>On Wed, 11 Nov 2015, Kirill A. Shutemov wrote:
> >>>>>	ret = sfd->file->f_op->mmap(sfd->file, vma);
> >>>>>-	if (ret != 0)
> >>>>>+	if (ret) {
> >>>>>+		shm_close(vma);
> >>>>>		return ret;
> >>>>>+	}
> >>>>
> >>>>Hmm what's this shm_close() about?
> >>>
> >>>Undo shp->shm_nattch++ in successful __shm_open().
> >>
> >>Yeah that's just nasty.
> >
> >I don't see why: we successfully opened the segment, but f_op->mmap
> >failed -- let's close the segment. It's normal error path.
> 
> I was referring to the fact that I hate having to prematurely call shm_open()
> just for this case, and then have to backout, ie for nattach. Similarly, I
> dislike that you make shm_close behave one way and _shm_open another, looks
> hacky.
> 
> That said, I do agree that we should inform EIDRM back to the shm_mmap
> caller. My immediate thought would be to recheck right after shm_open returns.
> I realize this is also hacky as we run into similar inconsistencies that I
> mentioned above. But that's a caller (and the only one), not the whole
> shm_open/close. Also, just like we are concerned about EIDRM, should we also
> care about EINVAL -- where we race with explicit user shmctl(RMID) calls but
> we hold reference to nattach?? I mean, why bother doing mmap if the segment is
> marked for deletion and ipc won't touch it again anyway (failed idr lookups).
> The downside to that is the extra lookup overhead, so perhaps your approach
> is better. But looks like the right thing to do conceptually. Something like so?
> 
> shm_mmap()
> {
> 	err = shm_check_vma_validity()
> 	if (err)
> 
> 	->mmap()
> 
> 	shm_open()
> 	err = shm_check_vma_validity()
> 	if (err)
> 	   return err; /* shm_open was a nop, return the corresponding error */
> 
> 	return 0;
> }

The problem I have with this approach is that it assumes that there's
nothing to undo from ->mmap in case of shm_check_validity() failed in the
second call. That seems true at the moment, but I'm not sure if we can
assume this in general and if it's future-proof.

> So considering EINVAL, even your approach to bumping up nattach by calling
> _shm_open earlier isn't enough. Races exposed to user called rmid can still
> occur between dropping the lock and doing ->mmap().

Ugh.. I see. That's a problem.

Looks like a problem we solved for mm_struct by separation of mm_count
from mm_users. Should we have two counters instead of shm_nattch?

> Ultimately this leads to all ipc_valid_object() checks, as we totally
> ignore SHM_DEST segments nowadays since we forbid mapping previously
> removed segments.
> 
> I think this is the first thing we must decide before going forward with this
> mess. ipc currently defines invalid objects by merely checking the deleted flag.

To me all these flags mess should be replaced by proper refcounting.
Although, I admit, I don't understand SysV IPC API good enough to say for
sure if it's possible.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
