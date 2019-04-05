Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D214CC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:24:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E71221852
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:24:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="NBqRhb6D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E71221852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 202976B000D; Fri,  5 Apr 2019 11:24:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B4516B0269; Fri,  5 Apr 2019 11:24:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02C4B6B026A; Fri,  5 Apr 2019 11:24:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF13B6B000D
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 11:24:55 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q18so4389332pll.16
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 08:24:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=FmlrGnlcnzOaXOwG0WgwsBliBrSjujp1iAaQnWvzoYU=;
        b=gS9XfjJVOjj/WrEfUhtdDpVeBWCKJwN+UKpLoJBB3vdpDjTKsMKn7hylUXSh+Z3MEu
         K8OqoNHElNNB3yvFp88Ddfl/vmOhgf/VJ6pRpULswk3/U210srCU5x33rJsDYIaqIDhM
         bydve+8NoLgjRsXu8nduYE3aSUC8VBbUEBRj/gGW3EjFiOU7wn0YPPcxdkKDZMzaaDpl
         ttPmixW+6JNTZu8Jbk275vNABBBfIjqsqmJ0NhNTEzQEIkSxcOVpnOp7y6+IiIL/lnqR
         9mCUwRLbYiNhU6+ZeDi01CMBng7TnacB7XMcstHJ16h3d/TgnUHnJDl7bbE/PoB4xx6i
         MIQw==
X-Gm-Message-State: APjAAAWTGmQuSczARSEDDDKfMSA8HFHsWlpC/W5y3lXqxDluDTi+EGpo
	uDO3kzV+R+JFK0zgFMs+OHQgc7Vq1be+t4lNn3167ohUqTJjRMYgapsnGptL6bNwEuNIskYnPMJ
	VNQFbVGfStbyQbAkBHhLRZTgC6oarq8DG4b5oSycNulIIn6R9d5VEfiXiT6eLBYM1EQ==
X-Received: by 2002:a65:6105:: with SMTP id z5mr12905148pgu.378.1554477895349;
        Fri, 05 Apr 2019 08:24:55 -0700 (PDT)
X-Received: by 2002:a65:6105:: with SMTP id z5mr12905081pgu.378.1554477894658;
        Fri, 05 Apr 2019 08:24:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554477894; cv=none;
        d=google.com; s=arc-20160816;
        b=gjTjjOypmKnxO/8Ao8jrQTLljwYcQ6YCUmhaMX+/9knUkCyWDRszt80v95ruRnALFZ
         wWwWALRWauLy+uSCjVkTB1D/K1M/losUXTweIEFe5yFCip2a1UDwxnrjknHcW2P5JlmC
         ZZ66TYxR2rNdcARAjAhEzGqAIu3ZkSbve06VihnHAJwFbUg/XqRLaeJe8aY/cyZYdo/y
         ksAov+/b13pfJnUEHFtxhHIY2E8+gmYSgoAaj+3i4GOdMicn7hmNsE0+VtSwiuXBYRlq
         p2eP+adPPfaRT/g/draRrEGe7oTIOJ0WNe3xRHJqM65UduDFI68Do5HN/sMcy68NBb+H
         7N3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=FmlrGnlcnzOaXOwG0WgwsBliBrSjujp1iAaQnWvzoYU=;
        b=Z4zce88HLpcPymGQ4jPB3ve0aZeFB/Ory3fNcHfHI0q6jbEZL6nd0eU5ZwGuBnUQaT
         OeNwODjMaTIvEpmwvfBnr3X6dbJnNm7WJ6B/E4KF0fnHPegBMaaPd0h9Ok/bFHhG51tm
         qJB3Q3Xc1WvjT3oiFUjPlnDGfyWUA4Rbl4AYOjFuW70Xfdi5KkyWwe37yQPBgzMaCVRi
         9GdOhqqjnXqxoO8nwldbxvKJYwdKCbTkedn3byAgCGc3MhaePBdWrW5AIN0V4mwqLvBu
         owjkJOdtgq1lEAKjxLTzrqz8DXM0f2u3/q38xjdXDHgsIDpLPtpOH1gkU5hX7ywHGuax
         yeRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=NBqRhb6D;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor24246090pgv.47.2019.04.05.08.24.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 08:24:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=NBqRhb6D;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=FmlrGnlcnzOaXOwG0WgwsBliBrSjujp1iAaQnWvzoYU=;
        b=NBqRhb6DS4vNUj1PuPBydzkYS3LAQYQhIhx9yAMCmxN65credQ7KTgic8lRf4vjH3e
         fnX6zPmu6Mtq6J0THConhsabMoycJ5KcrywXIHRm2YRVl8H30vyOFAtjLWikgIWKLXa/
         j4inkJRKvQddon6vX6r9Xg66oVpfAyfgqKOXHyi7jWEHl40HbbbfH2nHgtUoh2twrYkD
         fw9OlCSnWwd/cVNP3B34xzS0SwmMr/LtBZ9aNgYcBodSAutqXEnh0u5Mwi8XrGKIgqhK
         WPO7GRN4bV3qrgd6Nhqk9Gc5sYGrvZNngo6cL0iAOyeiQqAHPK4S9oDda1cN4oyVJVIU
         YQ+g==
X-Google-Smtp-Source: APXvYqz6bfaC+cy9ySwZcgCCVqfPOr2v2mH7Fz9R0nQBTjswjnpcsrJEN1MUvuKKZR21XLJqe97wCQ==
X-Received: by 2002:a65:62ce:: with SMTP id m14mr1272543pgv.191.1554477894254;
        Fri, 05 Apr 2019 08:24:54 -0700 (PDT)
Received: from [100.91.160.246] (72.sub-174-208-6.myvzw.com. [174.208.6.72])
        by smtp.gmail.com with ESMTPSA id o76sm59501993pfa.156.2019.04.05.08.24.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 08:24:52 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16D57)
In-Reply-To: <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com>
Date: Fri, 5 Apr 2019 09:24:50 -0600
Cc: Thomas Gleixner <tglx@linutronix.de>,
 Khalid Aziz <khalid.aziz@oracle.com>, Andy Lutomirski <luto@kernel.org>,
 Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>,
 jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
 Kees Cook <keescook@google.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
 Tyler Hicks <tyhicks@canonical.com>,
 "Woodhouse, David" <dwmw@amazon.co.uk>,
 Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com,
 Joao Martins <joao.m.martins@oracle.com>,
 Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
 John Haxby <john.haxby@oracle.com>,
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
Content-Transfer-Encoding: quoted-printable
Message-Id: <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com> <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com> <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com> <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de> <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 5, 2019, at 8:44 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> On 4/5/19 12:17 AM, Thomas Gleixner wrote:
>>> process. Is that an acceptable trade-off?
>> You are not seriously asking whether creating a user controllable ret2dir=

>> attack window is a acceptable trade-off? April 1st was a few days ago.
>=20
> Well, let's not forget that this set at least takes us from "always
> vulnerable to ret2dir" to a choice between:
>=20
> 1. fast-ish and "vulnerable to ret2dir for a user-controllable window"
> 2. slow and "mitigated against ret2dir"
>=20
> Sounds like we need a mechanism that will do the deferred XPFO TLB
> flushes whenever the kernel is entered, and not _just_ at context switch
> time.  This permits an app to run in userspace with stale kernel TLB
> entries as long as it wants... that's harmless.

I don=E2=80=99t think this is good enough. The bad guys can enter the kernel=
 and arrange for the kernel to wait, *in kernel*, for long enough to set up t=
he attack.  userfaultfd is the most obvious way, but there are plenty. I sup=
pose we could do the flush at context switch *and* entry.  I bet that perfor=
mance still utterly sucks, though =E2=80=94 on many workloads, this turns ev=
ery entry into a full flush, and we already know exactly how much that sucks=
 =E2=80=94 it=E2=80=99s identical to KPTI without PCID.  (And yes, if we go t=
his route, we need to merge this logic together =E2=80=94 we shouldn=E2=80=99=
t write CR3 twice on entry).

I feel like this whole approach is misguided. ret2dir is not such a game cha=
nger that fixing it is worth huge slowdowns. I think all this effort should b=
e spent on some kind of sensible CFI. For example, we should be able to most=
ly squash ret2anything by inserting a check that the high bits of RSP match t=
he value on the top of the stack before any code that pops RSP.  On an FPO b=
uild, there aren=E2=80=99t all that many hot POP RSP instructions, I think.

(Actually, checking the bits is suboptimal. Do:

unsigned long offset =3D *rsp - rsp;
offset >>=3D THREAD_SHIFT;
if (unlikely(offset))
BUG();
POP RSP;

This means that it=E2=80=99s also impossible to trick a function to return i=
nto a buffer that is on that function=E2=80=99s stack.)

In other words, I think that ret2dir is an insufficient justification for XP=
FO.=

