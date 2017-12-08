Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A093B6B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 02:50:19 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a10so7384962pgq.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 23:50:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si5061458pll.350.2017.12.07.23.50.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 23:50:18 -0800 (PST)
Date: Fri, 8 Dec 2017 08:50:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171208075014.GN20234@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
 <20171206090019.GE16386@dhcp22.suse.cz>
 <201712070720.vB77KlBQ009754@www262.sakura.ne.jp>
 <20171207082801.GB20234@dhcp22.suse.cz>
 <alpine.DEB.2.10.1712071315570.135101@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1712071315570.135101@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 07-12-17 13:22:30, David Rientjes wrote:
[...]
> > diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
> > index 9c8847395b5e..da673ca66e7a 100644
> > --- a/include/linux/sched/coredump.h
> > +++ b/include/linux/sched/coredump.h
> > @@ -68,8 +68,9 @@ static inline int get_dumpable(struct mm_struct *mm)
> >  #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
> >  #define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
> >  #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
> > -#define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
> > -#define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
> > +#define MMF_OOM_VICTIM		23	/* mm is the oom victim */
> > +#define MMF_HUGE_ZERO_PAGE	24      /* mm has ever used the global huge zero page */
> > +#define MMF_DISABLE_THP		25	/* disable THP for all VMAs */
> >  #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
> >  
> >  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
> 
> Could we not adjust the bit values, but simply add new one for 
> MMF_OOM_VICTIM?  We have automated tools that look at specific bits in 
> mm->flags and it would be nice to not have them be inconsistent between 
> kernel versions.  Not absolutely required, but nice to avoid.

I just wanted to have those semantically related bits closer
together. But I do not insist on this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
