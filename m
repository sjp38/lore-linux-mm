Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8976A6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 05:44:41 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xy5so33604445wjc.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:44:41 -0800 (PST)
Received: from mail-wj0-x241.google.com (mail-wj0-x241.google.com. [2a00:1450:400c:c01::241])
        by mx.google.com with ESMTPS id p21si2788964wmb.29.2016.12.16.02.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 02:44:40 -0800 (PST)
Received: by mail-wj0-x241.google.com with SMTP id kp2so13871671wjc.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:44:40 -0800 (PST)
Date: Fri, 16 Dec 2016 13:44:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: crash during oom reaper (was: Re: [PATCH 4/4] [RFC!] mm: 'struct
 mm_struct' reference counting debugging)
Message-ID: <20161216104438.GD27758@node>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216101113.GE13940@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Dec 16, 2016 at 11:11:13AM +0100, Michal Hocko wrote:
> On Fri 16-12-16 10:43:52, Vegard Nossum wrote:
> [...]
> > I don't think it's a bug in the OOM reaper itself, but either of the
> > following two patches will fix the problem (without my understand how or
> > why):
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index ec9f11d4f094..37b14b2e2af4 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -485,7 +485,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk,
> > struct mm_struct *mm)
> >  	 */
> >  	mutex_lock(&oom_lock);
> > 
> > -	if (!down_read_trylock(&mm->mmap_sem)) {
> > +	if (!down_write_trylock(&mm->mmap_sem)) {
> 
> __oom_reap_task_mm is basically the same thing as MADV_DONTNEED and that
> doesn't require the exlusive mmap_sem. So this looks correct to me.

BTW, shouldn't we filter out all VM_SPECIAL VMAs there? Or VM_PFNMAP at
least.

MADV_DONTNEED doesn't touch VM_PFNMAP, but I don't see anything matching
on __oom_reap_task_mm() side.

Other difference is that you use unmap_page_range() witch doesn't touch
mmu_notifiers. MADV_DONTNEED goes via zap_page_range(), which invalidates
the range. Not sure if it can make any difference here.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
