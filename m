Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2D3C6B0008
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:13:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m18so716337pgu.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:13:38 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b90-v6si6211863pli.261.2018.03.05.11.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:13:37 -0800 (PST)
Subject: Re: [RFC, PATCH 13/22] mm, rmap: Free encrypted pages once mapcount
 drops to zero
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e04536bc-77e9-84d0-3c23-1dfea8542da5@intel.com>
Date: Mon, 5 Mar 2018 11:13:36 -0800
MIME-Version: 1.0
In-Reply-To: <20180305162610.37510-14-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> @@ -1292,6 +1308,12 @@ static void page_remove_anon_compound_rmap(struct page *page)
>  		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
>  		deferred_split_huge_page(page);
>  	}
> +
> +	anon_vma = page_anon_vma(page);
> +	if (anon_vma_encrypted(anon_vma)) {
> +		int keyid = anon_vma_keyid(anon_vma);
> +		free_encrypt_page(page, keyid, compound_order(page));
> +	}
>  }

It's not covered in the description and I'm to lazy to dig into it, so:
Without this code, where do they get freed?  Why does it not cause any
problems to free them here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
