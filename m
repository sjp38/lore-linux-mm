Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE046B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 12:28:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id c3-v6so10337797plz.7
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 09:28:34 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s13-v6si14845820plp.350.2018.06.18.09.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 09:28:29 -0700 (PDT)
Subject: Re: [PATCHv3 15/17] x86/mm: Implement sync_direct_mapping()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-16-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <848a6836-1f54-4775-0b87-e926d7b7991d@intel.com>
Date: Mon, 18 Jun 2018 09:28:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-16-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> index 17383f9677fa..032b9a1ba8e1 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -731,6 +731,8 @@ kernel_physical_mapping_init(unsigned long paddr_start,
>  		pgd_changed = true;
>  	}
>  
> +	sync_direct_mapping();
> +
>  	if (pgd_changed)
>  		sync_global_pgds(vaddr_start, vaddr_end - 1);
>  
> @@ -1142,10 +1144,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
>  static void __meminit
>  kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>  {
> +	int ret;
>  	start = (unsigned long)__va(start);
>  	end = (unsigned long)__va(end);
>  
>  	remove_pagetable(start, end, true, NULL);
> +	ret = sync_direct_mapping();
> +	WARN_ON(ret);
>  }

I understand why you implemented it this way, I really do.  It's
certainly the quickest way to hack something together and make a
standalone piece of code.  But, I don't think it's maintainable.

For instance, this call to sync_direct_mapping() could be entirely
replaced by a call to:

	for_each_keyid(k)...
		remove_pagetable(start + offset_per_keyid * k,
			         end   + offset_per_keyid * k,
				 true, NULL);

No?

>  int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
> @@ -1290,6 +1295,7 @@ void mark_rodata_ro(void)
>  			(unsigned long) __va(__pa_symbol(rodata_end)),
>  			(unsigned long) __va(__pa_symbol(_sdata)));
>  
> +	sync_direct_mapping();
>  	debug_checkwx();

Huh, checking the return code in some cases and not others.  Curious.
Why is it that way?
