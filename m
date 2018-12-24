Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 581198E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 13:51:11 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t2so15332169edb.22
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 10:51:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b6si1393009edi.277.2018.12.24.10.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Dec 2018 10:51:09 -0800 (PST)
Date: Mon, 24 Dec 2018 19:51:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Bug with report THP eligibility for each vma
Message-ID: <20181224185106.GC16738@dhcp22.suse.cz>
References: <CALouPAi8KEuPw_Ly5W=MkYi8Yw3J6vr8mVezYaxxVyKCxH1x_g@mail.gmail.com>
 <20181224074916.GB9063@dhcp22.suse.cz>
 <20181224121250.GA2070@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181224121250.GA2070@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Oppenheimer <bepvte@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 24-12-18 14:12:51, Mike Rapoport wrote:
> On Mon, Dec 24, 2018 at 08:49:16AM +0100, Michal Hocko wrote:
> > [Cc-ing mailing list and people involved in the original patch]
> > 
> > On Fri 21-12-18 13:42:24, Paul Oppenheimer wrote:
> > > Hello! I've never reported a kernel bug before, and since its on the
> > > "next" tree I was told to email the author of the relevant commit.
> > > Please redirect me to the correct place if I've made a mistake.
> > > 
> > > When opening firefox or chrome, and using it for a good 7 seconds, it
> > > hangs in "uninterruptible sleep" and I recieve a "BUG" in dmesg. This
> > > doesn't occur when reverting this commit:
> > > https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=48cf516f8c.
> > > Ive attached the output of decode_stacktrace.sh and the relevant dmesg
> > > log to this email.
> > > 
> > > Thanks
> > 
> > > BUG: unable to handle kernel NULL pointer dereference at 00000000000000e8
> > 
> > Thanks for the bug report! This is offset 232 and that matches
> > file->f_mapping as per pahole
> > pahole -C file ./vmlinux | grep f_mapping
> >         struct address_space *     f_mapping;            /*   232     8 */
> > 
> > I thought that each file really has to have a mapping. But the following
> > should heal the issue and add an extra care.
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index f64733c23067..fc9d70a9fbd1 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -66,6 +66,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
> >  {
> >  	if (vma_is_anonymous(vma))
> >  		return __transparent_hugepage_enabled(vma);
> > +	if (!vma->vm_file || !vma->vm_file->f_mapping)
> > +		return false;
> >  	if (shmem_mapping(vma->vm_file->f_mapping) && shmem_huge_enabled(vma))
> >  		return __transparent_hugepage_enabled(vma);
> 
> We have vma_is_shmem(), it can be used to replace shmem_mapping() without
> adding the check for !vma->vm_file

Yes, this looks like a much better choice. Thanks! Andrew, could you
fold this in instead.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f64733c23067..e093cf5e4640 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -66,7 +66,7 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
 	if (vma_is_anonymous(vma))
 		return __transparent_hugepage_enabled(vma);
-	if (shmem_mapping(vma->vm_file->f_mapping) && shmem_huge_enabled(vma))
+	if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
 		return __transparent_hugepage_enabled(vma);
 
 	return false;
-- 
Michal Hocko
SUSE Labs
