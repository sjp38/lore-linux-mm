Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id B13236B006C
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 20:03:36 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so10683963pad.9
        for <linux-mm@kvack.org>; Sun, 14 Jul 2013 17:03:36 -0700 (PDT)
Date: Mon, 15 Jul 2013 08:22:16 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [RFC][PATCH] mm: madvise: MADV_POPULATE for quick pre-faulting
Message-ID: <20130715002216.GA6403@gmail.com>
References: <20130627231605.8F9F12E6@viggo.jf.intel.com>
 <20130628054757.GA10429@gmail.com>
 <51CDB056.5090308@sr71.net>
 <51CE4451.4060708@gmail.com>
 <51D1AB6E.9030905@sr71.net>
 <20130702023748.GA10366@gmail.com>
 <51E2173A.8080003@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E2173A.8080003@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ben <sam.bennn@gmail.com>
Cc: Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jul 14, 2013 at 11:12:58AM +0800, Sam Ben wrote:
> On 07/02/2013 10:37 AM, Zheng Liu wrote:
> >On Mon, Jul 01, 2013 at 09:16:46AM -0700, Dave Hansen wrote:
> >>On 06/28/2013 07:20 PM, Zheng Liu wrote:
> >>>>>IOW, a process needing to do a bunch of MAP_POPULATEs isn't
> >>>>>parallelizable, but one using this mechanism would be.
> >>>I look at the code, and it seems that we will handle MAP_POPULATE flag
> >>>after we release mmap_sem locking in vm_mmap_pgoff():
> >>>
> >>>                 down_write(&mm->mmap_sem);
> >>>                 ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
> >>>                                     &populate);
> >>>                 up_write(&mm->mmap_sem);
> >>>                 if (populate)
> >>>                         mm_populate(ret, populate);
> >>>
> >>>Am I missing something?
> >>I went and did my same test using mmap(MAP_POPULATE)/munmap() pair
> >>versus using MADV_POPULATE in 160 threads in parallel.
> >>
> >>MADV_POPULATE was about 10x faster in the threaded configuration.
> >>
> >>With MADV_POPULATE, the biggest cost is shipping the mmap_sem cacheline
> >>around so that we can write the reader count update in to it.  With
> >>mmap(), there is a lot of _contention_ on that lock which is much, much
> >>more expensive than simply bouncing a cacheline around.
> >Thanks for your explanation.
> >
> >FWIW, it would be great if we can let MAP_POPULATE flag support shared
> >mappings because in our product system there has a lot of applications
> >that uses mmap(2) and then pre-faults this mapping.  Currently these
> >applications need to pre-fault the mapping manually.
> 
> How do you pre-fault the mapping manually in your product system? By
> walking through the file touching each page?

Yes, in our product system most applications do like this.

Regards,
                                                - Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
