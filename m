Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCD796B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 12:26:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p16-v6so748096pfn.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:26:51 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x1-v6si53779818plb.8.2018.06.07.09.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 09:26:50 -0700 (PDT)
Received: from mail-wr0-f178.google.com (mail-wr0-f178.google.com [209.85.128.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 17563208A4
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:26:50 +0000 (UTC)
Received: by mail-wr0-f178.google.com with SMTP id d2-v6so10472814wrm.10
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:26:50 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143705.3531-1-yu-cheng.yu@intel.com> <20180607143705.3531-8-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143705.3531-8-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 09:26:36 -0700
Message-ID: <CALCETrXA--XrVNvPM4-Cv6-E6OFd=TZ5Gw_MWePt7MtqCBBqRg@mail.gmail.com>
Subject: Re: [PATCH 7/9] x86/mm: Shadow stack page fault error checking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> If a page fault is triggered by a shadow stack access (e.g.
> call/ret) or shadow stack management instructions (e.g.
> wrussq), then bit[6] of the page fault error code is set.
>
> In access_error(), we check if a shadow stack page fault
> is within a shadow stack memory area.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>

> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 73bd8c95ac71..2b3b9170109c 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1166,6 +1166,17 @@ access_error(unsigned long error_code, struct vm_area_struct *vma)
>                                        (error_code & X86_PF_INSTR), foreign))
>                 return 1;
>
> +       /*
> +        * Verify X86_PF_SHSTK is within a shadow stack VMA.
> +        * It is always an error if there is a shadow stack
> +        * fault outside a shadow stack VMA.
> +        */
> +       if (error_code & X86_PF_SHSTK) {
> +               if (!(vma->vm_flags & VM_SHSTK))
> +                       return 1;
> +               return 0;
> +       }
> +

What, if anything, would go wrong without this change?  It seems like
it might be purely an optimization.  If so, can you mention that in
the comment?
