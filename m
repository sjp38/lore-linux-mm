Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC82CC282CC
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:37:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DA4720844
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:37:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DA4720844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39CAD8E0069; Mon,  4 Feb 2019 18:37:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34B1A8E001C; Mon,  4 Feb 2019 18:37:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23A508E0069; Mon,  4 Feb 2019 18:37:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7A468E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 18:37:35 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id q14so1023145pll.15
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 15:37:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0V5IXxV+W236PsOjKsy3nzd0cOeYKjHat+p/e5219Io=;
        b=oKt6WcOju/ygU6xW+EIuTkdxZNBRUoeAIrrnSAyphSDa5meDGsXj56VIK//cWWbLgK
         ZKudILvMsAfal9jqrSF+Ndqk0d56/Bd3mZO+uoGjIDkv5EvPJFReM4OqSlLaOOKUnYXe
         jirBhXHilYqZXZK2a95BklsqEgunYp3y7/URefJiskVtlfzp2sbQk6Hhm3kRbX9e7BOG
         HqmdWVSKtq3Xzc9SHrHxTzNUlXu3uCBFsO6ho3W1mBKGHCW0NnCE+SE/65lF7TdzfHtY
         MKUiGwTZ1SdRXzsB2Zv9UGqPl0WONoNVFGeXZcTBFY35WqjfBP3ugRJCkH0T1f5ckSqV
         CFYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaTFNnotmBrvQuLyEBGcOb2/UrgVhWpUCgwQwHreY6xtJd2UYIB
	QbtfIbY8zB9qt5mDVXSuygsG2cRK+GVI7Z07RkIl6otANd6aAO84zQh9WLpePNCQ9k0OKUxMvLA
	CJY7w+sYoGJJ243+Jdo0vXykBFTBkbPLmctn7wjN+EqJu2Rteg+UpiouqwWfou7ScwQ==
X-Received: by 2002:a63:5b1f:: with SMTP id p31mr1796496pgb.56.1549323455528;
        Mon, 04 Feb 2019 15:37:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ58gieF4J90PF5qSvgx5DkSGgKPMDAWK0/XGe4uJyYTg+q2OwdJn5oRWOHnpUvpGtMM7cE
X-Received: by 2002:a63:5b1f:: with SMTP id p31mr1796473pgb.56.1549323454746;
        Mon, 04 Feb 2019 15:37:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549323454; cv=none;
        d=google.com; s=arc-20160816;
        b=0P88D5jNvSi0UZlZ7wDvh0EzD+UfxseM2vGqe8safT036QlZkRdPTM5Rp+MXZdhIaY
         8pQ7BKje+q2B0hGIZw0O5xWMhIPCR4b8I+zYIhS6+g0I1UKLTe86YwLUDvM0w6CYooCO
         Y8TUTK06IohE8UztnASmzQfevQG5oIMMUaHRXKwvVCqcQlx/MCswgu91Jk4FXXRlfxQS
         vGFKdy++g0n9FTS4XUtqKg5MqfgLMX0WrEdUC/5boxRvzBiq1FVBFKsZ3GTMgYXhosNt
         Rr6cc4WMM6FszhS8CpI8GuYDi4O+aoEbJNv4leyupnyXvBlcG3vi5f9c3IRDF8CdVrd2
         JUMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=0V5IXxV+W236PsOjKsy3nzd0cOeYKjHat+p/e5219Io=;
        b=S9SxhtNIG1auCbhtZ9jzUsbGVIjjdVkT53xrg2OKKk6wKEEPzTrSJgPLsgd1aPgGe4
         bHNlqgv2QQmi4bP3Kydt3/rHE4rwteG32JgUAjjriScg0l6jYj0aXhVveDkYEeco98AO
         nXDGUtBBkCE2bIpWuBDGJfw57w4C+rYpwvkbjJKaTYFI/awlJ5Mr7mh0gWN9PPkv7DWC
         +2ru/ZA6oeVY3L7elZoBdOVmLguWErZKD82j8HjsifExXO7tfR41Qsk6KaaQD/0lNsi5
         WEURo+nVp1lUNnw1tpwcdTMBH7y41Cw/5XZcW/ZJioo2zzHts5Lq++f2jnSYmiqZVHHN
         9BQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h32si1358409pgh.276.2019.02.04.15.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 15:37:34 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Feb 2019 15:37:34 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,560,1539673200"; 
   d="scan'208";a="123953782"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga003.jf.intel.com with ESMTP; 04 Feb 2019 15:37:33 -0800
Message-ID: <c24dc2351f3dc2f0e0bdf552c6504851e6fa6c06.camel@linux.intel.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nadav Amit <nadav.amit@gmail.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kvm
 list <kvm@vger.kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, X86 ML
 <x86@kernel.org>,  Ingo Molnar <mingo@redhat.com>, bp@alien8.de,
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de, 
 akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 15:37:33 -0800
In-Reply-To: <4E64E8CA-6741-47DF-87DE-88D01B01B15D@gmail.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181552.12095.46287.stgit@localhost.localdomain>
	 <4E64E8CA-6741-47DF-87DE-88D01B01B15D@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-04 at 15:00 -0800, Nadav Amit wrote:
> > On Feb 4, 2019, at 10:15 AM, Alexander Duyck <alexander.duyck@gmail.com> wrote:
> > 
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Add guest support for providing free memory hints to the KVM hypervisor for
> > freed pages huge TLB size or larger. I am restricting the size to
> > huge TLB order and larger because the hypercalls are too expensive to be
> > performing one per 4K page. Using the huge TLB order became the obvious
> > choice for the order to use as it allows us to avoid fragmentation of higher
> > order memory on the host.
> > 
> > I have limited the functionality so that it doesn't work when page
> > poisoning is enabled. I did this because a write to the page after doing an
> > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > cycles to do so.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> > arch/x86/include/asm/page.h |   13 +++++++++++++
> > arch/x86/kernel/kvm.c       |   23 +++++++++++++++++++++++
> > 2 files changed, 36 insertions(+)
> > 
> > diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> > index 7555b48803a8..4487ad7a3385 100644
> > --- a/arch/x86/include/asm/page.h
> > +++ b/arch/x86/include/asm/page.h
> > @@ -18,6 +18,19 @@
> > 
> > struct page;
> > 
> > +#ifdef CONFIG_KVM_GUEST
> > +#include <linux/jump_label.h>
> > +extern struct static_key_false pv_free_page_hint_enabled;
> > +
> > +#define HAVE_ARCH_FREE_PAGE
> > +void __arch_free_page(struct page *page, unsigned int order);
> > +static inline void arch_free_page(struct page *page, unsigned int order)
> > +{
> > +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> > +		__arch_free_page(page, order);
> > +}
> > +#endif
> 
> This patch and the following one assume that only KVM should be able to hook
> to these events. I do not think it is appropriate for __arch_free_page() to
> effectively mean “kvm_guest_free_page()”.
> 
> Is it possible to use the paravirt infrastructure for this feature,
> similarly to other PV features? It is not the best infrastructure, but at least
> it is hypervisor-neutral.

I could probably tie this into the paravirt infrastructure, but if I
did so I would probably want to pull the checks for the page order out
of the KVM specific bits and make it something we handle in the inline.
Doing that I would probably make it a paravirtual hint that only
operates at the PMD level. That way we wouldn't incur the cost of the
paravirt infrastructure at the per 4K page level.

