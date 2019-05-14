Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8896DC04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 22:38:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3014820873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 22:38:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3014820873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7182C6B0005; Tue, 14 May 2019 18:38:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A1B56B0006; Tue, 14 May 2019 18:38:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 568F76B0007; Tue, 14 May 2019 18:38:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF126B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 18:38:27 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d9so281632pfo.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 15:38:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=OuZ44tiUYD+isdZPI9iQkb7rmvzNlz1oSQ2UPWd5EYQ=;
        b=YrKxi55DMUa4dgLS2AYMOy1d7254tWEfwL24r5fKjExxm/ePYYax+2NyalYDcdWppj
         IMwbSv0n8Wdu/r8bbJm7B5VfeCKZL6uiodsgyx1ePjDjhEQDLELK/2lbt75y0ftTDxho
         nnI789oaT8jFMyGB3kQUm9tfQ1SmZKr/Y368CMx44snUsecIEgqGY6Ke1dBlDISMboc/
         ZYHmF7HbTbNhR+aIOK4+0eeiD2cbxC9RJ7mNdrIckpAThkAqmAcfW7kNmo6EnOmSLCCe
         THfyZKwue0SsxSKh7/Gk8ybn/eQkdtbmJREQ8cUrEesuf4eRIrvLbs9jQ0HrzWLXxQ7Q
         QoLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVPWobJgkZQcexKB6FpKz9RkJDWUV5zKS5H4Vi0CvTS2ZrE0bm5
	EzatKGIVG0JNhrQG1aPySHa8JwXtLnnuwQ9U09xq3UExrrdXhrD7WyDcZDfC9Qf2cl8sFibCiLP
	zQsODVnQIR2SGhlorQvmWRyAgoLcwVXqjcoaThzsFEFde/7rZYsLrdAbbartxJ1nitw==
X-Received: by 2002:a63:b507:: with SMTP id y7mr40644524pge.237.1557873506691;
        Tue, 14 May 2019 15:38:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNlkuI20eQ1vOV699mfr2u7bTv4ucYv0OrZFBPI9UwpNsaK43mGSxNxiTMXz2N6oKn6ct2
X-Received: by 2002:a63:b507:: with SMTP id y7mr40644463pge.237.1557873505770;
        Tue, 14 May 2019 15:38:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557873505; cv=none;
        d=google.com; s=arc-20160816;
        b=LqArlvvVmZTbnSxFcWDrmHLhhKZ7HqH+ieiq5DU9cMJOBlfN1vNbRIYT56yBv0Czaw
         MHUv0C2wqQRHeK0y04/c3fwJqvUXSgAMxdX5Z4i9lFP6k/OexWHboKTvxaa5YVcWP7ZH
         TCgh+Q5jekEZigNnMFt9Ui8pY3cZH2FJgbWcttZX5qPfk6E+Y/RtBhx2e85Jy+t2tutM
         bOa+ObLHpARwsT1vrYu8Up2XJ+eqjva1ZPuuXtZYHbjNK9sZ6uMqceD6ZnmKml84gnyw
         EF13H59j/DYzlY7YGa8MqoznpnOzpMQeg2AGtGnSdVop85mDsUo4XdoD3Frqs8ygzl3v
         wk1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=OuZ44tiUYD+isdZPI9iQkb7rmvzNlz1oSQ2UPWd5EYQ=;
        b=Wt294LhCo8powoRofwHYipcHlT+YRI4hiACAt4XV88kGIN6UK8IB5Ostg/zY6+cZbJ
         Th/7BP6G2X1s0fZLuIXU6v1MvlJwwW8JMgY1mP9YSWDlLeKbC7cJSaoRAPtvFW1g0kX7
         3TBe3/5VYohJ8UiWLi7AaqKNvXlRcF8AhVyVLwfzLGI9Z8FrMynSrWe9S5u+LIDUzEfC
         l03uGmnBBpi12HV3tNGQHv3p7J0afNAEhNaYmIxdzcRPUVFhA8VRNDxztTCYjgVNDc5g
         0qgH6bXR+oVjVLcbkohhEPAOjvR8pA5EepydExXxr4KfFIrBWizQ9mE0giLTys+fYFc9
         ckHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o15si122436pgv.316.2019.05.14.15.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 15:38:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 May 2019 15:38:24 -0700
X-ExtLoop1: 1
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.36])
  by FMSMGA003.fm.intel.com with ESMTP; 14 May 2019 15:38:23 -0700
Date: Tue, 14 May 2019 15:38:23 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
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
Message-ID: <20190514223823.GE1977@linux.intel.com>
References: <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net>
 <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
 <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
 <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com>
 <20190514170522.GW2623@hirez.programming.kicks-ass.net>
 <20190514180936.GA1977@linux.intel.com>
 <CALCETrVzbBLokip5n0KEyG6irH6aoEWqyNODTy8embpXhB1GQg@mail.gmail.com>
 <20190514210603.GD1977@linux.intel.com>
 <A1EB80C0-2D88-4DC0-A898-3BED50A4F5A8@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <A1EB80C0-2D88-4DC0-A898-3BED50A4F5A8@amacapital.net>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 02:55:18PM -0700, Andy Lutomirski wrote:
> 
> > On May 14, 2019, at 2:06 PM, Sean Christopherson <sean.j.christopherson@intel.com> wrote:
> > 
> >> On Tue, May 14, 2019 at 01:33:21PM -0700, Andy Lutomirski wrote:
> >> I suspect that the context switch is a bit of a red herring.  A
> >> PCID-don't-flush CR3 write is IIRC under 300 cycles.  Sure, it's slow,
> >> but it's probably minor compared to the full cost of the vm exit.  The
> >> pain point is kicking the sibling thread.
> > 
> > Speaking of PCIDs, a separate mm for KVM would mean consuming another
> > ASID, which isn't good.
> 
> I’m not sure we care. We have many logical address spaces (two per mm plus a
> few more).  We have 4096 PCIDs, but we only use ten or so.  And we have some
> undocumented number of *physical* ASIDs with some undocumented mechanism by
> which PCID maps to a physical ASID.

Yeah, I was referring to physical ASIDs.

> I don’t suppose you know how many physical ASIDs we have?

Limited number of physical ASIDs.  I'll leave it at that so as not to
disclose something I shouldn't.

> And how it interacts with the VPID stuff?

VPID and PCID get factored into the final ASID, i.e. changing either one
results in a new ASID.  The SDM's oblique way of saying that:

  VPIDs and PCIDs (see Section 4.10.1) can be used concurrently. When this
  is done, the processor associates cached information with both a VPID and
  a PCID. Such information is used only if the current VPID and PCID both
  match those associated with the cached information.

E.g. enabling PTI in both the host and guest consumes four ASIDs just to
run a single task in the guest:

  - VPID=0, PCID=kernel
  - VPID=0, PCID=user
  - VPID=1, PCID=kernel
  - VPID=1, PCID=user

The impact of consuming another ASID for KVM would likely depend on both
the guest and host configurations/worloads, e.g. if the guest is using a
lot of PCIDs then it's probably a moot point.  It's something to keep in
mind though if we go down this path.

