Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id ED5E56B0039
	for <linux-mm@kvack.org>; Tue,  6 May 2014 14:38:51 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id i50so8456600qgf.3
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:38:51 -0700 (PDT)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id j74si4216111qge.29.2014.05.06.11.38.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 11:38:51 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id cm18so7929203qab.36
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:38:51 -0700 (PDT)
Date: Tue, 6 May 2014 14:38:45 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140506183842.GI6731@gmail.com>
References: <20140506150014.GA6731@gmail.com>
 <CA+55aFwM-g01tCZ1NknwvMeSMpwyKyTm6hysN-GmrZ_APtk7UA@mail.gmail.com>
 <20140506153315.GB6731@gmail.com>
 <CA+55aFzzPtTkC22WvHNy6srN9PFzer0-_mgRXWO03NwmCdfy4g@mail.gmail.com>
 <20140506161836.GC6731@gmail.com>
 <CA+55aFweCGWQMSxP09MJMhJ0XySZqvw=QaoUWwsWU4KaqDgOhw@mail.gmail.com>
 <20140506172853.GF6731@gmail.com>
 <CA+55aFwhHYnVhzx4-TchrpM5AN2Oqm1fy8ot0bguJ=T_eeA0fg@mail.gmail.com>
 <20140506181308.GG6731@gmail.com>
 <CA+55aFzPrs_UdUnivxv_8=WCKjjYLz=AU+-8gtKYL-RSTi_6mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFzPrs_UdUnivxv_8=WCKjjYLz=AU+-8gtKYL-RSTi_6mw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Davidlohr Bueso <davidlohr@hp.com>

On Tue, May 06, 2014 at 11:22:48AM -0700, Linus Torvalds wrote:
> On Tue, May 6, 2014 at 11:13 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >
> > I could grow the radix function to return some bool to avoid looping over for
> > case where there is no special entry.
> 
> .. or even just a bool (or counter) associated with the mapping to
> mark whether any special entries exist at all.
> 
> Also, the code to turn special entries is duplicated over and over
> again, usually together with a "FIXME - what about migration failure",
> so it would make sense to do that as it's own function.
> 

Migration failure is when something goes horribly wrong and GPU can not
copy back the page to system memory that philosophical question associated
is what to do about other process ? Make them SIGBUS ?

The answer so far is consider this as any kind of cpu thread that would
crash and only half write content it wanted into the page. So other thread
will use the lastest version of the data we have. Thread that triggered
the migration to the GPU memory would see a SIGBUS (those thread are GPU
aware as they use some form of GPU api such as OpenCL).

> But conceptually I don't hate it. I didn't much like having random
> hmm_pagecache_migrate() calls in core vm code, and code like this
> 
> +                       hmm_pagecache_migrate(mapping, swap);
> +                       spd.pages[page_nr] = find_get_page(mapping,
> index + page_nr);
> 
> looks fundamentally racy, and in other places you seemed to assume
> that all exceptional entries are always about hmm, which looked
> questionable. But those are details.  The concept of putting a special
> swap entry in the mapping radix trees I don't necessarily find
> objectionable per se.
> 
>            Linus

So far only shmem use special entry and my patchset did not support it
as i wanted to vet the design first.

The hmm_pagecache_migrate is the function that trigger migration back to
system memory. Once again the expectation is that such code path will
neve be call, only the process that use the GPU and the mmaped file will
ever access those pages and this process knows that it should not access
them while they are on the GPU so if it does it has to suffer the
consequences.

Thanks a lot for all the feedback, much appreciated.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
