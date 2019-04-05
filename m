Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MIME_QP_LONG_LINE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F95DC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:24:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A92592184B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:24:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="utPoc6PE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A92592184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33C5B6B0008; Fri,  5 Apr 2019 11:24:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EC426B000D; Fri,  5 Apr 2019 11:24:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 165BB6B0269; Fri,  5 Apr 2019 11:24:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD12F6B0008
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 11:24:06 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c7so686178plo.8
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 08:24:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=iGOCAhS0Nh0Q28F4cKGMxEhkILlnQQJc9LLSkn976ag=;
        b=fn4lMikpDMlvWVXu09+ujTT7NpAC2uY2pH4zsv4NrR5F3t5WGuqc9X2NVXBb7zXPms
         00WCcfXU4fyWD7BcZ3TWPzYHort3Nj1/L9u9SImMXGo04r3K9UN09L0ZKsCaXLfP8C5D
         NlWZVrTA6eVBwuKTb1bKw8ysw5le3tQ1HeJW24BKsmvU1QHrDuWVUxZwqEamH5R4z2gh
         /vJ1HGIgDQm3e106t/oRHyOztK/Y6fti/dgiDTsICW2w1No08feYMZlzIeuV0HMAMzKy
         Xnuc534s2EIwMh8Zt6J66BeLY80r7GqxW9Nd2asLaoFsPW5IeBXI54QkB+onfsWPAxl2
         BxzA==
X-Gm-Message-State: APjAAAXnNVvxirtFmQTFq9x0hRPEGuqB+k57Soti8+LpkLG115Bxth7G
	VYxsOn3i5W2HXGUnNNeQwjnfEhaWO8QbMcpG4SOjNjgZkIDfXUGxvYWwmF6IMBGaHj9+yq7jnAq
	iuciyf07HpbGd3afphkIHKECZn6MMzEhbmP/UGruiSHe3PvpdBkjCgN6xHyjTfq6jxQ==
X-Received: by 2002:a63:c40c:: with SMTP id h12mr1589815pgd.39.1554477846193;
        Fri, 05 Apr 2019 08:24:06 -0700 (PDT)
X-Received: by 2002:a63:c40c:: with SMTP id h12mr1589730pgd.39.1554477845030;
        Fri, 05 Apr 2019 08:24:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554477845; cv=none;
        d=google.com; s=arc-20160816;
        b=abZgWKGL1Mu2DvgPVAr02pHoUIUsoJa6iQa4CN/cOibAqO9EPMfqaIwBg++hVWQhx7
         F4yO2O8HFrIK96LE4D4xFk4o3n+klaqKrU58/VjTCweYGGeoz6TJD19YusDMcHfTLMX8
         FL19k1VR9CQfYARk8RLTyKoOo/OyAG5j5nGcFPnkU6Fxub/vyrajvn0T765SiK6qAmM0
         ADY/g2bEpJJ9O5+lEPGUnl/MxIio7YbX16VYyVLYiTpEkhTa8wSnlOpUf2L6klLKOZtd
         zncNZjLeA/I1m5Wds72s9G0YHyX/wUT+FhsYRhZX4j8ZorL8jMHvknimwFrnSeWTfcFs
         T9AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=iGOCAhS0Nh0Q28F4cKGMxEhkILlnQQJc9LLSkn976ag=;
        b=HsnZdKZwOC9YjiaYD/QQ6Eqq8wbq9I17eKwcHmVkMGy6l1oo95oMpcAs712h+r85SC
         Ht1R+Brqifh0V35q8YRtHFPaampd7X5AGs4UH+H0oLQrv4TSV4+Jaoamk/E6WyJr2qkt
         iNskS1qqGnm6PAuOHM7Q2mV3SjIz3vfbES8MXamGKnYVHG3PNL6AWEEGSYHFm5dRzhh5
         A/KreDUJCw9KsSKx0ynhizkdWUSLc+oD9lfRYbWjIAaxyjHEdxcWQ969OdbUfPOrQMem
         9vPoEGIhMqk9EqGKNktUr25Jibc7KlEjsscUQjq/Z7u0R8UWRYgyVb7HeTK7NR9k8JPW
         59YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=utPoc6PE;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g6sor26729349pll.50.2019.04.05.08.24.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 08:24:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=utPoc6PE;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=iGOCAhS0Nh0Q28F4cKGMxEhkILlnQQJc9LLSkn976ag=;
        b=utPoc6PENireic5FOXK/6gNlCZoHxLoVxXvIuWuV2Ldezt4oYNYBwGjH8t1h9Yythn
         NBMHVmJqsQiSSgLDIbxGelGGWG6PTrg17gPXjFFVs/bZNUfjI99ScPHiJH/n5asWnHTE
         pxNdiSFNyO4roPwGN23lMX2Kq+37RTiffPJuFlZpFzZur3TJegpdwYUlgYUr+m2i26gm
         W9XUIX1hCrY/7nA+NUxqTQO7hRs+NL4e2+3/cn/2OjM8JsqZQd2J5vN4EonJXxD2TV7C
         1PoI0If4qTkO1Kw+8RgLoJOuBc910yXQbM/NoefPRHlg97tXtOA6XN1KTxmL8UFx7IdR
         NTyg==
X-Google-Smtp-Source: APXvYqxMP8hSJP5kyoEinr2wbSpbPq5dBS4iQHJvz9gcS8VG3LUoS2p3dEZlZaxIm7Q/ZUuQ39Skcg==
X-Received: by 2002:a17:902:1008:: with SMTP id b8mr13257931pla.120.1554477844312;
        Fri, 05 Apr 2019 08:24:04 -0700 (PDT)
Received: from [100.91.160.246] (72.sub-174-208-6.myvzw.com. [174.208.6.72])
        by smtp.gmail.com with ESMTPSA id w10sm7488981pfi.126.2019.04.05.08.24.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 08:24:03 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16D57)
In-Reply-To: <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
Date: Fri, 5 Apr 2019 09:24:01 -0600
Cc: Andy Lutomirski <luto@kernel.org>, Juerg Haefliger <juergh@gmail.com>,
 Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de,
 Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
 Kees Cook <keescook@google.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
 Tyler Hicks <tyhicks@canonical.com>,
 "Woodhouse, David" <dwmw@amazon.co.uk>,
 Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com,
 Joao Martins <joao.m.martins@oracle.com>,
 Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
 John Haxby <john.haxby@oracle.com>, Thomas Gleixner <tglx@linutronix.de>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
 Laura Abbott <labbott@redhat.com>, Dave Hansen <dave.hansen@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, Aaron Lu <aaron.lu@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 alexander.h.duyck@linux.intel.com, Amir Goldstein <amir73il@gmail.com>,
 Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com,
 anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
 Ben Hutchings <ben@decadent.org.uk>,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
 Catalin Marinas <catalin.marinas@arm.com>,
 Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org,
 Daniel Vetter <daniel.vetter@ffwll.ch>,
 Dan Williams <dan.j.williams@intel.com>,
 Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, James Morse <james.morse@arm.com>,
 Jann Horn <jannh@google.com>, Juergen Gross <jgross@suse.com>,
 Jiri Kosina <jkosina@suse.cz>, James Morris <jmorris@namei.org>,
 Joe Perches <joe@perches.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
 Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
 Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
 Mark Rutland <mark.rutland@arm.com>,
 Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>,
 Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
 pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
 richard.weiyang@gmail.com, Rik van Riel <riel@surriel.com>,
 David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>,
 Steven Rostedt <rostedt@goodmis.org>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 "Serge E. Hallyn" <serge@hallyn.com>, Steve Capper <steve.capper@arm.com>,
 thymovanbeers@gmail.com, Vlastimil Babka <vbabka@suse.cz>,
 Will Deacon <will.deacon@arm.com>, Matthew Wilcox <willy@infradead.org>,
 yaojun8558363@gmail.com, Huang Ying <ying.huang@intel.com>,
 zhangshaokun@hisilicon.com, iommu@lists.linux-foundation.org,
 X86 ML <x86@kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Khalid Aziz <khalid@gonehiking.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <C1253C86-DD1F-469F-9B5E-ED7AA9FBEE4D@amacapital.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com> <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com> <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com>
To: Khalid Aziz <khalid.aziz@oracle.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



>>> On Apr 4, 2019, at 4:55 PM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>>>=20
>>> On 4/3/19 10:10 PM, Andy Lutomirski wrote:
>>> On Wed, Apr 3, 2019 at 10:36 AM Khalid Aziz <khalid.aziz@oracle.com> wro=
te:
>>>=20
>>> XPFO flushes kernel space TLB entries for pages that are now mapped
>>> in userspace on not only the current CPU but also all other CPUs
>>> synchronously. Processes on each core allocating pages causes a
>>> flood of IPI messages to all other cores to flush TLB entries.
>>> Many of these messages are to flush the entire TLB on the core if
>>> the number of entries being flushed from local core exceeds
>>> tlb_single_page_flush_ceiling. The cost of TLB flush caused by
>>> unmapping pages from physmap goes up dramatically on machines with
>>> high core count.
>>>=20
>>> This patch flushes relevant TLB entries for current process or
>>> entire TLB depending upon number of entries for the current CPU
>>> and posts a pending TLB flush on all other CPUs when a page is
>>> unmapped from kernel space and mapped in userspace. Each core
>>> checks the pending TLB flush flag for itself on every context
>>> switch, flushes its TLB if the flag is set and clears it.
>>> This patch potentially aggregates multiple TLB flushes into one.
>>> This has very significant impact especially on machines with large
>>> core counts.
>>=20
>> Why is this a reasonable strategy?
>=20
> Ideally when pages are unmapped from physmap, all CPUs would be sent IPI
> synchronously to flush TLB entry for those pages immediately. This may
> be ideal from correctness and consistency point of view, but it also
> results in IPI storm and repeated TLB flushes on all processors. Any
> time a page is allocated to userspace, we are going to go through this
> and it is very expensive. On a 96-core server, performance degradation
> is 26x!!

Indeed. XPFO is expensive.

>=20
> When xpfo unmaps a page from physmap only (after mapping the page in
> userspace in response to an allocation request from userspace) on one
> processor, there is a small window of opportunity for ret2dir attack on
> other cpus until the TLB entry in physmap for the unmapped pages on
> other cpus is cleared.

Why do you think this window is small? Intervals of seconds to months betwee=
n context switches aren=E2=80=99t unheard of.

And why is a small window like this even helpful?  For a ret2dir attack, you=
 just need to get CPU A to allocate a page and write the ret2dir payload and=
 then get CPU B to return to it before context switching.  This should be do=
able quite reliably.

So I don=E2=80=99t really have a suggestion, but I think that a 44% regressi=
on to get a weak defense like this doesn=E2=80=99t seem worthwhile.  I bet t=
hat any of a number of CFI techniques (RAP-like or otherwise) will be cheape=
r and protect against ret2dir better.  And they=E2=80=99ll also protect agai=
nst using other kernel memory as a stack buffer.  There are plenty of those =E2=
=80=94 think pipe buffers, network buffers, any page cache not covered by XP=
FO, XMM/YMM saved state, etc.=

