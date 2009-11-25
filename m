Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E0F816B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 08:20:34 -0500 (EST)
Date: Wed, 25 Nov 2009 15:20:14 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v2 09/12] Retry fault before vmentry
Message-ID: <20091125132014.GO2999@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
 <1258985167-29178-10-git-send-email-gleb@redhat.com>
 <4B0D2C90.2060200@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B0D2C90.2060200@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 25, 2009 at 03:09:36PM +0200, Avi Kivity wrote:
> On 11/23/2009 04:06 PM, Gleb Natapov wrote:
> >When page is swapped in it is mapped into guest memory only after guest
> >tries to access it again and generate another fault. To save this fault
> >we can map it immediately since we know that guest is going to access
> >the page.
> >
> >
> >-static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
> >+static int tdp_page_fault(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gpa,
> >  				u32 error_code)
> >  {
> >  	pfn_t pfn;
> >@@ -2230,7 +2233,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
> >  	mmu_seq = vcpu->kvm->mmu_notifier_seq;
> >  	smp_rmb();
> >
> >-	if (can_do_async_pf(vcpu)) {
> >+	if (cr3 == vcpu->arch.cr3&&  can_do_async_pf(vcpu)) {
> 
> Why check cr3 here?
> 
If cr3 == vcpu->arch.cr3 here we know that this is guest generated page
fault so we try to do it async. Otherwise this is async page fault code
try to establish mapping, so need to go through async logic.
Theoretically page that was just swapped in can be swapped out once again at
this point and in this case we need to go to sleep here otherwise things
may go wrong.

> >-static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
> >+static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t addr,
> >  			       u32 error_code)
> 
> I'd be slightly happier if we had a page_fault_other_cr3() op that
> switched cr3, called the original, then switched back (the tdp
> version need not change anything).
> 
> -- 
> error compiling committee.c: too many arguments to function

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
