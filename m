Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD93A6B000D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 08:15:31 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g1-v6so1518627edp.2
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 05:15:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15-v6si3154907edf.328.2018.07.02.05.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 05:15:30 -0700 (PDT)
Date: Mon, 2 Jul 2018 14:15:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 5/5] x86: check VM_DEAD flag in page fault
Message-ID: <20180702121528.GM19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-6-git-send-email-yang.shi@linux.alibaba.com>
 <84eba553-2e0b-1a90-d543-6b22c1b3c5f8@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84eba553-2e0b-1a90-d543-6b22c1b3c5f8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon 02-07-18 10:45:03, Laurent Dufour wrote:
> On 30/06/2018 00:39, Yang Shi wrote:
> > Check VM_DEAD flag of vma in page fault handler, if it is set, trigger
> > SIGSEGV.
> > 
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > ---
> >  arch/x86/mm/fault.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> > 
> > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > index 9a84a0d..3fd2da5 100644
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -1357,6 +1357,10 @@ static inline bool smap_violation(int error_code, struct pt_regs *regs)
> >  		bad_area(regs, error_code, address);
> >  		return;
> >  	}
> > +	if (unlikely(vma->vm_flags & VM_DEAD)) {
> > +		bad_area(regs, error_code, address);
> > +		return;
> > +	}
> 
> This will have to be done for all the supported architectures, what about doing
> this check in handle_mm_fault() and return VM_FAULT_SIGSEGV ?

We already do have a model for that. Have a look at MMF_UNSTABLE.

-- 
Michal Hocko
SUSE Labs
