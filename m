Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFB782F8A
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 17:53:46 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so19011495wic.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 14:53:45 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id hf9si43829540wjc.36.2015.10.19.14.53.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 14:53:45 -0700 (PDT)
Received: by wikq8 with SMTP id q8so19004930wik.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 14:53:44 -0700 (PDT)
Date: Tue, 20 Oct 2015 00:53:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
Message-ID: <20151019215342.GA18625@node.shutemov.name>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182148040.2481@eggly.anvils>
 <56248C5B.3040505@suse.cz>
 <alpine.LSU.2.11.1510190341490.3809@eggly.anvils>
 <20151019131308.GB15819@node.shutemov.name>
 <alpine.LSU.2.11.1510191218070.4652@eggly.anvils>
 <20151019201003.GA18106@node.shutemov.name>
 <56255FE4.5070609@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56255FE4.5070609@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Oct 19, 2015 at 11:25:56PM +0200, Vlastimil Babka wrote:
> >>>I think we need to have at lease WRITE_ONCE() everywhere we update
> >>>vm_flags and READ_ONCE() where we read it without mmap_sem taken.
> 
> It wouldn't hurt to check if seeing a stale value or using non-atomic RMW
> can be a problem somewhere. In this case it's testing, not changing, so RMW
> is not an issue. But the check shouldn't consider arbitrary changes made by
> a potentially crazy compiler.
> 
> >>Not a series I'll embark upon myself,
> >>and the patch at hand doesn't make things worse.
> >
> >I think it does.
> 
> So what's the alternative? Hm could we keep the trylock on mmap_sem under
> pte lock? The ordering is wrong, but it's a trylock, so no danger of
> deadlock?

This patch is okay for now as it fixes bug. I mean more real bug than it
introduces ;)

But situation with locking around ->vm_flags is getting worse. ->mmap_sem
doesn't serve it well.  We need to come up with something better.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
