Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61F6DC04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:06:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EF1520879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:06:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EF1520879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 931D46B0005; Tue, 14 May 2019 17:06:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E1EA6B0006; Tue, 14 May 2019 17:06:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D0E56B0007; Tue, 14 May 2019 17:06:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 465776B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:06:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d7so318474pgc.8
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:06:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=h/9GWAD+PPT8SCoW1bambdWmBDsCkaFfMf6u86UHsJQ=;
        b=AZD5uevZU6FEifmwrDCgC29BowyilZi1H9xhESQRg6NiUk08VmCB9MVmpl/5QZtB0o
         HXDQAwvPTF9HAGctxj3cCjWLB2X9SnMp7rEAFYCMBCI/q3jZsBvYzcMk5HkrBj8Dx5N4
         nsJBukWw0C2tcTqSVQ7R/xAS+7F7tprzurQmhkdU66oHSL9TV0Ui3yXUgr7X1EL0Jq4p
         6TJoSKkrQaSzN0bCB71qChRqRyLxEtQpWxQc0wbNHTv8KsyNxFQdWSBCARXC+OjJP8u1
         KV/gAgOTd+oruprTqpwxLzOMxz3eJn12pRxfzEGWFW8Lut3fUFSF8T6Zd3H+ZRGZ9fx5
         3vZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWjo73+/4coB05enu7zlTCKDoAfh5jZGKcpP4BFhS+AsiRS0yiH
	XPtHxw00kbRpAf0QhPLNtgf2gBdtN+oYxDKsRM8hmQeuNqyXt7fRPvfWkhuIFZ8TIQ7hlPzLLut
	3lM7B4TFRpBRp14pstxmA4w/G7VnRb8mGiaWzfNF8Qn8pXsA9B+pLtQK/uJ9ptLjSrQ==
X-Received: by 2002:a17:902:694b:: with SMTP id k11mr40219499plt.307.1557867964937;
        Tue, 14 May 2019 14:06:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQdFWm5Uu8rj3KetNngsaWIbr6UO0NY3NzJBIPPvEB49iqUn58bMZsYvuz1pl7aHp8zzDI
X-Received: by 2002:a17:902:694b:: with SMTP id k11mr40219425plt.307.1557867964107;
        Tue, 14 May 2019 14:06:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557867964; cv=none;
        d=google.com; s=arc-20160816;
        b=LMv/IkfsuchfhmQhLXtpWsaCbb6VN5VeeiWIKTRMnDv3S5mPKTfuV00PQLxDfsnQGr
         VF7DFFKBo1HaRaauMZct+SSjhISRzRAy1iJTMfehoDv1MRe8jozGmJb0L3/lMCWkHiXs
         8+XeAdsDmq9zNPW6seW711mkgVhJp6TQF9p1LMwS2YLCxrVk/5DY3lHIkWvX3ambSHLs
         xlQj/NL2jTYIM9ujW7UGK6yQn8+6GJ7gUDE7DjwZEWwFvnhlisRqRLiIGedDf6H/BMRW
         IyLBo21FT7FGakNE0c2Hj5tZ+fVO45ANzBgzjw3an/G8fOb82HfSNjnHxs1MEtTs3WHG
         p/ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=h/9GWAD+PPT8SCoW1bambdWmBDsCkaFfMf6u86UHsJQ=;
        b=xEWh1nsVrW017K811AOLGzk3HaTdJrIngaHMWE+vOtAkx6HAqjWwE0kpzF4vT8tZSY
         CIrAoIt+7XaHooYSlV2hBksz2tgIVEUs+cPHuimVChhyHgLuUHXN5i8lPetiZ8Gf7pbb
         8ZYCESEB+wLlqHppH9FNuqe9Ge9CycNPH9mwQrsXXaO5uzbi/7hNaEwOql3kW5haMM2E
         /6zWD710NQc8HoTksEOV6UzoRCmXrP2G2/VKBCt/Wc1ypMlnI0hvblOM3kVgjnfp0XHC
         Zufn9CvzvK57oYWC8LUePgUTyQaj5QCMx6Q9MuQw/NpP7gbQh/VAKyGNVx/HOwHvQ4R7
         GrcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y22si83124pfe.141.2019.05.14.14.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:06:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 May 2019 14:06:03 -0700
X-ExtLoop1: 1
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.36])
  by orsmga006.jf.intel.com with ESMTP; 14 May 2019 14:06:03 -0700
Date: Tue, 14 May 2019 14:06:03 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
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
Message-ID: <20190514210603.GD1977@linux.intel.com>
References: <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net>
 <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net>
 <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
 <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
 <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com>
 <20190514170522.GW2623@hirez.programming.kicks-ass.net>
 <20190514180936.GA1977@linux.intel.com>
 <CALCETrVzbBLokip5n0KEyG6irH6aoEWqyNODTy8embpXhB1GQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVzbBLokip5n0KEyG6irH6aoEWqyNODTy8embpXhB1GQg@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 01:33:21PM -0700, Andy Lutomirski wrote:
> On Tue, May 14, 2019 at 11:09 AM Sean Christopherson
> <sean.j.christopherson@intel.com> wrote:
> > For IRQs it's somewhat feasible, but not for NMIs since NMIs are unblocked
> > on VMX immediately after VM-Exit, i.e. there's no way to prevent an NMI
> > from occuring while KVM's page tables are loaded.
> >
> > Back to Andy's question about enabling IRQs, the answer is "it depends".
> > Exits due to INTR, NMI and #MC are considered high priority and are
> > serviced before re-enabling IRQs and preemption[1].  All other exits are
> > handled after IRQs and preemption are re-enabled.
> >
> > A decent number of exit handlers are quite short, e.g. CPUID, most RDMSR
> > and WRMSR, any event-related exit, etc...  But many exit handlers require
> > significantly longer flows, e.g. EPT violations (page faults) and anything
> > that requires extensive emulation, e.g. nested VMX.  In short, leaving
> > IRQs disabled across all exits is not practical.
> >
> > Before going down the path of figuring out how to handle the corner cases
> > regarding kvm_mm, I think it makes sense to pinpoint exactly what exits
> > are a) in the hot path for the use case (configuration) and b) can be
> > handled fast enough that they can run with IRQs disabled.  Generating that
> > list might allow us to tightly bound the contents of kvm_mm and sidestep
> > many of the corner cases, i.e. select VM-Exits are handle with IRQs
> > disabled using KVM's mm, while "slow" VM-Exits go through the full context
> > switch.
> 
> I suspect that the context switch is a bit of a red herring.  A
> PCID-don't-flush CR3 write is IIRC under 300 cycles.  Sure, it's slow,
> but it's probably minor compared to the full cost of the vm exit.  The
> pain point is kicking the sibling thread.

Speaking of PCIDs, a separate mm for KVM would mean consuming another
ASID, which isn't good.

> When I worked on the PTI stuff, I went to great lengths to never have
> a copy of the vmalloc page tables.  The top-level entry is either
> there or it isn't, so everything is always in sync.  I'm sure it's
> *possible* to populate just part of it for this KVM isolation, but
> it's going to be ugly.  It would be really nice if we could avoid it.
> Unfortunately, this interacts unpleasantly with having the kernel
> stack in there.  We can freely use a different stack (the IRQ stack,
> for example) as long as we don't schedule, but that means we can't run
> preemptable code.
> 
> Another issue is tracing, kprobes, etc -- I don't think anyone will
> like it if a kprobe in KVM either dramatically changes performance by
> triggering isolation exits or by crashing.  So you may need to
> restrict the isolated code to a file that is compiled with tracing off
> and has everything marked NOKPROBE.  Yuck.

Right, and all of the above is largely why I suggested compiling a list
of VM-Exits that "need" preferential treatment.  If the cumulative amount
of code and data that needs to be accessed is tiny, then this might be
feasible.  But if the goal is to be able to do things like handle IRQs
using the KVM mm, ouch.

> I hate to say this, but at what point do we declare that "if you have
> SMT on, you get to keep both pieces, simultaneously!"?

