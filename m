Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 3 Feb 2015 14:48:28 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 2/2] aio: make aio .mremap handle size changes
Message-ID: <20150203194828.GU2974@kvack.org>
References: <b885312bcea6e8c89889412936fb93305a4d139d.1422986358.git.shli@fb.com> <798fafb96373cfab0707457a266dd137016cd1e9.1422986358.git.shli@fb.com> <20150203192323.GT2974@kvack.org> <20150203193115.GA296459@devbig257.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203193115.GA296459@devbig257.prn2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 03, 2015 at 11:31:15AM -0800, Shaohua Li wrote:
> On Tue, Feb 03, 2015 at 02:23:23PM -0500, Benjamin LaHaise wrote:
> > On Tue, Feb 03, 2015 at 11:18:53AM -0800, Shaohua Li wrote:
> > > mremap aio ring buffer to another smaller vma is legal. For example,
> > > mremap the ring buffer from the begining, though after the mremap, some
> > > ring buffer pages can't be accessed in userspace because vma size is
> > > shrinked. The problem is ctx->mmap_size isn't changed if the new ring
> > > buffer vma size is changed. Latter io_destroy will zap all vmas within
> > > mmap_size, which might zap unrelated vmas.
> > 
> > Nak.  Shrinking the aio ring buffer is not a supported operation and will 
> > cause the application to lose events.  Make the size changing mremap fail, 
> > as this patch will not make the system do the right thing.
> 
> Yes, making the syscall fail (vma ops has .remap) is another option. If
> the app uses io_getevents(), looks the app will not lose events, no? On
> the other hand, I just want to make sure kernel does the right thing
> (not zap unrelated vmas). If app does crazy things, it will break.

But reading events out of the ring buffer is a supported mode of operation.  
Given that constraint, you should make an mremap changing the size of the 
ring buffer fail.

		-ben

> Thanks,
> Shaohua

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
