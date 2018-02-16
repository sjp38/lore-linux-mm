Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EE686B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 18:19:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b6so2966034pgu.16
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 15:19:03 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a5-v6si347377plh.450.2018.02.16.15.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 15:19:02 -0800 (PST)
Subject: Re: [PATCH 2/3] x86/mm: introduce __PAGE_KERNEL_GLOBAL
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <20180215132055.F341C31E@viggo.jf.intel.com>
 <E0AB2852-C4E0-43D3-ABA7-34117A5516C1@gmail.com>
 <a3dd1676-a2dc-aa02-77ad-51cd3b7a78d5@linux.intel.com>
 <DF43D1DD-42EE-4545-9F54-4BC2395D66EA@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <562aaaf0-fb8e-1cc8-61eb-1d74b5922714@linux.intel.com>
Date: Fri, 16 Feb 2018 15:19:00 -0800
MIME-Version: 1.0
In-Reply-To: <DF43D1DD-42EE-4545-9F54-4BC2395D66EA@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org

On 02/16/2018 10:25 AM, Nadav Amit wrote:
>> --- a/arch/x86/mm/pageattr.c~kpti-no-global-for-kernel-mappings	2018-02-13 15:17:56.148210060 -0800
>> +++ b/arch/x86/mm/pageattr.c	2018-02-13 15:17:56.153210060 -0800
>> @@ -593,7 +593,8 @@ try_preserve_large_page(pte_t *kpte, uns
>> 	 * different bit positions in the two formats.
>> 	 */
>> 	req_prot = pgprot_4k_2_large(req_prot);
>> -	req_prot = pgprot_set_on_present(req_prot, _PAGE_GLOBAL | _PAGE_PSE);
>> +	req_prot = pgprot_set_on_present(req_prot,
>> +			__PAGE_KERNEL_GLOBAL | _PAGE_PSE);
>> 	req_prot = canon_pgprot(req_prot);
> From these chunks, it seems to me as req_prot will not have the global bit
> on when a??noptia?? parameter is provided. What am I missing?

BTW, this code is broken.  It's trying to unconditionally set
_PAGE_GLOBAL whenever set do change_page_attr() and friends.  It gets
fixed up by canon_pgprot(), but it's wrong to do in the first place.
I've got a better fix for this coming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
