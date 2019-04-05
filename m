Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D32CC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 04:14:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDBC32175B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 04:14:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brainfault-org.20150623.gappssmtp.com header.i=@brainfault-org.20150623.gappssmtp.com header.b="Tx+GE/ky"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDBC32175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brainfault.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2731E6B0006; Fri,  5 Apr 2019 00:14:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 222EC6B000D; Fri,  5 Apr 2019 00:14:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EAEA6B000E; Fri,  5 Apr 2019 00:14:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id B719D6B0006
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 00:14:15 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id i184so3067033wmi.9
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 21:14:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mBHVrWRKGZevbfTKeXKRxI9gf6sJ5d1z7tzrVixC8Jk=;
        b=B84VkxG4YJQJo6LSoNDSfdKM6Zy262LspoPBs4otQ+xXLhFzrQQ7+6HJ5g3fVH3MQF
         /NORkegbkrjoDacYZZohUfH1KjI80IKngA3E2hKevfcF+Vl4r6Y1VspCsdR82e3xF4tn
         JP4FHEMYGuH5b9Kvk9SIsIb27wuIQpEjp97+gP7z+5eYnAYPLs3XQ74xni6FgdYo6rau
         JDQZvLuSHYYzsvexzFMaHk3gpHbyFuBqShA/MbtHNRLcQMeuLNZQl7Xu2igqssf/1jlL
         B2JIHYGyz9ykDV/OfKNyv7849tmGrC4p4OR4yrnmEh57TB9r5hp8ajG9xu/0ixUYKmI5
         3vvA==
X-Gm-Message-State: APjAAAWMIUjv82nfQ6kUiDwm0xcwMNXtPN6XyG4s1Aa2ehWQ3VwTpZbe
	FKqJqlDzGrfx42+nd1e/Mzte0ChUFiUXPKHBJnoQdia4xlz9PEi0rr3KKUH5HdWDQcLbH5QERiU
	i7WTfLd6122Ohd6LczmVxWa828gzmWNYZa39cAYVBKoLOX9wkghQr4wFVlyYjF3m3ZQ==
X-Received: by 2002:a5d:52cc:: with SMTP id r12mr6384574wrv.163.1554437655222;
        Thu, 04 Apr 2019 21:14:15 -0700 (PDT)
X-Received: by 2002:a5d:52cc:: with SMTP id r12mr6384541wrv.163.1554437654385;
        Thu, 04 Apr 2019 21:14:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554437654; cv=none;
        d=google.com; s=arc-20160816;
        b=vcYfLU0Aq6Jd5Cenx/etm68yKGnDFGVTUQBFLMh4tkLlLeRtZOPPe+yJwCiX8Ra0Im
         d81LVVePo5mXpU0vfrWg4oxlK9LUHZ8ACs0SbWJ0q51aJbxwTtTos8gZXV5gk/tpP0gQ
         3Vjldk3hbj8TR5KK0NFSyyV8oNjlroHtmsqfpfC7fPv8H00Wk9mLn1GEiE5hT1Z/Xs2k
         qsefZTtB8QGmoZ9csOBtE6C0PxQYliUKcu2PzLZ3y4s/nI+EnJ9MGkBt5abLzrbLQPVc
         0yYFxXHoaEao3k3+dz4PnEIhTjkSv66FwlK9T+Mt+lD0zLVvjwteztzmvJlXbD5a95M6
         Y0Ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mBHVrWRKGZevbfTKeXKRxI9gf6sJ5d1z7tzrVixC8Jk=;
        b=Yy8zbn0B6IPqTsTwG4yb54CbAWqv0roPRnKznxRXMePR29TZuO8wUoMJULS6NX4XCm
         iO7Lwztjv6MZUZK+C1L6nDt2GSXn65sEnC7GY6X8dEztNMUp3sbROevNQJ06wyYiDNdK
         /IXM0Y9APkFMTG793nIa4mFfsuaqqoIbxnCfKKv+735x2X3Zds+r4f6cL+kOHORCSDLK
         vw3I9P6MLO57Td0+t8gZa+BvcfIogx3MTRKiK7/qGo3UJNzgCK17GnuGjZpPKTqq23ll
         tN87l4NkalB9Ot9TBVWGnP4BSGX9EdhIuzP6qTBlSf8JO+qcBjGEB+M3ra1LL7cOs7at
         zosg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brainfault-org.20150623.gappssmtp.com header.s=20150623 header.b="Tx+GE/ky";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of anup@brainfault.org) smtp.mailfrom=anup@brainfault.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g17sor275797wmg.15.2019.04.04.21.14.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 21:14:14 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of anup@brainfault.org) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brainfault-org.20150623.gappssmtp.com header.s=20150623 header.b="Tx+GE/ky";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of anup@brainfault.org) smtp.mailfrom=anup@brainfault.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brainfault-org.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mBHVrWRKGZevbfTKeXKRxI9gf6sJ5d1z7tzrVixC8Jk=;
        b=Tx+GE/kyMVuyulYFD856bWPolojQWzZWKuGBYAyKjK0wSk4YRKTXZo6o4ZTOpJgsos
         XQLvCcklGLmb66PPfiTWzUIWKIvNAVr6bC4EK1694Bit61uQlb1nNs67L+xwuxdl+PdX
         h4ivnwEstWB2XAVo/kCN4+ygPl9oCOa/pI2nucctjYQjixoE9p2B2NieLcCvq/smEOzv
         TWdJ2OrpLVzl1UGmcl93EOStMTOnOap/+WLoODhnByD6uG4l10NgxaH2EN6fKYZwp6i0
         DCLg5XXKc7J3QjtjAUdqw6/870X0w+b8BWvDHsIQYMwDs6d1as/suV81ZZ8FMq7MVqoA
         PVvg==
X-Google-Smtp-Source: APXvYqwPwBhxwnnbbp3Ou8kLLLXWzsVJNsanwq1En96de4XmSJmraw5HwQdVPcemwbBdE1cB9aXLGHM13X9Zf6iRDW8=
X-Received: by 2002:a1c:1f08:: with SMTP id f8mr5700645wmf.97.1554437653482;
 Thu, 04 Apr 2019 21:14:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190403141627.11664-1-steven.price@arm.com> <20190403141627.11664-7-steven.price@arm.com>
In-Reply-To: <20190403141627.11664-7-steven.price@arm.com>
From: Anup Patel <anup@brainfault.org>
Date: Fri, 5 Apr 2019 09:44:02 +0530
Message-ID: <CAAhSdy0Hz25LYwA6U0byRfbbmgorjiTUhyHs8sQ81=qvhPANrw@mail.gmail.com>
Subject: Re: [PATCH v8 06/20] riscv: mm: Add p?d_large() definitions
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>, 
	Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, 
	James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Will Deacon <will.deacon@arm.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
	"linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>, Mark Rutland <Mark.Rutland@arm.com>, 
	"Liang, Kan" <kan.liang@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, 
	linux-riscv@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 7:47 PM Steven Price <steven.price@arm.com> wrote:
>
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
>
> For riscv a page is large when it has a read, write or execute bit
> set on it.
>
> CC: Palmer Dabbelt <palmer@sifive.com>
> CC: Albert Ou <aou@eecs.berkeley.edu>
> CC: linux-riscv@lists.infradead.org
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  arch/riscv/include/asm/pgtable-64.h | 7 +++++++
>  arch/riscv/include/asm/pgtable.h    | 7 +++++++
>  2 files changed, 14 insertions(+)
>
> diff --git a/arch/riscv/include/asm/pgtable-64.h b/arch/riscv/include/asm/pgtable-64.h
> index 7aa0ea9bd8bb..73747d9d7c66 100644
> --- a/arch/riscv/include/asm/pgtable-64.h
> +++ b/arch/riscv/include/asm/pgtable-64.h
> @@ -51,6 +51,13 @@ static inline int pud_bad(pud_t pud)
>         return !pud_present(pud);
>  }
>
> +#define pud_large      pud_large
> +static inline int pud_large(pud_t pud)
> +{
> +       return pud_present(pud)
> +               && (pud_val(pud) & (_PAGE_READ | _PAGE_WRITE | _PAGE_EXEC));
> +}
> +
>  static inline void set_pud(pud_t *pudp, pud_t pud)
>  {
>         *pudp = pud;
> diff --git a/arch/riscv/include/asm/pgtable.h b/arch/riscv/include/asm/pgtable.h
> index 1141364d990e..9570883c79e7 100644
> --- a/arch/riscv/include/asm/pgtable.h
> +++ b/arch/riscv/include/asm/pgtable.h
> @@ -111,6 +111,13 @@ static inline int pmd_bad(pmd_t pmd)
>         return !pmd_present(pmd);
>  }
>
> +#define pmd_large      pmd_large
> +static inline int pmd_large(pmd_t pmd)
> +{
> +       return pmd_present(pmd)
> +               && (pmd_val(pmd) & (_PAGE_READ | _PAGE_WRITE | _PAGE_EXEC));
> +}
> +
>  static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
>  {
>         *pmdp = pmd;
> --
> 2.20.1
>

Looks good to me.

Reviewed-by: Anup Patel <anup@brainfault.org>

Regards,
Anup

