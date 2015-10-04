Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id BB16C680DC6
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 01:24:35 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so144201855pac.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 22:24:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gr2si29825886pbc.174.2015.10.03.22.24.34
        for <linux-mm@kvack.org>;
        Sat, 03 Oct 2015 22:24:34 -0700 (PDT)
Date: Sat, 3 Oct 2015 23:24:33 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 0/2] Revert locking changes in DAX for v4.3
Message-ID: <20151004052433.GA10753@linux.intel.com>
References: <1443830494-8748-2-git-send-email-ross.zwisler@linux.intel.com>
 <1443830494-8748-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1443830494-8748-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org

On Fri, Oct 02, 2015 at 06:01:32PM -0600, Ross Zwisler wrote:
> This series reverts some recent changes to the locking scheme in DAX introduced
> by these two commits:
> 
> commit 843172978bb9 ("dax: fix race between simultaneous faults")
> commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")
> 
> Changes from v1:
>  -  Squashed patches 1 and 2 from the first series into a single patch to avoid
>     adding another spot in the git history where we could end up referencing an
>     uninitialized pointer.
> 
> Ross Zwisler (2):
>   Revert "mm: take i_mmap_lock in unmap_mapping_range() for DAX"
>   Revert "dax: fix race between simultaneous faults"
> 
>  fs/dax.c    | 83 +++++++++++++++++++++++++------------------------------------
>  mm/memory.c |  2 ++
>  2 files changed, 36 insertions(+), 49 deletions(-)
> 
> -- 
> 2.1.0

*sigh* - even after these reverts we can deadlock on in the DAX PMD code with
its original locking scheme.  I can hit them 100% of the time with either
generic/074 or generic/198 using either XFS or ext4.  I'll debug exactly
what's going on on Monday.

The quick and easy workaround for this is to do a "return VM_FAULT_FALLBACK;"
at the beginning of __dax_pmd_fault() to just turn off PMD faults while we
rework the locking for v4.4.  This saves us reverting and re-adding all the
PMD code, and will let us ship v4.3 without known deadlocks.

Other better ideas?

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
