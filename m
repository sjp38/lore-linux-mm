Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E863F6B0010
	for <linux-mm@kvack.org>; Sat, 19 Jan 2013 04:36:09 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hn17so5837010wib.6
        for <linux-mm@kvack.org>; Sat, 19 Jan 2013 01:36:08 -0800 (PST)
Date: Sat, 19 Jan 2013 10:36:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Define set_pmd_at for numabalance for CONFIG_PARAVIRT
Message-ID: <20130119093605.GA27436@dhcp22.suse.cz>
References: <1358501604-6797-1-git-send-email-mhocko@suse.cz>
 <20130118133901.b445b348.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130118133901.b445b348.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org

On Fri 18-01-13 13:39:01, Andrew Morton wrote:
> On Fri, 18 Jan 2013 10:33:24 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > CONFIG_PARAVIRT defines set_pmd_at only for CONFIG_TRANSPARENT_HUGEPAGE
> > which leads to the following compile errors when randconfig selected
> > CONFIG_NUMA_BALANCING && CONFIG_PARAVIRT && !CONFIG_TRANSPARENT_HUGEPAGE:
> > 
> > mm/mprotect.c: In function ___change_pmd_protnuma___:
> > mm/mprotect.c:120: error: implicit declaration of function ___set_pmd_at___
> > 
> > mm/memory.c: In function ___do_pmd_numa_page___:
> > mm/memory.c:3529: error: implicit declaration of function ___set_pmd_at___
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  arch/x86/include/asm/paravirt.h |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
> > index a0facf3..f551e89 100644
> > --- a/arch/x86/include/asm/paravirt.h
> > +++ b/arch/x86/include/asm/paravirt.h
> > @@ -528,7 +528,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
> >  		PVOP_VCALL4(pv_mmu_ops.set_pte_at, mm, addr, ptep, pte.pte);
> >  }
> >  
> > -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_NUMA_BALANCING)
> >  static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
> >  			      pmd_t *pmdp, pmd_t pmd)
> >  {
> 
> Confused - there is no "#ifdef CONFIG_TRANSPARENT_HUGEPAGE" in there in
> any kernel version I can think of.

Ohh, I am missing c36e0501ee91d7616a188efbf9714b1fce150032 which didn't
go via your tree.

Sorry for the noise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
