Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86E216B025E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 10:24:40 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id qh10so135379965pac.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 07:24:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bg2si3263070pab.103.2016.07.14.07.24.39
        for <linux-mm@kvack.org>;
        Thu, 14 Jul 2016 07:24:39 -0700 (PDT)
Subject: Re: [PATCH 4/4] x86: use pte_none() to test for empty PTE
References: <20160708001909.FB2443E2@viggo.jf.intel.com>
 <20160708001915.813703D9@viggo.jf.intel.com>
 <71d7b63a-45dd-c72d-a277-03124b0053ae@suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5787A0A2.4070406@intel.com>
Date: Thu, 14 Jul 2016 07:24:34 -0700
MIME-Version: 1.0
In-Reply-To: <71d7b63a-45dd-c72d-a277-03124b0053ae@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, dave.hansen@linux.intel.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Juergen Gross <jgross@suse.com>

On 07/14/2016 06:47 AM, Vlastimil Babka wrote:
> So, this might be just because I know next to nothing about (para)virt,
> but...
> 
> in arch/x86/include/asm/paravirt.h, pte_val is implemented via some
> pvops, which suggests that obtaining a pte value is different than just
> reading it from memory. But I don't see pte_none() defined to be using
> this on paravirt, and it shares (before patch 2/4) the "return !pte.pte"
> implementation, AFAICS?
> 
> So that itself is suspicious to me. And now that this patches does
> things like this:
> 
> -              if (pte_val(*pte)) {
> +              if (!pte_none(*pte)) {
> 
> So previously on paravirt these tests would read pte via the pvops, and
> now they won't. Is that OK?

I've cc'd a few Xen guys.  I think they're the only ones that would care.

But, as far as I can tell, the Xen pte_val() will take a _PAGE_PRESENT
PTE and muck with it.  But its answer will never differ for an all 0 PTE
from !pte_none() because that PTE does not have _PAGE_PRESENT set.

It does seem fragile that Xen is doing it this way, but I guess it works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
