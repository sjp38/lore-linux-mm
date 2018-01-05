Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BCD606B037D
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 14:03:59 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z2so2711002pgz.13
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 11:03:59 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l12si4331447plc.265.2018.01.05.11.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 11:03:58 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
 <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <282e2a56-ded1-6eb9-5ecb-22858c424bd7@linux.intel.com>
Date: Fri, 5 Jan 2018 11:03:56 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On 01/05/2018 10:19 AM, Jiri Kosina wrote:
> --- a/arch/x86/platform/efi/efi_64.c
> +++ b/arch/x86/platform/efi/efi_64.c
> @@ -95,6 +95,12 @@ pgd_t * __init efi_call_phys_prolog(void
>  		save_pgd[pgd] = *pgd_offset_k(pgd * PGDIR_SIZE);
>  		vaddress = (unsigned long)__va(pgd * PGDIR_SIZE);
>  		set_pgd(pgd_offset_k(pgd * PGDIR_SIZE), *pgd_offset_k(vaddress));
> +		/*
> +		 * pgprot API doesn't clear it for PGD
> +		 *
> +		 * Will be brought back automatically in _epilog()
> +		 */
> +		pgd_offset_k(pgd * PGDIR_SIZE)->pgd &= ~_PAGE_NX;
>  	}
>  	__flush_tlb_all();

Wait a sec...  Where does the _PAGE_USER come from?  Shouldn't we see
the &init_mm in there and *not* set _PAGE_USER?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
