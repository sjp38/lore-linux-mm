Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1CD6B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 00:32:37 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 74so88305315oie.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 21:32:37 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id u9si359622oia.214.2016.09.07.21.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 21:32:36 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id s131so55336428oie.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 21:32:36 -0700 (PDT)
MIME-Version: 1.0
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 7 Sep 2016 21:32:36 -0700
Message-ID: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
Subject: DAX mapping detection (was: Re: [PATCH] Fix region lost in /proc/self/smaps)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, mtosatti@redhat.com, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

[ adding linux-fsdevel and linux-nvdimm ]

On Wed, Sep 7, 2016 at 8:36 PM, Xiao Guangrong
<guangrong.xiao@linux.intel.com> wrote:
[..]
> However, it is not easy to handle the case that the new VMA overlays with
> the old VMA
> already got by userspace. I think we have some choices:
> 1: One way is completely skipping the new VMA region as current kernel code
> does but i
>    do not think this is good as the later VMAs will be dropped.
>
> 2: show the un-overlayed portion of new VMA. In your case, we just show the
> region
>    (0x2000 -> 0x3000), however, it can not work well if the VMA is a new
> created
>    region with different attributions.
>
> 3: completely show the new VMA as this patch does.
>
> Which one do you prefer?
>

I don't have a preference, but perhaps this breakage and uncertainty
is a good opportunity to propose a more reliable interface for NVML to
get the information it needs?

My understanding is that it is looking for the VM_MIXEDMAP flag which
is already ambiguous for determining if DAX is enabled even if this
dynamic listing issue is fixed.  XFS has arranged for DAX to be a
per-inode capability and has an XFS-specific inode flag.  We can make
that a common inode flag, but it seems we should have a way to
interrogate the mapping itself in the case where the inode is unknown
or unavailable.  I'm thinking extensions to mincore to have flags for
DAX and possibly whether the page is part of a pte, pmd, or pud
mapping.  Just floating that idea before starting to look into the
implementation, comments or other ideas welcome...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
