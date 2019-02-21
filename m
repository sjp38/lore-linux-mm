Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B23EC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1681E206A3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:21:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="si2bkdMJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1681E206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E6E58E0085; Thu, 21 Feb 2019 09:21:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BC9E8E0002; Thu, 21 Feb 2019 09:21:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AADA8E0085; Thu, 21 Feb 2019 09:21:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39CE28E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:21:33 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 2so19375661pgg.21
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:21:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iI1RJ0SSXxDh0vlZLQrOFO/u2FUJ4ENpS3Ludw9bPw8=;
        b=pjqCzUKiwWzEie9D/7D0qR3tBMCJXey3sXbMEaYbGNbg9GyT6omrYhDcFqTSy7oe9T
         hc8dAeymQeanpKJZPHDc59G6qwEzG2qHp7wWZeYIbyBfSkmupFZYumF9lPZIrQaq4oLM
         eXeWwc94wRBNs0Z0MhPCQSmZhkXFzdwFCbSlKuSUpFNL9Ie8IsW1WC9JLrbGbIvvr5EM
         NMn1ywS3cNT1F791DCdZ1byb6NM0SGpVb31V+SnBah1VudNx8uuDOzhV6DJpSEQr9b7A
         HcHM33yiZqO2WQlJ4IzK2X/3/q3OSaHb+XnpXUFUkiBOWdU1dEYt1zgsm+VbzwbBheQp
         Zx2Q==
X-Gm-Message-State: AHQUAuaO3odqVOBuALdl3mOG4VinNwyHuQs5kjnsUXxvR8sWkBDDwWU0
	G82bNDLvnIdkEpEJ8Eti967gPPGdAVUopIk84UWlO/sRW+3uyXxSC93RgZM1WmaILGanowRXFqk
	a4DlVR2H31GZ6PPPMiiX4ga7Zir7Zt1Qr4WahwecN2Mb8RVKvEY8W25blnN2jsHsVdljL2lw7+V
	odm8gyTBJtMMUYhQvGcYbeUfJT2Svrb6jKmFyx/a/Cg0xO+cCscj/ZeQ+v4wNA/eIb94Rihi9oi
	d5BV4DU+DZKjG8lKqmtqxbGiOw/yONFNCFVykH8pIPLoSqqUlbjQMdjMwEse87ys1l1gnql18TL
	cs6OZnZ5Ht2Zv55S0CgTLmJvilrXDhNl6rhyi90O/yR1Y6zrw+4JsWXYTswjFeVex6WXCF9gn6h
	J
X-Received: by 2002:a63:1c02:: with SMTP id c2mr27659832pgc.351.1550758892867;
        Thu, 21 Feb 2019 06:21:32 -0800 (PST)
X-Received: by 2002:a63:1c02:: with SMTP id c2mr27659754pgc.351.1550758891939;
        Thu, 21 Feb 2019 06:21:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550758891; cv=none;
        d=google.com; s=arc-20160816;
        b=IHpEkchr9WfCwY66EtPSpjfFy6u8nUewXUeQW5xni/9tYiHuqPHHu1XTw/TbVjCdpK
         7VQ6tn4ibUQuwNiwqYR5sr+6C3nPu1mJySxWjWG1NSAP/DdyAtmvm5dhHbvMgXS68Wba
         8oDQqbVsaoql3dcDIdmfWpmq4E5a6tq2g7Fx/CoJ/6wbXfyLN61PmKX/fRZ6bupAPZzv
         r2s2gOEoEj00zzirkq2c7kOOb5L7BCxbXo9Kd1LkPMLsuzj7bXI1vMZw+jJr/fj1J7vF
         4wACg2/huGSbIGOV2L0Cve2y2uDK5oUCpNur3e13tfgu101Ewz54Ep9O5GJ3yefW/RIU
         ASpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iI1RJ0SSXxDh0vlZLQrOFO/u2FUJ4ENpS3Ludw9bPw8=;
        b=VrQ+uHlbV6WRT1B3f4QQc2ePQdhxY1UvZ81WXXtJZLisDRuEoFjJQoj9fWSD/b/Mp1
         NqGW24yMo4vdbgd6Sz4Da3dIoJxiJwLdIr9mzvewm5PGp4qsDh/ix6C/3W3HUGh9PL6p
         QZAuhHzo1iwkSdgbWnnyNIfnolvMwE6Y6KZg/b4g9t2PTMOePqVLbvQl4lxLvC20YWQW
         1sc9BMZWsFZXt3I+cJ1RnXBEBFIvLU2w/ijya5n6I3rMscybDCRmQ0LbVbB2BXBQkynu
         dXQYiGGszJ02r/B3TAqpyMIg6AlNIZl3J+KOhlT3GjD8VpTOHxsOSN6a+tD2pHbWAQj3
         mlLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=si2bkdMJ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o23sor34661638pgv.0.2019.02.21.06.21.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 06:21:31 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=si2bkdMJ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iI1RJ0SSXxDh0vlZLQrOFO/u2FUJ4ENpS3Ludw9bPw8=;
        b=si2bkdMJebBvPM0GwIvEO3/Amyao38zKAiijR3TpjprMmoqFKum3Njget2unbrFOug
         Ga5QS8HL9rNhN0+nYuT7Z1Uu30vuTxz/7QrYSi00fO0cXe2GxPw1/zwMWmVyWJcYa23o
         f+J45gf8vblmxl80YXo1DP1ukP8rOkDYFLlVRZ93Vepj3O8V/WlhKysqFYJtQLEkXXvu
         Oh7ZRasJOIPvqvl9oLSXVqrMRxLiDcJW4Jr6wY7G8ezbvntovYIWEP4ik7Idb5ominp4
         8zG9C/Wqm3T7mqY/Z7xn00SZ3SrtBhrBwMG6aS/sCofVD/oqCyNYjTc3pB0OZzOpXqXf
         7Dtg==
X-Google-Smtp-Source: AHgI3IZIRxhWmHk+uI4fyRE/obuhbmXUG2L9nLu0JhpIBnQ04LtmbdtCF/YGn8UplGAT9XruNQ0UOA==
X-Received: by 2002:a63:68c9:: with SMTP id d192mr35656895pgc.264.1550758891142;
        Thu, 21 Feb 2019 06:21:31 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.44])
        by smtp.gmail.com with ESMTPSA id o2sm31440498pfa.76.2019.02.21.06.21.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 06:21:30 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 662E6301708; Thu, 21 Feb 2019 17:21:26 +0300 (+03)
Date: Thu, 21 Feb 2019 17:21:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v2 02/13] x86/mm: Add p?d_large() definitions
Message-ID: <20190221142126.k54vqaacrc2ekeff@kshutemo-mobl1>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-3-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221113502.54153-3-steven.price@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:34:51AM +0000, Steven Price wrote:
> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> we may come across the exotic large mappings that come with large areas
> of contiguous memory (such as the kernel's linear map).
> 
> Expose p?d_large() from each architecture to detect these large mappings.
> 
> x86 already has these defined as inline functions, add a macro of the
> same name so we don't end up with the generic version too.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  arch/x86/include/asm/pgtable.h | 3 +++
>  arch/x86/mm/dump_pagetables.c  | 3 +++
>  2 files changed, 6 insertions(+)
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 2779ace16d23..3695f6acb6af 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -234,6 +234,7 @@ static inline int pmd_large(pmd_t pte)
>  {
>  	return pmd_flags(pte) & _PAGE_PSE;
>  }
> +#define pmd_large(x)	pmd_large(x)
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  static inline int pmd_trans_huge(pmd_t pmd)
> @@ -873,6 +874,7 @@ static inline int pud_large(pud_t pud)
>  	return 0;
>  }
>  #endif	/* CONFIG_PGTABLE_LEVELS > 2 */
> +#define pud_large(x)	pud_large(x)

Nit: we usually do this in form of

#define pud_large pud_large

and before body of the inline function.

-- 
 Kirill A. Shutemov

