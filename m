Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29E346B0005
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:09:51 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id r3-v6so7723839ybg.7
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:09:51 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t141si2178044ywf.332.2018.03.05.08.09.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:09:50 -0800 (PST)
Subject: Re: [PATCH 34/34] x86/mm/pti: Add Warning when booting on a PCIE
 capable CPU
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-35-git-send-email-joro@8bytes.org>
From: Denys Vlasenko <dvlasenk@redhat.com>
Message-ID: <c024f4d3-4780-5d62-a36a-8ccd79bc6299@redhat.com>
Date: Mon, 5 Mar 2018 17:09:44 +0100
MIME-Version: 1.0
In-Reply-To: <1520245563-8444-35-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On 03/05/2018 11:26 AM, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> Warn the user in case the performance can be significantly
> improved by switching to a 64-bit kernel.
> 
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>   arch/x86/mm/pti.c | 16 ++++++++++++++++
>   1 file changed, 16 insertions(+)
> 
> diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
> index 3ffd923..8f5aa0d 100644
> --- a/arch/x86/mm/pti.c
> +++ b/arch/x86/mm/pti.c
> @@ -385,6 +385,22 @@ void __init pti_init(void)
>   
>   	pr_info("enabled\n");
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

Isn't it a bit too dramatic? Not one, but two lines of big fat warnings?

There are people who run 32-bit kernels on purpose, not because they
did not yet realize 64 bits are upon us.

E.g. industrial setups with strict regulations and licensing requirements.
In many such cases they already are more than satisfied with CPU speeds,
thus not interested in 64-bit migration for performance reasons,
and avoid it because it would incur mountains of paperwork
with no tangible gains.

The big fat warning on every boot would be irritating.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
