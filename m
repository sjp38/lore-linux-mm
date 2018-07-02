Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6D6B6B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 08:46:01 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g16-v6so5666665edq.10
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 05:46:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h18-v6si1380093edq.57.2018.07.02.05.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 05:46:00 -0700 (PDT)
Date: Mon, 2 Jul 2018 14:45:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 5/5] x86: check VM_DEAD flag in page fault
Message-ID: <20180702124558.GP19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-6-git-send-email-yang.shi@linux.alibaba.com>
 <84eba553-2e0b-1a90-d543-6b22c1b3c5f8@linux.vnet.ibm.com>
 <20180702121528.GM19043@dhcp22.suse.cz>
 <80406cbd-67f4-ca4c-cd54-aeb305579a72@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80406cbd-67f4-ca4c-cd54-aeb305579a72@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon 02-07-18 14:26:09, Laurent Dufour wrote:
> On 02/07/2018 14:15, Michal Hocko wrote:
> > On Mon 02-07-18 10:45:03, Laurent Dufour wrote:
> >> On 30/06/2018 00:39, Yang Shi wrote:
> >>> Check VM_DEAD flag of vma in page fault handler, if it is set, trigger
> >>> SIGSEGV.
> >>>
> >>> Cc: Michal Hocko <mhocko@kernel.org>
> >>> Cc: Thomas Gleixner <tglx@linutronix.de>
> >>> Cc: Ingo Molnar <mingo@redhat.com>
> >>> Cc: "H. Peter Anvin" <hpa@zytor.com>
> >>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> >>> ---
> >>>  arch/x86/mm/fault.c | 4 ++++
> >>>  1 file changed, 4 insertions(+)
> >>>
> >>> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> >>> index 9a84a0d..3fd2da5 100644
> >>> --- a/arch/x86/mm/fault.c
> >>> +++ b/arch/x86/mm/fault.c
> >>> @@ -1357,6 +1357,10 @@ static inline bool smap_violation(int error_code, struct pt_regs *regs)
> >>>  		bad_area(regs, error_code, address);
> >>>  		return;
> >>>  	}
> >>> +	if (unlikely(vma->vm_flags & VM_DEAD)) {
> >>> +		bad_area(regs, error_code, address);
> >>> +		return;
> >>> +	}
> >>
> >> This will have to be done for all the supported architectures, what about doing
> >> this check in handle_mm_fault() and return VM_FAULT_SIGSEGV ?
> > 
> > We already do have a model for that. Have a look at MMF_UNSTABLE.
> 
> MMF_UNSTABLE is a mm's flag, here this is a VMA's flag which is checked.

Yeah, and we have the VMA ready for all places where we do check the
flag. check_stable_address_space can be made to get vma rather than mm.

-- 
Michal Hocko
SUSE Labs
