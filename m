Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id D58F46B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 17:35:45 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id h15so3400648igd.13
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 14:35:45 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 82si3780520iod.52.2014.11.26.14.35.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Nov 2014 14:35:44 -0800 (PST)
Date: Wed, 26 Nov 2014 14:35:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm: prevent endless growth of anon_vma hierarchy
Message-Id: <20141126143543.63634293ba6e9136e689fe44@linux-foundation.org>
In-Reply-To: <20141126210559.GA12060@cosmos.ssec.wisc.edu>
References: <20141126191145.3089.90947.stgit@zurg>
	<20141126210559.GA12060@cosmos.ssec.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Forrest <dan.forrest@ssec.wisc.edu>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Tim Hartrick <tim@edgecast.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 26 Nov 2014 15:05:59 -0600 Daniel Forrest <dan.forrest@ssec.wisc.edu> wrote:

> On Wed, Nov 26, 2014 at 10:11:45PM +0400, Konstantin Khlebnikov wrote:
> 
> > Constantly forking task causes unlimited grow of anon_vma chain.
> > Each next child allocate new level of anon_vmas and links vmas to all
> > previous levels because it inherits pages from them. None of anon_vmas
> > cannot be freed because there might be pages which points to them.
> > 
> > This patch adds heuristic which decides to reuse existing anon_vma instead
> > of forking new one. It counts vmas and direct descendants for each anon_vma.
> > Anon_vma with degree lower than two will be reused at next fork.
> > 
> > As a result each anon_vma has either alive vma or at least two descendants,
> > endless chains are no longer possible and count of anon_vmas is no more than
> > two times more than count of vmas.
> 
> While I was working on the previous fix for this bug, Andrew Morton
> noticed that the error return from anon_vma_clone() was being dropped
> and replaced with -ENOMEM (which is not itself a bug because the only
> error return value from anon_vma_clone() is -ENOMEM).
> 
> I did an audit of callers of anon_vma_clone() and discovered an actual
> bug where the error return was being lost.  In __split_vma(), between
> Linux 3.11 and 3.12 the code was changed so the err variable is used
> before the call to anon_vma_clone() and the default initial value of
> -ENOMEM is overwritten.  So a failure of anon_vma_clone() will return
> success since err at this point is now zero.
> 
> Below is a patch which fixes this bug and also propagates the error
> return value from anon_vma_clone() in all cases.
> 
> I can send this as a separate patch, but maybe it would be easier if
> you were to incorporate it into yours?
> 

I grabbed it.  A bugfix is a bugfix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
