Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E740DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:13:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79A9D21925
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:13:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79A9D21925
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F21FF8E0002; Fri, 15 Feb 2019 04:13:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED1458E0001; Fri, 15 Feb 2019 04:13:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBED08E0002; Fri, 15 Feb 2019 04:13:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE688E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 04:13:11 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h70so7043957pfd.11
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 01:13:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=juFHqzeKfwBJva52CybdDJ7ojpRQMEPZc12GIizILx4=;
        b=GNijkivNQfB3ST1Op1IxylbuyS+cXcZf5ZpVwfWJ5uOOAUe+mt8UIPTQkCNp0+wgGQ
         uft5usi9pgLvKnL9aLvJ+ohAw2jFoec19bZlgXdKPg2vukQBKSMjlxl4Mc/qbGxPCrRC
         fXo3Fr/a4EK9Zq2ztgruee++53Qu3weh6RY8DynkpoMC80D7bKikRpGCsWiLkeCYp1lr
         +47FUJgETqN6OsoDaEFG7/hj+uilyCMB7IlX2ORvKoRcq9627U3MhhNl0KUbAgUewg8C
         ugXPo1+jFvpt9KwrqlCasPFneEOAz8HfyJdBN0Uy/ZcTURA+pOU0y5Hxs1vCWAvvI+EZ
         Mf9g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuaNmYYivMtmRQ8w4EoeXXz0NFKgeD1amwpdEacLQJkYOkKn0M8s
	3XyNEOxp5wE0w555w6KzeXycI+cyR2MPAQy892c4C/it4IkLBatBuXy1Ct4JpFOXfMUumgIFQk2
	FgUr7r6rMqPbo223NCOl7hj8QZA6uiU63YSWudMx5WQEpNhbHhFkGm8Cf+UooaNk=
X-Received: by 2002:a63:f241:: with SMTP id d1mr4464779pgk.2.1550221991283;
        Fri, 15 Feb 2019 01:13:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbKoiMNAPh/REh3w5GxGNzyjMwsM5ztQClOOgyxSDON8MNKfyWEIagBQXjkXiV0FqmoMRCN
X-Received: by 2002:a63:f241:: with SMTP id d1mr4464718pgk.2.1550221990458;
        Fri, 15 Feb 2019 01:13:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550221990; cv=none;
        d=google.com; s=arc-20160816;
        b=xF32hQz0bvTe1OZMPpXpyTMOcH6Sy1okwkjTCo1QOd67nH1wd6O1utX1K9ZjX0IA0Q
         JdcgetVHhdTcCJIoq98V6D7xsrttRzpeWGzXtDa4ANYsWiEJW68JevXNYOahgoZeBtFY
         LyK4eEmAAHz6QPEvZnoERda+eAYXlTANF3oKcTqxgbaDV7qFtlfPBFGf9o+Q+Jpt+4ZE
         NiyanNhADWoh3Bh9dRRYIOZ2H+6ILsrp4ejnfcn8VUub167X04qlgTE3kT3wg61NuHi4
         VyrVuoaWkCblREIJ6FhS5qQ4rSAHWVdh6Gz4WBTJk7ZvbU2Xn15MuUHKDay6u7Gyw9WH
         Y+6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=juFHqzeKfwBJva52CybdDJ7ojpRQMEPZc12GIizILx4=;
        b=GVbT6B+TT9pbPptEmyQcRHr/fP9hka1vXQ6p/ecFPCSRs1RVrFX+zDgX/X4IC86HFx
         v09mrzqjdRIyttU2VrY31qOqrH0zhtRj670KEvaEbPUmyr7N/6oqBfb57xzbF+1UXnHY
         gXRr+VDVTABW7HiI5dJdm74qA4oIDrryZhwi8EjV3fa+cOBTzXmeLhH+k+1pyW6tm6+i
         knVhW8qtcU5JmuIJpu5CcGclv4J29BJcjmZPpiUuzxNVfudbVo/kjyFQ2sm1WquLETM8
         MmNaz3jVrM+e7aQiAURsXSMAIDcmT+hiSEfwDqDppp4FdJYLXKMTyKFYsBf0r/PhnNrw
         Ox8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id n59si443159plb.388.2019.02.15.01.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 01:13:10 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 4416xG3vTtz9s7T;
	Fri, 15 Feb 2019 20:13:06 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Jann Horn <jannh@google.com>, mtk.manpages@gmail.com, jannh@google.com
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-api@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH] mmap.2: describe the 5level paging hack
In-Reply-To: <20190211163653.97742-1-jannh@google.com>
References: <20190211163653.97742-1-jannh@google.com>
Date: Fri, 15 Feb 2019 20:13:02 +1100
Message-ID: <87sgwpct41.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Jann Horn <jannh@google.com> writes:

> The manpage is missing information about the compatibility hack for
> 5-level paging that went in in 4.14, around commit ee00f4a32a76 ("x86/mm:
> Allow userspace have mappings above 47-bit"). Add some information about
> that.

Thanks for doing this.

> While I don't think any hardware supporting this is shipping yet (?), I
> think it's useful to try to write a manpage for this API, partly to
> figure out how usable that API actually is, and partly because when this
> hardware does ship, it'd be nice if distro manpages had information about
> how to use it.
>
> Signed-off-by: Jann Horn <jannh@google.com>
> ---
> This patch goes on top of the patch "[PATCH] mmap.2: fix description of
> treatment of the hint" that I just sent, but I'm not sending them in a
> series because I want the first one to go in, and I think this one might
> be a bit more controversial.
>
> It would be nice if the architecture maintainers and mm folks could have
> a look at this and check that what I wrote is right - I only looked at
> the source for this, I haven't tried it.
>
>  man2/mmap.2 | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
>
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 8556bbfeb..977782fa8 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -67,6 +67,8 @@ is NULL,
>  then the kernel chooses the (page-aligned) address
>  at which to create the mapping;
>  this is the most portable method of creating a new mapping.
> +On Linux, in this case, the kernel may limit the maximum address that can be
> +used for allocations to a legacy limit for compatibility reasons.
>  If
>  .I addr
>  is not NULL,
> @@ -77,6 +79,19 @@ or equal to the value specified by
>  and attempt to create the mapping there.
>  If another mapping already exists there, the kernel picks a new
>  address, independent of the hint.
> +However, if a hint above the architecture's legacy address limit is provided
> +(on x86-64: above 0x7ffffffff000, on arm64: above 0x1000000000000, on ppc64 with
> +book3s: above 0x7fffffffffff or 0x3fffffffffff, depending on page size), the

It doesn't depend on page size for ppc64(le). With 4K pages the user VM
is always 64TB.

So the only boundary for us is at 128T when using 64K pages.

cheers

