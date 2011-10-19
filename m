Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id BD9A36B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 20:59:59 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p9J0xvWA008270
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:59:57 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by wpaz33.hot.corp.google.com with ESMTP id p9J0saoT022221
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:59:55 -0700
Received: by pzk1 with SMTP id 1so3988469pzk.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2011 17:59:55 -0700 (PDT)
Date: Tue, 18 Oct 2011 17:59:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: munlock use mapcount to avoid terrible overhead
In-Reply-To: <m262jlzv1v.fsf@firstfloor.org>
Message-ID: <alpine.LSU.2.00.1110181757080.4283@sister.anvils>
References: <alpine.LSU.2.00.1110181700400.3361@sister.anvils> <m262jlzv1v.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Oct 2011, Andi Kleen wrote:
> Hugh Dickins <hughd@google.com> writes:
> 
> > A process spent 30 minutes exiting, just munlocking the pages of a large
> > anonymous area that had been alternately mprotected into page-sized vmas:
> > for every single page there's an anon_vma walk through all the other
> > little vmas to find the right one.
> 
> We had the same problem recently after a mmap+touch workload: in this
> case it was hugepaged walking all these anon_vmas and the list was over
> 100k long. 
> 
> Had some data on this at plumbers:
> http://halobates.de/plumbers-fork-locks_v2.pdf
> 
> > A general fix to that would be a lot more complicated (use prio_tree on
> > anon_vma?), but there's one very simple thing we can do to speed up the
> > common case: if a page to be munlocked is mapped only once, then it is
> > our vma that it is mapped into, and there's no need whatever to walk
> > through all the others.
> 
> I think we need a generic fix, this problem does not only happen
> in munmap. 

Thanks for the pointer, Andi, I'll have to look into it when I've a
moment; but I don't look forward to making this area more complicated.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
