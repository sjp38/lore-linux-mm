Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0F96B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:01:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y192so6054167pgd.12
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:01:22 -0700 (PDT)
Received: from ipmailnode02.adl6.internode.on.net (ipmailnode02.adl6.internode.on.net. [150.101.137.148])
        by mx.google.com with ESMTP id b8si5997941plm.383.2017.08.15.02.01.19
        for <linux-mm@kvack.org>;
        Tue, 15 Aug 2017 02:01:20 -0700 (PDT)
Date: Tue, 15 Aug 2017 19:01:16 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 0/3] MAP_DIRECT and block-map sealed files
Message-ID: <20170815090116.GL21024@dastard>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: darrick.wong@oracle.com, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Aug 14, 2017 at 11:12:05PM -0700, Dan Williams wrote:
> Changes since v3 [1]:
> * Move from an fallocate(2) interface to a new mmap(2) flag and rename
>   'immutable' to 'sealed'.
> 
> * Do not record the sealed state in permanent metadata it is now purely
>   a temporary state for as long as a MAP_DIRECT vma is referencing the
>   inode (Christoph)
> 
> * Drop the CAP_IMMUTABLE requirement, but do require a PROT_WRITE
>   mapping.
> 
> [1]: https://lwn.net/Articles/730570/
> 
> ---
> 
> This is the next revision of a patch series that aims to enable
> applications that otherwise need to resort to DAX mapping a raw device
> file to instead move to a filesystem.
> 
> In the course of reviewing a previous posting, Christoph said:
> 
>     That being said I think we absolutely should support RDMA memory
>     registrations for DAX mappings.  I'm just not sure how S_IOMAP_IMMUTABLE
>     helps with that.  We'll want a MAP_SYNC | MAP_POPULATE to make sure all
>     the blocks are populated and all ptes are set up.  Second we need to
>     make sure get_user_page works, which for now means we'll need a struct
>     page mapping for the region (which will be really annoying for PCIe
>     mappings, like the upcoming NVMe persistent memory region), and we need
>     to guarantee that the extent mapping won't change while the
>     get_user_pages holds the pages inside it.  I think that is true due to
>     side effects even with the current DAX code, but we'll need to make it
>     explicit.  And maybe that's where we need to converge - "sealing" the
>     extent map makes sense as such a temporary measure that is not persisted
>     on disk, which automatically gets released when the holding process
>     exits, because we sort of already do this implicitly.  It might also
>     make sense to have explicitly breakable seals similar to what I do for
>     the pNFS blocks kernel server, as any userspace RDMA file server would
>     also need those semantics.
> 
> So, this is an attempt to converge on the idea that we need an explicit
> and process-lifetime-temporary mechanism for a process to be able to
> make assumptions about the mapping to physical page to dax-file-offset
> relationship. The "explicitly breakable seals" aspect is not addressed
> in these patches, but I wonder if it might be a voluntary mechanism that
> can implemented via userfaultfd.
> 
> These pass a basic smoke test and are meant to just gauge 'right track'
> / 'wrong track'. The main question it seems is whether the pinning done
> in this patchset is too early (applies before get_user_pages()) and too
> coarse (applies to the whole file). Perhaps this is where I discarded
> too easily Jan's suggestion to look at Peter Z's mm_mpin() syscall [2]? On
> the other hand, the coarseness and simple lifetime rules of MAP_DIRECT
> make it an easy mechanism to implement and explain.
> 
> Another reason I kept the scope of S_IOMAP_SEALED coarsely defined was
> to support Dave's desired use case of sealing for operating on reflinked
> files [3].

Which really needs a fcntl() interface to set/clear iomap seals.

Which, now that I look at it, already has a bunch of "file sealing"
commands defined which arrived in 3.17. It appears to be a special
purpose access control interface for memfd_create() to manage shared
access to anonymous tmpfs files and will EINVAL on any fd that
points to a real file.

Oh, even more problematic:

	Seals are a property of an inode. [....] Furthermore, seals
	can never be removed, only added.

That seems somewhat difficult to reconcile with how I need
F_SEAL_IOMAP to operate.

/me calls it a day and goes looking for the hard liquor.....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
