Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECE96B006C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 14:32:12 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gq15so54225361lab.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 11:32:11 -0800 (PST)
Date: Tue, 3 Feb 2015 11:31:15 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH 2/2] aio: make aio .mremap handle size changes
Message-ID: <20150203193115.GA296459@devbig257.prn2.facebook.com>
References: <b885312bcea6e8c89889412936fb93305a4d139d.1422986358.git.shli@fb.com>
 <798fafb96373cfab0707457a266dd137016cd1e9.1422986358.git.shli@fb.com>
 <20150203192323.GT2974@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150203192323.GT2974@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: linux-mm@kvack.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 03, 2015 at 02:23:23PM -0500, Benjamin LaHaise wrote:
> On Tue, Feb 03, 2015 at 11:18:53AM -0800, Shaohua Li wrote:
> > mremap aio ring buffer to another smaller vma is legal. For example,
> > mremap the ring buffer from the begining, though after the mremap, some
> > ring buffer pages can't be accessed in userspace because vma size is
> > shrinked. The problem is ctx->mmap_size isn't changed if the new ring
> > buffer vma size is changed. Latter io_destroy will zap all vmas within
> > mmap_size, which might zap unrelated vmas.
> 
> Nak.  Shrinking the aio ring buffer is not a supported operation and will 
> cause the application to lose events.  Make the size changing mremap fail, 
> as this patch will not make the system do the right thing.

Yes, making the syscall fail (vma ops has .remap) is another option. If
the app uses io_getevents(), looks the app will not lose events, no? On
the other hand, I just want to make sure kernel does the right thing
(not zap unrelated vmas). If app does crazy things, it will break.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
