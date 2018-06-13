Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5132D6B000D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:18:07 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 89-v6so1852904plb.18
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:18:07 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k13-v6si3591060pfd.97.2018.06.13.11.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:18:06 -0700 (PDT)
Subject: Re: [PATCHv3 08/17] x86/mm: Implement vma_is_encrypted() and
 vma_keyid()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-9-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cc63f92a-4020-79b5-9b49-4cdd5cb800d2@intel.com>
Date: Wed, 13 Jun 2018 11:18:05 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-9-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> +bool vma_is_encrypted(struct vm_area_struct *vma)
> +{
> +	return pgprot_val(vma->vm_page_prot) & mktme_keyid_mask;
> +}
> +
> +int vma_keyid(struct vm_area_struct *vma)
> +{
> +	pgprotval_t prot;
> +
> +	if (!vma_is_anonymous(vma))
> +		return 0;
> +
> +	prot = pgprot_val(vma->vm_page_prot);
> +	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
> +}

Why do we have a vma_is_anonymous() in one of these but not the other?

While this reuse of ->vm_page_prot is cute, is there any downside?  It's
the first place I know of that we can't derive ->vm_page_prot from
->vm_flags on non-VM_IO/PFNMAP VMAs.  Is that a problem?
