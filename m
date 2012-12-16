Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 9B1746B002B
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 03:41:52 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2816676eek.14
        for <linux-mm@kvack.org>; Sun, 16 Dec 2012 00:41:50 -0800 (PST)
Date: Sun, 16 Dec 2012 09:41:46 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: Downgrade mmap_sem before locking or populating on
 mmap
Message-ID: <20121216084146.GA21690@gmail.com>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <20121214072755.GR4939@ZenIV.linux.org.uk>
 <CALCETrVw9Pc1sUZBL=wtLvsnBnkW5LAO5iu-i=T2oMOdwQfjHg@mail.gmail.com>
 <20121214144927.GS4939@ZenIV.linux.org.uk>
 <CALCETrUS7baKF7cdbrqX-o2qdeo1Uk=7Z4MHcxHMA3Luh+Obdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUS7baKF7cdbrqX-o2qdeo1Uk=7Z4MHcxHMA3Luh+Obdw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, J??rn Engel <joern@logfs.org>


* Andy Lutomirski <luto@amacapital.net> wrote:

> On Fri, Dec 14, 2012 at 6:49 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Fri, Dec 14, 2012 at 03:14:50AM -0800, Andy Lutomirski wrote:
> >
> >> > Wait a minute.  get_user_pages() relies on ->mmap_sem being held.  Unless
> >> > I'm seriously misreading your patch it removes that protection.  And yes,
> >> > I'm aware of execve-related exception; it's in special circumstances -
> >> > bprm->mm is guaranteed to be not shared (and we need to rearchitect that
> >> > area anyway, but that's a separate story).
> >>
> >> Unless I completely screwed up the patch, ->mmap_sem is still held for
> >> read (it's downgraded from write).  It's just not held for write
> >> anymore.
> >
> > Huh?  I'm talking about the call of get_user_pages() in aio_setup_ring().
> > With your patch it's done completely outside of ->mmap_sem, isn't it?
> 
> Oh, /that/ call to get_user_pages.  That would qualify as screwing up...
> 
> Since dropping and reacquiring mmap_sem there is probably a 
> bad idea there, I'll rework this and post a v2.

It probably does not matter much, as aio_setup() is an utter 
slowpath, but I suspect you could still use the downgrading 
variant of do_mmap_pgoff_unlock() here too:

	int downgraded = 0;

	...

        down_write(&ctx->mm->mmap_sem);
        /*
         * XXX: If MCL_FUTURE is set, this will hold mmap_sem for write for
         *      longer than necessary.
         */
        info->mmap_base = do_mmap_pgoff_helper(NULL, 0, info->mmap_size,
                                        PROT_READ|PROT_WRITE,
                                        MAP_ANONYMOUS|MAP_PRIVATE, 0, &downgraded);
        if (IS_ERR((void *)info->mmap_base)) {
		up_read_write(&ctx->mm->mmap_sem, downgraded);
                info->mmap_size = 0;
                aio_free_ring(ctx);
                return -EAGAIN;
        }

        dprintk("mmap address: 0x%08lx\n", info->mmap_base);
        info->nr_pages = get_user_pages(current, ctx->mm,
                                        info->mmap_base, nr_pages,
                                        1, 0, info->ring_pages, NULL);
	up_read_write(&ctx->mm->mmap_sem, downgraded);

Where up_read_write(lock, read) is a new primitive/wrapper that 
does the up_read()/up_write() depending on the value of 
'downgraded'.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
