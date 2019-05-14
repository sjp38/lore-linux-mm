Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31C70C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 18:09:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA86820850
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 18:09:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA86820850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39B816B0005; Tue, 14 May 2019 14:09:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34BE56B0006; Tue, 14 May 2019 14:09:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23AD56B0007; Tue, 14 May 2019 14:09:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE5F96B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 14:09:52 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h7so971608pfq.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 11:09:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3UQS2XHTdSVGwXYnTPVMo1tYEHcx2ClEg4W90yUXbmw=;
        b=iN/DhgAUbnAqcQjWqA8rix/r2OJJnTRqL2y4QF/r9+VCPKMeZ1s+GzOicKnEHTbkBG
         KBSMX4Z/5FWStXXNPCHdmVXbhZeixAYnr2BvBZF49DiOoClTA0VweB6sENUbZcisKd8F
         IRXfFJ/lUZQ0mdeZyeXDDBaNNwwYeG6nRdhOHPORMZtk4H6xW3iOZe3nGPaGLXS0jfP5
         2LTHcu8HhQwDuWHHLODUbQZEtD9/+ZKh7+x7xPmLwE6skYuCDiV7/Qe4YAMVaBg8BI8y
         vTj+V0FYTGnd2ZkjcrTH/y23tuDG/YBNXmbr6BVKdDEOJZzJlV3faVGPs1bYcT05EaRu
         lfRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVDwUuNyRCFGDAl9ehOlP0XX6gddGaBEBiNsiIk1WPzHnSBqrHQ
	MZy63wNszI24Pdub4TlYG5qB8UygF4r1rzFCK9RD9BdMBkQpq+YTD5RxfjF8YFbAQiv7Aa+vn/r
	/idpvhVmcGOUgbI7knfy8lPhLYaN2Vr7af8jccINUr+DXwVOhq+99D7eZeiHOvYtMqw==
X-Received: by 2002:a62:4859:: with SMTP id v86mr12835146pfa.237.1557857392457;
        Tue, 14 May 2019 11:09:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylUUtmmrsCsNcpjks97Dbar3yb95c/vDrgXvFISh1BX4nM0mWPUQ38sj5DnubWv9Q8UkhO
X-Received: by 2002:a62:4859:: with SMTP id v86mr12835081pfa.237.1557857391610;
        Tue, 14 May 2019 11:09:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557857391; cv=none;
        d=google.com; s=arc-20160816;
        b=s7bhdJN8NevPaxpgjrpt2OB/u/3yI39GgkUjqP9p4iAIx/ntXqpy9Jg26vrEgoZY6s
         E6/UOQIAfASb18Ux7SKrlnIMhTcwqG1M7Ec+4oS8uDEfD5l9/1hDoRutUWWAL8jJoUUD
         4y0f0nnku5efEKZ/H6nFyhWNKi0y+52jSUfTR1jEgov43/vIaq6Enb5FZc0uVctNRrZG
         T1pKHxlw+hRThqNnw+dtVwLDdTRaaTWUDAdJ9HzJIU17Tc49UJzQ2GClfR/yTCir4KUx
         VnnymNBjpgju2DcSqyLBKwTCjArWzjPohhXIQwCfQePGpPYWTT4uGqkGYgdL0mBqtU+n
         gkwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3UQS2XHTdSVGwXYnTPVMo1tYEHcx2ClEg4W90yUXbmw=;
        b=XPYqTcD7RPsN7jRRUYp+rKpXO2oW33+BwPmwvmBh1BUz7UEyZzzchfGBTXc2RZakWM
         bDPEfv8Z5oX+wcnUthDn9YsXnucfKRc2+XHgfNJWBJLtFcTscjma4fra6H9MprrPl54C
         AyDce+xekXPo73KT8+N1ofjmxdWDzfJmJm7mRxk2X6vXHK/vtdOwsVLECPjuD3bJEGOV
         Pa/7cwpfBWwY+oA6dp/yGuTNz6+h2M4fXnvV3iGtsfORUc98GDeDGrK/UtnThSPb30G8
         hvK+BHLCThXSRXow90usibiQqztMJQAqFhI03aPFu9+eNuFpVe0pgK4ykWUhrcYGb6i5
         eQJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x3si21808548plb.347.2019.05.14.11.09.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 11:09:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 May 2019 11:09:50 -0700
X-ExtLoop1: 1
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.36])
  by orsmga007.jf.intel.com with ESMTP; 14 May 2019 11:09:50 -0700
Date: Tue, 14 May 2019 11:09:36 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
	Andy Lutomirski <luto@kernel.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
	Jonathan Adams <jwadams@google.com>
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
Message-ID: <20190514180936.GA1977@linux.intel.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net>
 <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net>
 <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
 <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
 <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com>
 <20190514170522.GW2623@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514170522.GW2623@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 07:05:22PM +0200, Peter Zijlstra wrote:
> On Tue, May 14, 2019 at 06:24:48PM +0200, Alexandre Chartre wrote:
> > On 5/14/19 5:23 PM, Andy Lutomirski wrote:
> 
> > > How important is the ability to enable IRQs while running with the KVM
> > > page tables?
> > > 
> > 
> > I can't say, I would need to check but we probably need IRQs at least for
> > some timers. Sounds like you would really prefer IRQs to be disabled.
> > 
> 
> I think what amluto is getting at, is:
> 
> again:
> 	local_irq_disable();
> 	switch_to_kvm_mm();
> 	/* do very little -- (A) */
> 	VMEnter()
> 
> 		/* runs as guest */
> 
> 	/* IRQ happens */
> 	WMExit()
> 	/* inspect exit raisin */
> 	if (/* IRQ pending */) {
> 		switch_from_kvm_mm();
> 		local_irq_restore();
> 		goto again;
> 	}
> 
> 
> but I don't know anything about VMX/SVM at all, so the above might not
> be feasible, specifically I read something about how VMX allows NMIs
> where SVM did not somewhere around (A) -- or something like that,
> earlier in this thread.

For IRQs it's somewhat feasible, but not for NMIs since NMIs are unblocked
on VMX immediately after VM-Exit, i.e. there's no way to prevent an NMI
from occuring while KVM's page tables are loaded.

Back to Andy's question about enabling IRQs, the answer is "it depends".
Exits due to INTR, NMI and #MC are considered high priority and are
serviced before re-enabling IRQs and preemption[1].  All other exits are
handled after IRQs and preemption are re-enabled.

A decent number of exit handlers are quite short, e.g. CPUID, most RDMSR
and WRMSR, any event-related exit, etc...  But many exit handlers require 
significantly longer flows, e.g. EPT violations (page faults) and anything
that requires extensive emulation, e.g. nested VMX.  In short, leaving
IRQs disabled across all exits is not practical.

Before going down the path of figuring out how to handle the corner cases
regarding kvm_mm, I think it makes sense to pinpoint exactly what exits
are a) in the hot path for the use case (configuration) and b) can be
handled fast enough that they can run with IRQs disabled.  Generating that
list might allow us to tightly bound the contents of kvm_mm and sidestep
many of the corner cases, i.e. select VM-Exits are handle with IRQs
disabled using KVM's mm, while "slow" VM-Exits go through the full context
switch.

[1] Technically, IRQs are actually enabled when SVM services INTR.  SVM
    hardware doesn't acknowledge the INTR/NMI on VM-Exit, but rather keeps
    it pending until the event is unblocked, e.g. servicing a VM-Exit due
    to an INTR is simply a matter of enabling IRQs.

