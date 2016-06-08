Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8BB46B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 04:42:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r5so2474752wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:42:45 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id ib3si199755wjb.118.2016.06.08.01.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 01:42:44 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id k184so1081623wme.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:42:44 -0700 (PDT)
Date: Wed, 8 Jun 2016 10:42:41 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [Bug 119641] New: hugetlbfs: disabling because there are no
 supported hugepage sizes
Message-ID: <20160608084241.GA10729@gmail.com>
References: <bug-119641-27@https.bugzilla.kernel.org/>
 <20160606140123.bbc4b06d0f9d8b974f7b323f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606140123.bbc4b06d0f9d8b974f7b323f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, jp.pozzi@izzop.net, Ingo Molnar <mingo@elte.hu>, Jan Beulich <JBeulich@suse.com>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> Does anyone have any theories about this?  I went through the
> 4.5.2->4.5.5 changelog searching for "huget" but came up blank..
> 
> I'm suspiciously staring at Ingo's change
> 
> commit b2eafe890d4a09bfa63ab31ff018d7d6bb8cfefc
> Merge: abfb949 ea5dfb5
> Author:     Ingo Molnar <mingo@kernel.org>
> AuthorDate: Fri Apr 22 10:12:19 2016 +0200
> Commit:     Ingo Molnar <mingo@kernel.org>
> CommitDate: Fri Apr 22 10:13:53 2016 +0200
> 
>     Merge branch 'x86/urgent' into x86/asm, to fix semantic conflict
>     
>     'cpu_has_pse' has changed to boot_cpu_has(X86_FEATURE_PSE), fix this
>     up in the merge commit when merging the x86/urgent tree that includes
>     the following commit:
>     
>       103f6112f253 ("x86/mm/xen: Suppress hugetlbfs in PV guests")
>     
>     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> 
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@@ -4,6 -4,7 +4,7 @@@
>   #include <asm/page.h>
>   #include <asm-generic/hugetlb.h>
>   
>  -#define hugepages_supported() cpu_has_pse
> ++#define hugepages_supported() boot_cpu_has(X86_FEATURE_PSE)

That's really a no-op change, as we simply got rid of cpu_has_pse:

-#define cpu_has_pse            boot_cpu_has(X86_FEATURE_PSE)

... and open coded the boot_cpu_has(X86_FEATURE_PSE) uses. There should be zero 
change to the generated code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
