Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8BAEC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 23:52:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C6FA206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 23:52:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C6FA206C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C4C76B026B; Mon, 10 Jun 2019 19:52:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1509B6B026C; Mon, 10 Jun 2019 19:52:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 016576B026D; Mon, 10 Jun 2019 19:52:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D5C206B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 19:52:05 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id 192so948616itx.2
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 16:52:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=OcZkeUf5/cXX+cTPlBGtkERUCzwzkqjjh03gFMxo+No=;
        b=Uo0re0oX7UxrDHN67nP6dS/qYAcK/1c9bGpeJyy0J6zOlm6kVQ1C1y/VfvkcnMStGB
         t4LxgRFNc4tG9xSyGq+MvEDw8fDKc7m9Wt6XPwKwySS/lTzmrPvZYV5C5LcdeYPoAN99
         PmUZyNJQOC9giUu/5gjoKc0sF32faLgYFI3YRRs8g/MpVIho3cZSwI0Yl6SEhdVKMQIG
         FO7b8YIrUaZI9cjK+GVFqRygXTISdK/A69K1WB8OVBKLZOLOxc8EuyE+J6ruA0vGkM2f
         Nz2Sj3WHIIG4i8DzPO62VCcZR1gIl6eFkRY3H/CklFSIogCMXIEAU/seWfpbJGcjnHc/
         suGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAXDn7m+RsgD8IgrFBYpM9+E3IffjU7DsiP2SWMJtzz6b6SaSGcx
	b3aN0kJHc3stRVk3SpfaGoCaES4OC/ZpJPpH58+RL7RViWVOOICMbatww2wxm6U45FGPjPV4AoB
	41/MA5fc3BZPyptqMgq4IidNWoAiENmP/Zi5rERUqaSlyqnFfxn2gBIs9hO1uA7o8kw==
X-Received: by 2002:a24:5c05:: with SMTP id q5mr16672007itb.110.1560210725601;
        Mon, 10 Jun 2019 16:52:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynmtn/RBxdJeFxYrthnNVXr7aB0F/lAIHNeBeGhSfJ2xqDlknu/uqt5j8EgS885wW5aTtO
X-Received: by 2002:a24:5c05:: with SMTP id q5mr16671977itb.110.1560210724598;
        Mon, 10 Jun 2019 16:52:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560210724; cv=none;
        d=google.com; s=arc-20160816;
        b=nn/CWQX+fvH3adEs4OCZxkZIZxd6ytbaMfsrqSSOK7hgCAahyXysJW9vjsIcjNPVv5
         QXJ1qg4HbKGb58KGD4OtYO34ja834lI5mJYJ51Tf0dWQx8izBa62/i2kC6vuLlCNjtQ5
         jD02Kn/liP3HgfIM5EynTipJEaynx3MDnzDvMPYyTikmBooOS4dFexAE3fAftLB7NKpW
         QVthoQ3oeO6JG7cUn3XZHbkMBdMlBBHSo9HvfMUtXtbUv1ZwLwnTdtxmQS6XRSbabHnb
         hOJor4cAhMheS1aFuH69ees1cwJ2FyUJSShPeDcrHiELAunAkOAmLjMwhx86vxuIrPjZ
         MDcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=OcZkeUf5/cXX+cTPlBGtkERUCzwzkqjjh03gFMxo+No=;
        b=PZ/UAAu3Hn+cwqi7MJKB0IOMJLdms1gDQgWdLHiW1mC3DnHaBCamtBESgAeYe8aj8Z
         gZzmdxSLcIUmyUlZfTcgnL5ekWiIPwI7pTe5P3PxDD7nGrZ2SgRfcF8tN/XdScwb+WNk
         Cwq0hpTEOx9wscgc/rJXsM2ksEGkWPFK7gyHKtClsB26DQ7j60lMIu35Cxis19LbTwZW
         WlQEV4NDBa4d/VtvExBsjUEqY7dsX7ijWOyMRbuUsGb1x7ta/uHua6rvGXg6E37nQDgn
         lF6H7AAPywSwfqjWIr0Iy6bxS2nuxD33A4CfyLzJZLHwwf410XXrMimsVqS8Px90XkX2
         OZXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id o83si589422itc.97.2019.06.10.16.52.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 16:52:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x5ANpjra015106
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 11 Jun 2019 08:51:45 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5ANpj1a007816;
	Tue, 11 Jun 2019 08:51:45 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5ANpDXZ009406;
	Tue, 11 Jun 2019 08:51:45 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-5840663; Tue, 11 Jun 2019 08:50:39 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0319.002; Tue,
 11 Jun 2019 08:50:39 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: Wanpeng Li <kernellwp@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>,
        Andrew Morton <akpm@linux-foundation.org>,
        Punit Agrawal <punit.agrawal@arm.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "Michal Hocko" <mhocko@kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Anshuman Khandual <khandual@linux.vnet.ibm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        kvm <kvm@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>,
        Xiao Guangrong <xiaoguangrong@tencent.com>,
        "lidongchen@tencent.com" <lidongchen@tencent.com>,
        "yongkaiwu@tencent.com" <yongkaiwu@tencent.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB
 hugepage
Thread-Topic: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB
 hugepage
Thread-Index: AQHVFnaoUuMkT7+k5kKGu78GtXiXKKaVCtaA
Date: Mon, 10 Jun 2019 23:50:38 +0000
Message-ID: <20190610235045.GB30991@hori.linux.bs1.fc.nec.co.jp>
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
 <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
 <20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
 <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
 <20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
 <87wozhvc49.fsf@concordia.ellerman.id.au>
 <e673f38a-9e5f-21f6-421b-b3cb4ff02e91@oracle.com>
 <CANRm+CxAgWVv5aVzQ0wdP_A7QQgqfy7nN_SxyaactG7Mnqfr2A@mail.gmail.com>
 <f79d828c-b0b4-8a20-c316-a13430cfb13c@oracle.com>
In-Reply-To: <f79d828c-b0b4-8a20-c316-a13430cfb13c@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D93DB5550526EC4A8EA7D6EFB4444954@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 04:31:01PM -0700, Mike Kravetz wrote:
> On 5/28/19 2:49 AM, Wanpeng Li wrote:
> > Cc Paolo,
> > Hi all,
> > On Wed, 14 Feb 2018 at 06:34, Mike Kravetz <mike.kravetz@oracle.com> wr=
ote:
> >>
> >> On 02/12/2018 06:48 PM, Michael Ellerman wrote:
> >>> Andrew Morton <akpm@linux-foundation.org> writes:
> >>>
> >>>> On Thu, 08 Feb 2018 12:30:45 +0000 Punit Agrawal <punit.agrawal@arm.=
com> wrote:
> >>>>
> >>>>>>
> >>>>>> So I don't think that the above test result means that errors are =
properly
> >>>>>> handled, and the proposed patch should help for arm64.
> >>>>>
> >>>>> Although, the deviation of pud_huge() avoids a kernel crash the cod=
e
> >>>>> would be easier to maintain and reason about if arm64 helpers are
> >>>>> consistent with expectations by core code.
> >>>>>
> >>>>> I'll look to update the arm64 helpers once this patch gets merged. =
But
> >>>>> it would be helpful if there was a clear expression of semantics fo=
r
> >>>>> pud_huge() for various cases. Is there any version that can be used=
 as
> >>>>> reference?
> >>>>
> >>>> Is that an ack or tested-by?
> >>>>
> >>>> Mike keeps plaintively asking the powerpc developers to take a look,
> >>>> but they remain steadfastly in hiding.
> >>>
> >>> Cc'ing linuxppc-dev is always a good idea :)
> >>>
> >>
> >> Thanks Michael,
> >>
> >> I was mostly concerned about use cases for soft/hard offline of huge p=
ages
> >> larger than PMD_SIZE on powerpc.  I know that powerpc supports PGD_SIZ=
E
> >> huge pages, and soft/hard offline support was specifically added for t=
his.
> >> See, 94310cbcaa3c "mm/madvise: enable (soft|hard) offline of HugeTLB p=
ages
> >> at PGD level"
> >>
> >> This patch will disable that functionality.  So, at a minimum this is =
a
> >> 'heads up'.  If there are actual use cases that depend on this, then m=
ore
> >> work/discussions will need to happen.  From the e-mail thread on PGD_S=
IZE
> >> support, I can not tell if there is a real use case or this is just a
> >> 'nice to have'.
> >=20
> > 1GB hugetlbfs pages are used by DPDK and VMs in cloud deployment, we
> > encounter gup_pud_range() panic several times in product environment.
> > Is there any plan to reenable and fix arch codes?
>=20
> I too am aware of slightly more interest in 1G huge pages.  Suspect that =
as
> Intel MMU capacity increases to handle more TLB entries there will be mor=
e
> and more interest.
>=20
> Personally, I am not looking at this issue.  Perhaps Naoya will comment a=
s
> he know most about this code.

Thanks for forwarding this to me, I'm feeling that memory error handling
on 1GB hugepage is demanded as real use case.

>=20
> > In addition, https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/l=
inux.git/tree/arch/x86/kvm/mmu.c#n3213
> > The memory in guest can be 1GB/2MB/4K, though the host-backed memory
> > are 1GB hugetlbfs pages, after above PUD panic is fixed,
> > try_to_unmap() which is called in MCA recovery path will mark the PUD
> > hwpoison entry. The guest will vmexit and retry endlessly when
> > accessing any memory in the guest which is backed by this 1GB poisoned
> > hugetlbfs page. We have a plan to split this 1GB hugetblfs page by 2MB
> > hugetlbfs pages/4KB pages, maybe file remap to a virtual address range
> > which is 2MB/4KB page granularity, also split the KVM MMU 1GB SPTE
> > into 2MB/4KB and mark the offensive SPTE w/ a hwpoison flag, a sigbus
> > will be delivered to VM at page fault next time for the offensive
> > SPTE. Is this proposal acceptable?
>=20
> I am not sure of the error handling design, but this does sound reasonabl=
e.

I agree that that's better.

> That block of code which potentially dissolves a huge page on memory erro=
r
> is hard to understand and I'm not sure if that is even the 'normal'
> functionality.  Certainly, we would hate to waste/poison an entire 1G pag=
e
> for an error on a small subsection.

Yes, that's not practical, so we need at first establish the code base for
2GB hugetlb splitting and then extending it to 1GB next.

Thanks,
Naoya Horiguchi=

