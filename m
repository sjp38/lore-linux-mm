Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8588C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 15:50:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CA3E206B7
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 15:50:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CA3E206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 313058E0007; Mon, 14 Jan 2019 10:50:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C23F8E0002; Mon, 14 Jan 2019 10:50:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D88E8E0007; Mon, 14 Jan 2019 10:50:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6CFB8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:50:50 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id 18-v6so5450055ljn.8
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:50:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=31z+XEMzJ6K5/5aQETRHBYXsxTO0tFnzs/8KDuSnm1o=;
        b=WcuCWKyMJlHltsE8hlRqzJl4BnRlDZ+v0nf1f2l4EkmKAluukN5LkGaqqmJlip6N9K
         Az8FlC4c0JFrw9GWkcyE6BIe6Ih/dNTxv0XYhkPqlx9U+t2ZljizlmqzFdUXErP3nn7w
         CR7c4xy4cHH2Vxx0mfRuBIVhAedqNtKSeNDndpsW/Z8S4AKAUh9vi+uqGvb3ob0xvOn+
         9nYOitfe7kK5ugSAFIZICnx/V9bq9fXX6sUQA/G+C324u9H5MpR4svfKkiEaTtqCnUw/
         BfmBzSiRHqZWTttAqfOZp7zVSVhEowRBXSRT15/vDLKGDmkzSbXgBZm+rGq4ULlhW6dV
         pnOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeLRPbqvU+09wE/RDzP/JLQeciQx9v9PoSVanoMsaQn4uBwTtdP
	2puzRMpWwXUCnwTd+w480C0XRS/zEPrCKbZsdrfe3joShi8dC4B8k7aojo85D3EzHvUBnBjhQ9j
	nla87Yp1bSoaQ9h+nn0a7X9ULxmrJRf1GK1upJ8X3EcE3g0a9oACcvG7LNtdhnkjlG5J18quJ9a
	gFxPGTEq3QdddKxTlipI/sIR4zAVJZIPenjBNLA2zg1DWr1fKWoM6UpHJR+CrG4Feg5z1MouO1E
	n9O6ThmHW7KkcJZB7uvJrAkxoWUoZK5MTuvqZjmX3Y0Lo62TpSfkwcdn8g+gue8xK1iiDfKB+Wm
	iW5iIS8kcOi6YGGEqDXW/DFPo9h2gKwuH4E/sCf5UnkFK16LGrdyGuRl6iLfAKfRDoFOB+rslJQ
	B
X-Received: by 2002:a2e:5109:: with SMTP id f9-v6mr16196002ljb.52.1547481050082;
        Mon, 14 Jan 2019 07:50:50 -0800 (PST)
X-Received: by 2002:a2e:5109:: with SMTP id f9-v6mr16195958ljb.52.1547481049138;
        Mon, 14 Jan 2019 07:50:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547481049; cv=none;
        d=google.com; s=arc-20160816;
        b=0cvV0fufavXs2Ep1AGT2bAtOachKrinbGQ7J/DlLNac/ADo8j0zwlcdehHHGz6SotT
         Ik8JxJmtKUg4gdg6JGCulKhMqUDdB4hNOLIrgmiXqplsSFS8RJSUtw2mSqkBwrVf2M6S
         91ainARGTvI6aqEPLcPvLmpMO3wrKgOCDc+t06h0ybIGvCZk3GiPWJkN1LaFxy4QPtB1
         DwaBDUBdYTOtjQ1s25IjUYetKklmyEGp9vjnnrq4DXKwisypJhlMJGROUSXK9wmtOINn
         bFgwNncCtgbtjTe8E6wCdSomoP7vBAT/YThIxTkYq9WXPDQlAF23tsIkmP7DExTutNwB
         2GQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=31z+XEMzJ6K5/5aQETRHBYXsxTO0tFnzs/8KDuSnm1o=;
        b=egAQRuy1ygLL8At1POmlV8xvukZ0Vj4gETcRYaHyJ3TdTh/yVAZ1nIJ5pY9QFirQ4a
         f1NkHrryHgviJd1rSEA5tR5CvhA7PTGYtucmigL+7py9FI1XpSS9D3K77UuOMA3ysAta
         BD+klh4pp9vKMbtE06yrq1wdChKCZnEyILGUc6CpmGgbc46OQiMWR8N2RARaW7CYYGdJ
         Ok4vyvHJ5XeMu6qBqiplm7OnhObXSctceefLQ3sZ/MwMGkwFd60D2RJefVJpwIFQ42QC
         1pj1qkaj1PEynBbPtHz7u5AdkJpX7qa3/EBA9Qj5ldu79XdAWqE/1e8EKdWEe/l/y1vN
         bmKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o194sor271568lfa.64.2019.01.14.07.50.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 07:50:49 -0800 (PST)
Received-SPF: pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: ALg8bN5txqcWH3KBN3VoGeUeW3+QHeURZnmU0Eso/D3tnH22waYzfYP3ty/L2QT+uI5i27K+O4hWHkLJc7cF20VJOfE=
X-Received: by 2002:a19:750a:: with SMTP id y10mr13446847lfe.43.1547481048577;
 Mon, 14 Jan 2019 07:50:48 -0800 (PST)
MIME-Version: 1.0
References: <20190114125903.24845-1-david@redhat.com> <20190114125903.24845-7-david@redhat.com>
In-Reply-To: <20190114125903.24845-7-david@redhat.com>
From: Bhupesh Sharma <bhsharma@redhat.com>
Date: Mon, 14 Jan 2019 21:20:01 +0530
Message-ID:
 <CACi5LpPb5Mkk-AQARm96mHJ6S5KLKkSswP-=4z9oPYzK0-knEQ@mail.gmail.com>
Subject: Re: [PATCH v2 6/9] arm64: kexec: no need to ClearPageReserved()
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-m68k@lists.linux-m68k.org, 
	linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, 
	linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	James Morse <james.morse@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, 
	Dave Kleikamp <dave.kleikamp@oracle.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114155001.-vHaEA97Hk3KOR17c_vPSoQixdCcW3PWX7FZQ4ZTc6A@z>

Hi David,

Thanks for the patch.

On Mon, Jan 14, 2019 at 6:29 PM David Hildenbrand <david@redhat.com> wrote:
>
> This will be done by free_reserved_page().
>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Bhupesh Sharma <bhsharma@redhat.com>
> Cc: James Morse <james.morse@arm.com>
> Cc: Marc Zyngier <marc.zyngier@arm.com>
> Cc: Dave Kleikamp <dave.kleikamp@oracle.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Acked-by: James Morse <james.morse@arm.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/arm64/kernel/machine_kexec.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
> index aa9c94113700..6f0587b5e941 100644
> --- a/arch/arm64/kernel/machine_kexec.c
> +++ b/arch/arm64/kernel/machine_kexec.c
> @@ -361,7 +361,6 @@ void crash_free_reserved_phys_range(unsigned long begin, unsigned long end)
>
>         for (addr = begin; addr < end; addr += PAGE_SIZE) {
>                 page = phys_to_page(addr);
> -               ClearPageReserved(page);
>                 free_reserved_page(page);
>         }
>  }
> --
> 2.17.2
>

Reviewed-by: Bhupesh Sharma <bhsharma@redhat.com>

