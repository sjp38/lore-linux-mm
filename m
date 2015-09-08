Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id CBAF76B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 07:31:59 -0400 (EDT)
Received: by igxx6 with SMTP id x6so13841740igx.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 04:31:59 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ch4si5023965pdb.84.2015.09.08.04.31.58
        for <linux-mm@kvack.org>;
        Tue, 08 Sep 2015 04:31:59 -0700 (PDT)
Date: Tue, 8 Sep 2015 12:31:13 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V4 2/3] arm64: support initrd outside kernel linear map
Message-ID: <20150908113113.GA20562@leverpostej>
References: <1439830867-14935-1-git-send-email-msalter@redhat.com>
 <1439830867-14935-3-git-send-email-msalter@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439830867-14935-3-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "x86@kernel.org" <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

Hi Mark,

On Mon, Aug 17, 2015 at 06:01:06PM +0100, Mark Salter wrote:
> The use of mem= could leave part or all of the initrd outside of
> the kernel linear map. This will lead to an error when unpacking
> the initrd and a probable failure to boot. This patch catches that
> situation and relocates the initrd to be fully within the linear
> map.

With next-20150908, this patch results in a confusing message at boot when not
using an initrd:

Moving initrd from [4080000000-407fffffff] to [9fff49000-9fff48fff]

I think that can be solved by folding in the diff below.

Thanks,
Mark.

diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 6bab21f..2322479 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -364,6 +364,8 @@ static void __init relocate_initrd(void)
                to_free = ram_end - orig_start;
 
        size = orig_end - orig_start;
+       if (!size)
+               return;
 
        /* initrd needs to be relocated completely inside linear mapping */
        new_start = memblock_find_in_range(0, PFN_PHYS(max_pfn),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
