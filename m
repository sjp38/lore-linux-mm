Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3D36B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:54:21 -0400 (EDT)
Received: by wibgu7 with SMTP id gu7so11787233wib.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 07:54:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eb5si5849888wic.46.2015.08.28.07.54.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Aug 2015 07:54:19 -0700 (PDT)
Subject: Re: [PATCH v8 3/6] mm: Introduce VM_LOCKONFAULT
References: <1440613465-30393-1-git-send-email-emunson@akamai.com>
 <1440613465-30393-4-git-send-email-emunson@akamai.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55E07618.9090905@suse.cz>
Date: Fri, 28 Aug 2015 16:54:16 +0200
MIME-Version: 1.0
In-Reply-To: <1440613465-30393-4-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 08/26/2015 08:24 PM, Eric B Munson wrote:
> The cost of faulting in all memory to be locked can be very high when
> working with large mappings.  If only portions of the mapping will be
> used this can incur a high penalty for locking.
>
> For the example of a large file, this is the usage pattern for a large
> statical language model (probably applies to other statical or graphical
> models as well).  For the security example, any application transacting
> in data that cannot be swapped out (credit card data, medical records,
> etc).
>
> This patch introduces the ability to request that pages are not
> pre-faulted, but are placed on the unevictable LRU when they are finally
> faulted in.  The VM_LOCKONFAULT flag will be used together with
> VM_LOCKED and has no effect when set without VM_LOCKED.  Setting the
> VM_LOCKONFAULT flag for a VMA will cause pages faulted into that VMA to
> be added to the unevictable LRU when they are faulted or if they are
> already present, but will not cause any missing pages to be faulted in.
>
> Exposing this new lock state means that we cannot overload the meaning
> of the FOLL_POPULATE flag any longer.  Prior to this patch it was used
> to mean that the VMA for a fault was locked.  This means we need the
> new FOLL_MLOCK flag to communicate the locked state of a VMA.
> FOLL_POPULATE will now only control if the VMA should be populated and
> in the case of VM_LOCKONFAULT, it will not be set.
>
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-api@vger.kernel.org

Acked-by: Vlastimil Babka <vbabka@suse.cz>

I just wonder if the call to populate_vma_page_range from mprotect_fixup 
is just an potentially expensive no-op for VM_LOCKONFAULT vma's? It 
might find many cow candidates but faultin_page() won't do anything. And 
it shouldn't find any existing pages to put on the unevictable list from 
this context.

But it's a corner case and preventing it would mean putting in another 
VM_LOCKONFAULT check so maybe we can leave it like this.
-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
