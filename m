Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 492D96B24BD
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 02:05:03 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x98-v6so2571699ede.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:05:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8-v6si7508761ejm.81.2018.11.20.23.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 23:05:01 -0800 (PST)
Date: Wed, 21 Nov 2018 08:05:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, proc: be more verbose about unstable VMA
 flags in /proc/<pid>/smaps
Message-ID: <20181121070500.GB12932@dhcp22.suse.cz>
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-2-mhocko@kernel.org>
 <CAPcyv4j7=Mh9dt3Fv+cEhtYEXXKNDxErv0N9Zt+h+r9QxX_GAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j7=Mh9dt3Fv+cEhtYEXXKNDxErv0N9Zt+h+r9QxX_GAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux API <linux-api@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, adobriyan@gmail.com, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>

On Tue 20-11-18 10:32:07, Dan Williams wrote:
> On Tue, Nov 20, 2018 at 2:35 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > From: Michal Hocko <mhocko@suse.com>
> >
> > Even though vma flags exported via /proc/<pid>/smaps are explicitly
> > documented to be not guaranteed for future compatibility the warning
> > doesn't go far enough because it doesn't mention semantic changes to
> > those flags. And they are important as well because these flags are
> > a deep implementation internal to the MM code and the semantic might
> > change at any time.
> >
> > Let's consider two recent examples:
> > http://lkml.kernel.org/r/20181002100531.GC4135@quack2.suse.cz
> > : commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
> > : removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
> > : mean time certain customer of ours started poking into /proc/<pid>/smaps
> > : and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
> > : flags, the application just fails to start complaining that DAX support is
> > : missing in the kernel.
> >
> > http://lkml.kernel.org/r/alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com
> > : Commit 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
> > : introduced a regression in that userspace cannot always determine the set
> > : of vmas where thp is ineligible.
> > : Userspace relies on the "nh" flag being emitted as part of /proc/pid/smaps
> > : to determine if a vma is eligible to be backed by hugepages.
> > : Previous to this commit, prctl(PR_SET_THP_DISABLE, 1) would cause thp to
> > : be disabled and emit "nh" as a flag for the corresponding vmas as part of
> > : /proc/pid/smaps.  After the commit, thp is disabled by means of an mm
> > : flag and "nh" is not emitted.
> > : This causes smaps parsing libraries to assume a vma is eligible for thp
> > : and ends up puzzling the user on why its memory is not backed by thp.
> >
> > In both cases userspace was relying on a semantic of a specific VMA
> > flag. The primary reason why that happened is a lack of a proper
> > internface. While this has been worked on and it will be fixed properly,
> > it seems that our wording could see some refinement and be more vocal
> > about semantic aspect of these flags as well.
> >
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  Documentation/filesystems/proc.txt | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> > index 12a5e6e693b6..b1fda309f067 100644
> > --- a/Documentation/filesystems/proc.txt
> > +++ b/Documentation/filesystems/proc.txt
> > @@ -496,7 +496,9 @@ flags associated with the particular virtual memory area in two letter encoded
> >
> >  Note that there is no guarantee that every flag and associated mnemonic will
> >  be present in all further kernel releases. Things get changed, the flags may
> > -be vanished or the reverse -- new added.
> > +be vanished or the reverse -- new added. Interpretatation of their meaning
> > +might change in future as well. So each consumnent of these flags have to
> > +follow each specific kernel version for the exact semantic.
> 
> Can we start to claw some of this back? Perhaps with a config option
> to hide the flags to put applications on notice?

I would love to. My knowledge of CRIU is very minimal, but my
understanding is that this is the primary consumer of those flags. And
checkpointing is so close to the specific kernel version that I assume
that this abuse is somehow justified. We can hide it behind
CONFIG_CHECKPOINT_RESTORE but does it going to help? I presume that many
distro kernels will have the config enabled.

> I recall that when I
> introduced CONFIG_IO_STRICT_DEVMEM it caused enough regressions that
> distros did not enable it, but now a few years out I'm finding that it
> is enabled in more places.
> 
> In any event,
> 
> Acked-by: Dan Williams <dan.j.williams@intel.com>

Thanks!

-- 
Michal Hocko
SUSE Labs
