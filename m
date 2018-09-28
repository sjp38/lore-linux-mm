Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0D6B8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 11:30:12 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id w23-v6so5840804qts.11
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 08:30:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g11-v6si3805109qke.47.2018.09.28.08.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 08:30:11 -0700 (PDT)
Date: Fri, 28 Sep 2018 11:29:59 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/4] get_user_pages*() and RDMA: first steps
Message-ID: <20180928152958.GA3321@redhat.com>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180928053949.5381-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Christian Benvenuti <benve@cisco.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>

On Thu, Sep 27, 2018 at 10:39:45PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Hi,
> 
> This short series prepares for eventually fixing the problem described
> in [1], and is following a plan listed in [2].
> 
> I'd like to get the first two patches into the -mm tree.
> 
> Patch 1, although not technically critical to do now, is still nice to have,
> because it's already been reviewed by Jan, and it's just one more thing on the
> long TODO list here, that is ready to be checked off.
> 
> Patch 2 is required in order to allow me (and others, if I'm lucky) to start
> submitting changes to convert all of the callsites of get_user_pages*() and
> put_page().  I think this will work a lot better than trying to maintain a
> massive patchset and submitting all at once.
> 
> Patch 3 converts infiniband drivers: put_page() --> put_user_page(). I picked
> a fairly small and easy example.
> 
> Patch 4 converts a small driver from put_page() --> release_user_pages(). This
> could just as easily have been done as a change from put_page() to
> put_user_page(). The reason I did it this way is that this provides a small and
> simple caller of the new release_user_pages() routine. I wanted both of the
> new routines, even though just placeholders, to have callers.
> 
> Once these are all in, then the floodgates can open up to convert the large
> number of get_user_pages*() callsites.
> 
> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
>     Proposed steps for fixing get_user_pages() + DMA problems.
> 

So the solution is to wait (possibly for days, months, years) that the
RDMA or GPU which did GUP and do not have mmu notifier, release the page
(or put_user_page()) ?

This sounds bads. Like i said during LSF/MM there is no way to properly
fix hardware that can not be preempted/invalidated ... most GPU are fine.
Few RDMA are fine, most can not ...

If it is just about fixing the set_page_dirty() bug then just looking at
refcount versus mapcount should already tell you if you can remove the
buffer head from the page or not. Which would fix the bug without complex
changes (i still like the put_user_page just for symetry with GUP).

Cheers,
Jerome
