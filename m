Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0986B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:21:41 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id i57so10665171yha.12
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:21:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n124si9696969ykf.69.2015.01.12.12.21.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 12:21:40 -0800 (PST)
Date: Mon, 12 Jan 2015 12:21:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix corner case in anon_vma endless growing
 prevention
Message-Id: <20150112122138.f173c6279af0b49565e956d3@linux-foundation.org>
In-Reply-To: <20150111135406.13266.42007.stgit@zurg>
References: <20150111135406.13266.42007.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Elifaz, Dana" <Dana.Elifaz@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Chris Clayton <chris2553@googlemail.com>, Oded Gabbay <oded.gabbay@amd.com>, Michal Hocko <mhocko@suse.cz>, Greg KH <gregkh@suse.de>

On Sun, 11 Jan 2015 16:54:06 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> Fix for BUG_ON(anon_vma->degree) splashes in unlink_anon_vmas()
> ("kernel BUG at mm/rmap.c:399!").
> 
> Anon_vma_clone() is usually called for a copy of source vma in destination
> argument. If source vma has anon_vma it should be already in dst->anon_vma.
> NULL in dst->anon_vma is used as a sign that it's called from anon_vma_fork().
> In this case anon_vma_clone() finds anon_vma for reusing.
> 
> Vma_adjust() calls it differently and this breaks anon_vma reusing logic:
> anon_vma_clone() links vma to old anon_vma and updates degree counters but
> vma_adjust() overrides vma->anon_vma right after that. As a result final
> unlink_anon_vmas() decrements degree for wrong anon_vma.
> 
> This patch assigns ->anon_vma before calling anon_vma_clone().
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")

I've asked Greg not to take 7a3ef208e662 into -stable because of this
problem.  So if you still think we should fix this in -stable, could
you please prepare an updated patch and send it to Greg?

> Tested-by: Chris Clayton <chris2553@googlemail.com>
> Tested-by: Oded Gabbay <oded.gabbay@amd.com>
> Cc: Daniel Forrest <dan.forrest@ssec.wisc.edu>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
