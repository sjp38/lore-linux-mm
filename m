Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 189A66B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 09:16:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p134so629905wmg.3
        for <linux-mm@kvack.org>; Fri, 05 May 2017 06:16:54 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id y39si5929056wrd.240.2017.05.05.06.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 06:16:52 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id u65so23607648wmu.1
        for <linux-mm@kvack.org>; Fri, 05 May 2017 06:16:52 -0700 (PDT)
Date: Fri, 5 May 2017 16:16:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, sparsemem: break out of loops early
Message-ID: <20170505131649.t5ffmg7xspndtrc4@node.shutemov.name>
References: <20170504174434.C45A4735@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170504174434.C45A4735@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Thu, May 04, 2017 at 10:44:34AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> There are a number of times that we loop over NR_MEM_SECTIONS,
> looking for section_present() on each section.  But, when we have
> very large physical address spaces (large MAX_PHYSMEM_BITS),
> NR_MEM_SECTIONS becomes very large, making the loops quite long.
> 
> With MAX_PHYSMEM_BITS=46 and a section size of 128MB, the current
> loops are 512k iterations, which we barely notice on modern
> hardware.  But, raising MAX_PHYSMEM_BITS higher (like we will see
> on systems that support 5-level paging) makes this 64x longer and
> we start to notice, especially on slower systems like simulators.
> A 10-second delay for 512k iterations is annoying.  But, a 640-
> second delay is crippling.
> 
> This does not help if we have extremely sparse physical address
> spaces, but those are quite rare.  We expect that most of the
> "slow" systems where this matters will also be quite small and
> non-sparse.
> 
> To fix this, we track the highest section we've ever encountered.
> This lets us know when we will *never* see another
> section_present(), and lets us break out of the loops earlier.
> 
> Doing the whole for_each_present_section_nr() macro is probably
> overkill, but it will ensure that any future loop iterations that
> we grow are more likely to be correct.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Tested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

It shaved almost 40 seconds from boot time in qemu with 5-level paging
enabled for me :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
