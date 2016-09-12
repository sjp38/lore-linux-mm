Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB1BC6B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 21:40:40 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 192so89515993itm.2
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 18:40:40 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id u66si17078787itf.4.2016.09.11.18.40.38
        for <linux-mm@kvack.org>;
        Sun, 11 Sep 2016 18:40:39 -0700 (PDT)
Date: Mon, 12 Sep 2016 11:40:35 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160912014035.GB30497@dastard>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160908225636.GB15167@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, mtosatti@redhat.com, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Sep 08, 2016 at 04:56:36PM -0600, Ross Zwisler wrote:
> On Wed, Sep 07, 2016 at 09:32:36PM -0700, Dan Williams wrote:
> > My understanding is that it is looking for the VM_MIXEDMAP flag which
> > is already ambiguous for determining if DAX is enabled even if this
> > dynamic listing issue is fixed.  XFS has arranged for DAX to be a
> > per-inode capability and has an XFS-specific inode flag.  We can make
> > that a common inode flag, but it seems we should have a way to
> > interrogate the mapping itself in the case where the inode is unknown
> > or unavailable.  I'm thinking extensions to mincore to have flags for
> > DAX and possibly whether the page is part of a pte, pmd, or pud
> > mapping.  Just floating that idea before starting to look into the
> > implementation, comments or other ideas welcome...
> 
> I think this goes back to our previous discussion about support for the PMEM
> programming model.  Really I think what NVML needs isn't a way to tell if it
> is getting a DAX mapping, but whether it is getting a DAX mapping on a
> filesystem that fully supports the PMEM programming model.  This of course is
> defined to be a filesystem where it can do all of its flushes from userspace
> safely and never call fsync/msync, and that allocations that happen in page
> faults will be synchronized to media before the page fault completes.
> 
> IIUC this is what NVML needs - a way to decide "do I use fsync/msync for
> everything or can I rely fully on flushes from userspace?" 

"need fsync/msync" is a dynamic state of an inode, not a static
property. i.e. users can do things that change an inode behind the
back of a mapping, even if they are not aware that this might
happen. As such, a filesystem can invalidate an existing mapping
at any time and userspace won't notice because it will simply fault
in a new mapping on the next access...

> For all existing implementations, I think the answer is "you need to use
> fsync/msync" because we don't yet have proper support for the PMEM programming
> model.

Yes, that is correct.

FWIW, I don't think it will ever be possible to support this ....
wonderful "PMEM programming model" from any current or future kernel
filesystem without a very specific set of restrictions on what can
be done to a file.  e.g.

	1. the file has to be fully allocated and zeroed before
	   use. Preallocation/zeroing via unwritten extents is not
	   allowed. Sparse files are not allowed. Shared extents are
	   not allowed.
	2. set the "PMEM_IMMUTABLE" inode flag - filesystem must
	   check the file is fully allocated before allowing it to
	   be set, and caller must have CAP_LINUX_IMMUTABLE.
	3. Inode metadata is now immutable, and file data can only
	   be accessed and/or modified via mmap().
	4. All non-mmap methods of inode data modification
	   will now fail with EPERM.
	5. all methods of inode metadata modification will now fail
	   with EPERM, timestamp udpdates will be ignored.
	6. PMEM_IMMUTABLE flag can only be removed if the file is
	   not currently mapped and caller has CAP_LINUX_IMMUTABLE.

A flag like this /should/ make it possible to avoid fsync/msync() on
a file for existing filesystems, but it also means that such files
have significant management issues (hence the need for
CAP_LINUX_IMMUTABLE to cover it's use).

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
