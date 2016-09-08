Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7D76B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 18:56:38 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hi6so130588514pac.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 15:56:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id y4si414252pfg.217.2016.09.08.15.56.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 15:56:37 -0700 (PDT)
Date: Thu, 8 Sep 2016 16:56:36 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160908225636.GB15167@linux.intel.com>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Xiao Guangrong <guangrong.xiao@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, mtosatti@redhat.com, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Sep 07, 2016 at 09:32:36PM -0700, Dan Williams wrote:
> [ adding linux-fsdevel and linux-nvdimm ]
> 
> On Wed, Sep 7, 2016 at 8:36 PM, Xiao Guangrong
> <guangrong.xiao@linux.intel.com> wrote:
> [..]
> > However, it is not easy to handle the case that the new VMA overlays with
> > the old VMA
> > already got by userspace. I think we have some choices:
> > 1: One way is completely skipping the new VMA region as current kernel code
> > does but i
> >    do not think this is good as the later VMAs will be dropped.
> >
> > 2: show the un-overlayed portion of new VMA. In your case, we just show the
> > region
> >    (0x2000 -> 0x3000), however, it can not work well if the VMA is a new
> > created
> >    region with different attributions.
> >
> > 3: completely show the new VMA as this patch does.
> >
> > Which one do you prefer?
> >
> 
> I don't have a preference, but perhaps this breakage and uncertainty
> is a good opportunity to propose a more reliable interface for NVML to
> get the information it needs?
> 
> My understanding is that it is looking for the VM_MIXEDMAP flag which
> is already ambiguous for determining if DAX is enabled even if this
> dynamic listing issue is fixed.  XFS has arranged for DAX to be a
> per-inode capability and has an XFS-specific inode flag.  We can make
> that a common inode flag, but it seems we should have a way to
> interrogate the mapping itself in the case where the inode is unknown
> or unavailable.  I'm thinking extensions to mincore to have flags for
> DAX and possibly whether the page is part of a pte, pmd, or pud
> mapping.  Just floating that idea before starting to look into the
> implementation, comments or other ideas welcome...

I think this goes back to our previous discussion about support for the PMEM
programming model.  Really I think what NVML needs isn't a way to tell if it
is getting a DAX mapping, but whether it is getting a DAX mapping on a
filesystem that fully supports the PMEM programming model.  This of course is
defined to be a filesystem where it can do all of its flushes from userspace
safely and never call fsync/msync, and that allocations that happen in page
faults will be synchronized to media before the page fault completes.

IIUC this is what NVML needs - a way to decide "do I use fsync/msync for
everything or can I rely fully on flushes from userspace?" 

For all existing implementations, I think the answer is "you need to use
fsync/msync" because we don't yet have proper support for the PMEM programming
model.

My best idea of how to support this was a per-inode flag similar to the one
supported by XFS that says "you have a PMEM capable DAX mapping", which NVML
would then interpret to mean "you can do flushes from userspace and be fully
safe".  I think we really want this interface to be common over XFS and ext4.

If we can figure out a better way of doing this interface, say via mincore,
that's fine, but I don't think we can detangle this from the PMEM API
discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
