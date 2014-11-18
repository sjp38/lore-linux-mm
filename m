Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B4E766B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 12:08:31 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so2603080wiv.5
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 09:08:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9si67723381wjy.35.2014.11.18.09.08.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 09:08:30 -0800 (PST)
Date: Tue, 18 Nov 2014 17:08:25 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/7] Replace _PAGE_NUMA with PAGE_NONE protections
Message-ID: <20141118170825.GD2725@suse.de>
References: <1415971986-16143-1-git-send-email-mgorman@suse.de>
 <877fyugrmc.fsf@linux.vnet.ibm.com>
 <20141118160112.GC2725@suse.de>
 <87y4r879k5.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87y4r879k5.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Nov 18, 2014 at 10:03:30PM +0530, Aneesh Kumar K.V wrote:
> > diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
> > index 5a236f0..46152aa 100644
> > --- a/arch/powerpc/mm/copro_fault.c
> > +++ b/arch/powerpc/mm/copro_fault.c
> > @@ -64,7 +64,12 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
> >  		if (!(vma->vm_flags & VM_WRITE))
> >  			goto out_unlock;
> >  	} else {
> > -		if (dsisr & DSISR_PROTFAULT)
> > +		/*
> > +		 * protfault should only happen due to us
> > +		 * mapping a region readonly temporarily. PROT_NONE
> > +		 * is also covered by the VMA check above.
> > +		 */
> > +		if (WARN_ON_ONCE(dsisr & DSISR_PROTFAULT))
> >  			goto out_unlock;
> >  		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
> >  			goto out_unlock;
> 
> 
> we should do that DSISR_PROTFAILT check after vma->vm_flags. It is not
> that we will not hit DSISR_PROTFAULT, what we want to ensure here is that
> we get a prot fault only for cases convered by that vma check. So
> everything should be taking the if (!(vma->vm_flags & (VM_READ |
> VM_EXEC))) branch if it is a protfault. If not we would like to know
> about that. And hence the idea of not using WARN_ON_ONCE. I was also not
> sure whether we want to enable that always. The reason for keeping that
> within CONFIG_DEBUG_VM is to make sure that nobody ends up depending on
> PROTFAULT outside the vma check convered. So expectations is that
> developers working on feature will run with DEBUG_VM enable and finds
> this warning. We don't expect to hit this otherwise.
> 

/me slaps self. It's clear now and updated accordingly. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
