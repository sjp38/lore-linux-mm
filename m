Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 740B26B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 22:19:14 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id xa12so5497464pbc.11
        for <linux-mm@kvack.org>; Mon, 01 Jul 2013 19:19:13 -0700 (PDT)
Date: Tue, 2 Jul 2013 10:37:48 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [RFC][PATCH] mm: madvise: MADV_POPULATE for quick pre-faulting
Message-ID: <20130702023748.GA10366@gmail.com>
References: <20130627231605.8F9F12E6@viggo.jf.intel.com>
 <20130628054757.GA10429@gmail.com>
 <51CDB056.5090308@sr71.net>
 <51CE4451.4060708@gmail.com>
 <51D1AB6E.9030905@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51D1AB6E.9030905@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 01, 2013 at 09:16:46AM -0700, Dave Hansen wrote:
> On 06/28/2013 07:20 PM, Zheng Liu wrote:
> >> > IOW, a process needing to do a bunch of MAP_POPULATEs isn't
> >> > parallelizable, but one using this mechanism would be.
> > I look at the code, and it seems that we will handle MAP_POPULATE flag
> > after we release mmap_sem locking in vm_mmap_pgoff():
> > 
> >                 down_write(&mm->mmap_sem);
> >                 ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
> >                                     &populate);
> >                 up_write(&mm->mmap_sem);
> >                 if (populate)
> >                         mm_populate(ret, populate);
> > 
> > Am I missing something?
> 
> I went and did my same test using mmap(MAP_POPULATE)/munmap() pair
> versus using MADV_POPULATE in 160 threads in parallel.
> 
> MADV_POPULATE was about 10x faster in the threaded configuration.
> 
> With MADV_POPULATE, the biggest cost is shipping the mmap_sem cacheline
> around so that we can write the reader count update in to it.  With
> mmap(), there is a lot of _contention_ on that lock which is much, much
> more expensive than simply bouncing a cacheline around.

Thanks for your explanation.

FWIW, it would be great if we can let MAP_POPULATE flag support shared
mappings because in our product system there has a lot of applications
that uses mmap(2) and then pre-faults this mapping.  Currently these
applications need to pre-fault the mapping manually.

Regards,
                                                - Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
