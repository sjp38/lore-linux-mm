Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CCE6C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:56:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D47112184B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:56:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="SlpVczIJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D47112184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 595386B0007; Fri,  5 Apr 2019 11:56:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51D526B0008; Fri,  5 Apr 2019 11:56:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 370956B000D; Fri,  5 Apr 2019 11:56:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FAA96B0007
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 11:56:12 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id x9so4719487ybj.7
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 08:56:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ID62lT7CASQ5exKZNTIxim8rPMV7b2wqTWy85yy70pY=;
        b=Gtc0HdjhiMRH6BvgWe1ifFMh/GAWdzJ6yuST4dRSgb4W33N5G98zqlsWIgbSCJNC7P
         Telu5R4aKALoiRt9yEgRYZ7xdywOWDe9t5EP7vEmkdgedOFBcWk29D7qpKkwrKCDkGYk
         IXnSAU5P+e4TNflMAg7AYGBtB9HKKXV/UmrxNDtQK+FLUPkJhr3spFGt/RkypH3Z4ELN
         ufk+RnA5uYdBdG+Wyefzp4pav67mAjSFZIpQYyAbVz/iBW+z98lFOW7p4YF1s8OUh1f+
         EwuH79rhPzqnj4tn3yp5gSR6mMowjiYzsCEWpx1l/J8k5pEtYRx86/ZinMDLaNVn7HXB
         eW5g==
X-Gm-Message-State: APjAAAWXbJiDCYp7fSbZ4zGMtb0Q8tJCXAwTdC3MhflkAUeAJveNmQuw
	8/PFEihtM21X68guUf0mfRx/E4yS458rx0iJ85Zfjz441wF8gyEGaSJS7VC7JmlGyCNngFBmNAO
	aS2Y5ndgEZs43ejwoXKLNa7iUugrOHHs24PWoh6TUMinDJ8A7tq+2sV0Eivx0zXS0cg==
X-Received: by 2002:a25:2317:: with SMTP id j23mr11637957ybj.122.1554479771367;
        Fri, 05 Apr 2019 08:56:11 -0700 (PDT)
X-Received: by 2002:a25:2317:: with SMTP id j23mr11637898ybj.122.1554479770590;
        Fri, 05 Apr 2019 08:56:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554479770; cv=none;
        d=google.com; s=arc-20160816;
        b=XCcGiZkjTsEZ7DxKFcnq9uVPpObLsWGdW818VJxFT1cexj2r9D9jkhZlOihXulGm/7
         ytb51S7OJgn4Ub1wwI6HRdkEROweTkGjxBSmhz9XB3/nwvQs44UUOctSrz8f9/mu7VOf
         qJ9oVCs5D3jllWQIONMOPBAZtS3fmfhL8MGqLbtFQ3Ev2N1LF887ciBjg0iRLnsQErqR
         ttrI+js/pC74hhqJDjeAmwOTw8eHPPt80Lccw0nYnXQu9SaSwC1VIoPnddRY8UbPchmW
         7tsj13xQaX7DzHX2rztbHOauXGRRrr7FESiuF23nDRmerD+3H1HeB8Si9rq4GoWEvbX9
         WxWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ID62lT7CASQ5exKZNTIxim8rPMV7b2wqTWy85yy70pY=;
        b=sfz1EEk0131wOMdyMez72ENEi0w0c5xCnNDRIdIRBO3frva75SXeZABzOTMVH2KGph
         gqf2wSJxTSzzMJu3Vyj7qdcpnjjsXgI8AfD30IfJ9Xkw67YOwLqs0Y833VmSONO6QXkr
         qcrhMpnBDypEV8tcXB9U6j07ACrajFmzzBHRdLUcUpdgnT55nEJ2ibGjS5VHBEBLGwCR
         GvIRReXLoMPEuIX/fVvOnHgWtVIAPipgxCIFpL+erWC9VF1w9h4NBv1+KXlYr+TQYdur
         TEFWQ1x0iUfzLNpgzae7g7OQ9wZ908EPvwwXZvJWN9G/0HgnAQ7zcJZI/b64/GmNg0RX
         69hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=SlpVczIJ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j136sor8234453ywj.10.2019.04.05.08.56.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 08:56:10 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=SlpVczIJ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=ID62lT7CASQ5exKZNTIxim8rPMV7b2wqTWy85yy70pY=;
        b=SlpVczIJK4+1H51yrIy2XZfnWYtmEO8C77COIGAPUsvrvhaEM0m8FRrKyBqnM6gFHh
         F3pKmsq85ALP71H/Hr7DfbZ8ERn5miX69yKlGBvznyK7Oykz4AisHBQBGcsxJcUG3e8V
         Y9GcKXwN2Jft4Hs79HORZFiCCnnWZdcsXFw/K5B9RrtuKxwW38YvRvETy8pZArliOfSF
         Iujj9qL/OF1qJg9m9Y9O8zweIiE3YhQsn0MVqk0fLSK+F84epR/kbKkAlRlnk163SPa6
         gFJAQgCbFTOMEKLtMia6TzIf49M1a/iPDjXt7LlNXym4YY3YruwJ488KnrSc1wwqL85q
         /img==
X-Google-Smtp-Source: APXvYqwxZtHhbIF6A9Haj7ZQVMb9g3SIesRmO9UXkoy0Zl2crMaGtC7JfWk4iUGJpTgrcq4z6Txlcw==
X-Received: by 2002:a81:69d5:: with SMTP id e204mr11030566ywc.267.1554479769927;
        Fri, 05 Apr 2019 08:56:09 -0700 (PDT)
Received: from cisco ([2601:282:901:dd7b:38ae:7ccc:265c:2d2c])
        by smtp.gmail.com with ESMTPSA id z193sm7435775ywa.70.2019.04.05.08.56.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Apr 2019 08:56:08 -0700 (PDT)
Date: Fri, 5 Apr 2019 09:56:03 -0600
From: Tycho Andersen <tycho@tycho.ws>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andy Lutomirski <luto@kernel.org>,
	Juerg Haefliger <juergh@gmail.com>, jsteckli@amazon.de,
	Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
	Kees Cook <keescook@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
	Tyler Hicks <tyhicks@canonical.com>,
	"Woodhouse, David" <dwmw@amazon.co.uk>,
	Andrew Cooper <andrew.cooper3@citrix.com>,
	Jon Masters <jcm@redhat.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	kanth.ghatraju@oracle.com, Joao Martins <joao.m.martins@oracle.com>,
	Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
	John Haxby <john.haxby@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
	Laura Abbott <labbott@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Aaron Lu <aaron.lu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	alexander.h.duyck@linux.intel.com,
	Amir Goldstein <amir73il@gmail.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
	Ben Hutchings <ben@decadent.org.uk>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
	Catalin Marinas <catalin.marinas@arm.com>,
	Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	James Morse <james.morse@arm.com>, Jann Horn <jannh@google.com>,
	Juergen Gross <jgross@suse.com>, Jiri Kosina <jkosina@suse.cz>,
	James Morris <jmorris@namei.org>, Joe Perches <joe@perches.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
	Mark Rutland <mark.rutland@arm.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michal Hocko <mhocko@suse.com>, Michal Hocko <mhocko@suse.cz>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Ingo Molnar <mingo@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
	richard.weiyang@gmail.com, Rik van Riel <riel@surriel.com>,
	David Rientjes <rientjes@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Steve Capper <steve.capper@arm.com>, thymovanbeers@gmail.com,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will.deacon@arm.com>,
	Matthew Wilcox <willy@infradead.org>, yaojun8558363@gmail.com,
	Huang Ying <ying.huang@intel.com>, zhangshaokun@hisilicon.com,
	iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
Message-ID: <20190405155603.GA12463@cisco>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com>
 <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
 <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de>
 <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com>
 <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 09:24:50AM -0600, Andy Lutomirski wrote:
> 
> 
> > On Apr 5, 2019, at 8:44 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> > 
> > On 4/5/19 12:17 AM, Thomas Gleixner wrote:
> >>> process. Is that an acceptable trade-off?
> >> You are not seriously asking whether creating a user controllable ret2dir
> >> attack window is a acceptable trade-off? April 1st was a few days ago.
> > 
> > Well, let's not forget that this set at least takes us from "always
> > vulnerable to ret2dir" to a choice between:
> > 
> > 1. fast-ish and "vulnerable to ret2dir for a user-controllable window"
> > 2. slow and "mitigated against ret2dir"
> > 
> > Sounds like we need a mechanism that will do the deferred XPFO TLB
> > flushes whenever the kernel is entered, and not _just_ at context switch
> > time.  This permits an app to run in userspace with stale kernel TLB
> > entries as long as it wants... that's harmless.
> 
> I don’t think this is good enough. The bad guys can enter the kernel and arrange for the kernel to wait, *in kernel*, for long enough to set up the attack.  userfaultfd is the most obvious way, but there are plenty. I suppose we could do the flush at context switch *and* entry.  I bet that performance still utterly sucks, though — on many workloads, this turns every entry into a full flush, and we already know exactly how much that sucks — it’s identical to KPTI without PCID.  (And yes, if we go this route, we need to merge this logic together — we shouldn’t write CR3 twice on entry).
> 
> I feel like this whole approach is misguided. ret2dir is not such a game changer that fixing it is worth huge slowdowns. I think all this effort should be spent on some kind of sensible CFI. For example, we should be able to mostly squash ret2anything by inserting a check that the high bits of RSP match the value on the top of the stack before any code that pops RSP.  On an FPO build, there aren’t all that many hot POP RSP instructions, I think.
> 
> (Actually, checking the bits is suboptimal. Do:
> 
> unsigned long offset = *rsp - rsp;
> offset >>= THREAD_SHIFT;
> if (unlikely(offset))
> BUG();
> POP RSP;

This is a neat trick, and definitely prevents going random places in
the heap. But,

> This means that it’s also impossible to trick a function to return into a buffer that is on that function’s stack.)

Why is this true? All you're checking is that you can't shift the
"location" of the stack. If you can inject stuff into a stack buffer,
can't you just inject the right frame to return to your code as well,
so you don't have to shift locations?

Thanks!

Tycho

