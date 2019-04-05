Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0100EC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:01:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A131B2175B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:01:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A131B2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CCDD6B0007; Fri,  5 Apr 2019 12:01:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47D026B0008; Fri,  5 Apr 2019 12:01:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FBE86B000D; Fri,  5 Apr 2019 12:01:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E66E56B0007
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 12:01:28 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f7so4459750plr.10
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 09:01:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=qFppwflKV5P3O+G+3tB1I4jdkL4sTYm1jsUoFZ7EOyo=;
        b=bwb6oX5UGs/KkOXmcjsLPMqGcM1f6JdRH2/PMUdOZUEn3LaDk0wwsd53Mt7ws8ju3l
         FLfWGVza3Yj7qMOHpIGaE3wPVTCFq2g8g7XkSOBSL1IJYfuiaJtPMX+kjPaZFDAZFBX/
         KWQxmowTCUnfnCj0XSzv990tqGSa9N0jv9VARgpZAvpdJpTNyaw06kqfbyktskjMQhci
         ylqsY5HclLJtSb5yF8StW97Z5Z8Zx0hSF4wLmzJFWcu8EPcay+4kkZhSkvTWHwj1hv4N
         gZaz+h/6Gm3hT/4YbHz7SP1jnSsSIo1pVfnDKQ6cSnXv1eAIG347bZthdF5v+epwn+8M
         G3Bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXhiA47R3FCYR08Zv7Hh3lnoHzL9otKrzj1Ckdon1RuGNF7O0fo
	8QoljxbCQ+ZD+ZSgBouE7Q4e1kQv0M8PD560I5MYGVocYs+EbSSL2sxAAJKxCkN9eI1Ro4UKynR
	Qaf+EezpFKNg9dQr91ESDVvWVLlfNJN8GzBZvumJq11e34/TjDuNHI8lkELfHu8PPhw==
X-Received: by 2002:aa7:8145:: with SMTP id d5mr13301300pfn.215.1554480088428;
        Fri, 05 Apr 2019 09:01:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmsCmN5SagmpXM0G4j8MrT/07v/gWGzHuOYZy1y0hS3Bthc/6Uhvi9OE4zz849yG5l/MQa
X-Received: by 2002:aa7:8145:: with SMTP id d5mr13301143pfn.215.1554480087278;
        Fri, 05 Apr 2019 09:01:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554480087; cv=none;
        d=google.com; s=arc-20160816;
        b=t92TpwHpaBW9P5BDx65hQpbWFu80HNNFENB5c1vwbHF/ClGwzv6pg3r9zJ2wwDkwh8
         tWKuRXu/CHX3BhKKtP3u9GYGrc1B1QPvuy/2goGXJlfSEDsGfsKaF/+2aIqILMXmcxez
         /nLl/cj9e7YfcFlie7C6dh7rMEjQaV50Vm1GtsFZ/rFXYtJJxpE64NCOjelp4keUyLLb
         TDMlTxgJFGXXa6WGp7P9YCoGYIKDW9ev4DfcMUk2VEtomGIDDuahX1HmVqLf2j4YpT0x
         NthUV8kkOkgK0WziX/+cBK8+jTpHawTMC4sLfNpZixteX8ljBe+9UQhTArFYBpQTSryB
         73UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=qFppwflKV5P3O+G+3tB1I4jdkL4sTYm1jsUoFZ7EOyo=;
        b=XaNIz5/NllEwK/Rib4wQdqYJ5jvXTGUbj9E3dLq+0u7x4X0P13ZXvc99ikLti/VNsg
         e//Xg3bu4U/JL2F9hyi1cTrgsp7SCOPLCDFkWIuslGRDIObnrBB3CjE6c9mlAFlcownT
         9XUTzeTylV6QLJcwvO7HRG743T9NJHRnajQb2Pt76vPE1aOp2e5qWQOLlSmpfHvwueRr
         agfSNhJlCXzEaknRayYey8lzy7zInGozqKUW7xQSo1XyhBX7XCKlec1GGbyqelixOnz0
         aFRiqmQSWhG9Nu8ai9XlUNgdavem9IcQ9JZAm3dPQ5dSdSrAvX2AMWq5opo0yR/xNUod
         O/vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h11si20764068plk.270.2019.04.05.09.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 09:01:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Apr 2019 09:01:26 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,313,1549958400"; 
   d="scan'208";a="128936257"
Received: from skchinnx-mobl.amr.corp.intel.com (HELO [10.254.86.198]) ([10.254.86.198])
  by orsmga007.jf.intel.com with ESMTP; 05 Apr 2019 09:01:23 -0700
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Khalid Aziz
 <khalid.aziz@oracle.com>, Andy Lutomirski <luto@kernel.org>,
 Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>,
 jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
 Kees Cook <keescook@google.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com,
 chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>,
 "Woodhouse, David" <dwmw@amazon.co.uk>,
 Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com,
 Joao Martins <joao.m.martins@oracle.com>, Jim Mattson <jmattson@google.com>,
 pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
 Laura Abbott <labbott@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Aaron Lu <aaron.lu@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
 alexander.h.duyck@linux.intel.com, Amir Goldstein <amir73il@gmail.com>,
 Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com,
 anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
 Ben Hutchings <ben@decadent.org.uk>,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
 Catalin Marinas <catalin.marinas@arm.com>, Jonathan Corbet <corbet@lwn.net>,
 cpandya@codeaurora.org, Daniel Vetter <daniel.vetter@ffwll.ch>,
 Dan Williams <dan.j.williams@intel.com>, Greg KH
 <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, James Morse <james.morse@arm.com>,
 Jann Horn <jannh@google.com>, Juergen Gross <jgross@suse.com>,
 Jiri Kosina <jkosina@suse.cz>, James Morris <jmorris@namei.org>,
 Joe Perches <joe@perches.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
 Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
 Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
 Mark Rutland <mark.rutland@arm.com>, Mel Gorman
 <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>,
 Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
 pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
 richard.weiyang@gmail.com, Rik van Riel <riel@surriel.com>,
 David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>,
 Steven Rostedt <rostedt@goodmis.org>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>,
 Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
 "Serge E. Hallyn" <serge@hallyn.com>, Steve Capper <steve.capper@arm.com>,
 thymovanbeers@gmail.com, Vlastimil Babka <vbabka@suse.cz>,
 Will Deacon <will.deacon@arm.com>, Matthew Wilcox <willy@infradead.org>,
 yaojun8558363@gmail.com, Huang Ying <ying.huang@intel.com>,
 zhangshaokun@hisilicon.com, iommu@lists.linux-foundation.org,
 X86 ML <x86@kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Khalid Aziz <khalid@gonehiking.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com>
 <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
 <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de>
 <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com>
 <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <36b999d4-adf6-08a3-2897-d77b9cba20f8@intel.com>
Date: Fri, 5 Apr 2019 09:01:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/5/19 8:24 AM, Andy Lutomirski wrote:
>> Sounds like we need a mechanism that will do the deferred XPFO TLB 
>> flushes whenever the kernel is entered, and not _just_ at context
>> switch time.  This permits an app to run in userspace with stale
>> kernel TLB entries as long as it wants... that's harmless.
...
> I suppose we could do the flush at context switch *and*
> entry.  I bet that performance still utterly sucks, though — on many
> workloads, this turns every entry into a full flush, and we already
> know exactly how much that sucks — it’s identical to KPTI without
> PCID.  (And yes, if we go this route, we need to merge this logic
> together — we shouldn’t write CR3 twice on entry).

Yeah, probably true.

Just eyeballing this, it would mean mapping the "cpu needs deferred
flush" variable into the cpu_entry_area, which doesn't seem too awful.

I think the basic overall concern is that the deferred flush leaves too
many holes and by the time we close them sufficiently, performance will
suck again.  Seems like a totally valid concern, but my crystal ball is
hazy on whether it will be worth it in the end to many folks

...
> In other words, I think that ret2dir is an insufficient justification
> for XPFO.

Yeah, other things that it is good for have kinda been lost in the
noise.  I think I first started looking at this long before Meltdown and
L1TF were public.

There are hypervisors out there that simply don't (persistently) map
user data.  They can't leak user data because they don't even have
access to it in their virtual address space.  Those hypervisors had a
much easier time with L1TF mitigation than we did.  Basically, they
could flush the L1 after user data was accessible instead of before
untrusted guest code runs.

My hope is that XPFO could provide us similar protection.  But,
somebody's got to poke at it for a while to see how far they can push it.

IMNHO, XPFO is *always* going to be painful for kernel compiles.  But,
cloud providers aren't doing a lot of kernel compiles on their KVM
hosts, and they deeply care about leaking their users' data.

