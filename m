Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 51D4D6B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 19:04:02 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w193so145370523oiw.2
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 16:04:02 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id h56si131506ote.96.2016.09.08.16.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 16:04:01 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id y2so99469246oie.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 16:04:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160908225636.GB15167@linux.intel.com>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 8 Sep 2016 16:04:00 -0700
Message-ID: <CAPcyv4h5y4MHdXtdrdPRtG7L0_KCoxf_xwDGnHQ2r5yZoqkFzQ@mail.gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in /proc/self/smaps)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, mtosatti@redhat.com, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Sep 8, 2016 at 3:56 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Wed, Sep 07, 2016 at 09:32:36PM -0700, Dan Williams wrote:
>> [ adding linux-fsdevel and linux-nvdimm ]
>>
>> On Wed, Sep 7, 2016 at 8:36 PM, Xiao Guangrong
>> <guangrong.xiao@linux.intel.com> wrote:
>> [..]
>> > However, it is not easy to handle the case that the new VMA overlays with
>> > the old VMA
>> > already got by userspace. I think we have some choices:
>> > 1: One way is completely skipping the new VMA region as current kernel code
>> > does but i
>> >    do not think this is good as the later VMAs will be dropped.
>> >
>> > 2: show the un-overlayed portion of new VMA. In your case, we just show the
>> > region
>> >    (0x2000 -> 0x3000), however, it can not work well if the VMA is a new
>> > created
>> >    region with different attributions.
>> >
>> > 3: completely show the new VMA as this patch does.
>> >
>> > Which one do you prefer?
>> >
>>
>> I don't have a preference, but perhaps this breakage and uncertainty
>> is a good opportunity to propose a more reliable interface for NVML to
>> get the information it needs?
>>
>> My understanding is that it is looking for the VM_MIXEDMAP flag which
>> is already ambiguous for determining if DAX is enabled even if this
>> dynamic listing issue is fixed.  XFS has arranged for DAX to be a
>> per-inode capability and has an XFS-specific inode flag.  We can make
>> that a common inode flag, but it seems we should have a way to
>> interrogate the mapping itself in the case where the inode is unknown
>> or unavailable.  I'm thinking extensions to mincore to have flags for
>> DAX and possibly whether the page is part of a pte, pmd, or pud
>> mapping.  Just floating that idea before starting to look into the
>> implementation, comments or other ideas welcome...
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
>
> For all existing implementations, I think the answer is "you need to use
> fsync/msync" because we don't yet have proper support for the PMEM programming
> model.
>
> My best idea of how to support this was a per-inode flag similar to the one
> supported by XFS that says "you have a PMEM capable DAX mapping", which NVML
> would then interpret to mean "you can do flushes from userspace and be fully
> safe".  I think we really want this interface to be common over XFS and ext4.
>
> If we can figure out a better way of doing this interface, say via mincore,
> that's fine, but I don't think we can detangle this from the PMEM API
> discussion.

Whether a persistent memory mapping requires an msync/fsync is a
filesystem specific question.  This mincore proposal is separate from
that.  Consider device-DAX for volatile memory or mincore() called on
an anonymous memory range.  In those cases persistence and filesystem
metadata are not in the picture, but it would still be useful for
userspace to know "is there page cache backing this mapping?" or "what
is the TLB geometry of this mapping?".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
