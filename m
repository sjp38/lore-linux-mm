Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD416B0024
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 08:39:36 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id g13so14147968qtj.15
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 05:39:36 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r129si4377490qkd.206.2018.03.05.05.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 05:39:34 -0800 (PST)
Subject: Re: [PATCH 34/34] x86/mm/pti: Add Warning when booting on a PCIE
 capable CPU
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-35-git-send-email-joro@8bytes.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <d879496a-887d-9077-3a7d-ee878a691bdc@redhat.com>
Date: Mon, 5 Mar 2018 08:39:28 -0500
MIME-Version: 1.0
In-Reply-To: <1520245563-8444-35-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On 03/05/2018 05:26 AM, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Warn the user in case the performance can be significantly
> improved by switching to a 64-bit kernel.
>
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/mm/pti.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
>
> diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
> index 3ffd923..8f5aa0d 100644
> --- a/arch/x86/mm/pti.c
> +++ b/arch/x86/mm/pti.c
> @@ -385,6 +385,22 @@ void __init pti_init(void)
>  
>  	pr_info("enabled\n");
>  
> +#ifdef CONFIG_X86_32
> +	if (boot_cpu_has(X86_FEATURE_PCID)) {
> +		/* Use printk to work around pr_fmt() */
> +		printk(KERN_WARNING "\n");
> +		printk(KERN_WARNING "************************************************************\n");
> +		printk(KERN_WARNING "** WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!  **\n");
> +		printk(KERN_WARNING "**                                                        **\n");
> +		printk(KERN_WARNING "** You are using 32-bit PTI on a 64-bit PCID-capable CPU. **\n");
> +		printk(KERN_WARNING "** Your performance will increase dramatically if you     **\n");
> +		printk(KERN_WARNING "** switch to a 64-bit kernel!                             **\n");
> +		printk(KERN_WARNING "**                                                        **\n");
> +		printk(KERN_WARNING "** WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!  **\n");
> +		printk(KERN_WARNING "************************************************************\n");
> +	}
> +#endif
> +
>  	pti_clone_user_shared();
>  	pti_clone_entry_text();
>  	pti_setup_espfix64();

Typo in the patch title: PCIE => PCID.

-Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
