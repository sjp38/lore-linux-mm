Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54ECB6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 04:28:06 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so89353174lfw.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 01:28:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1si20291255wmc.33.2016.08.02.01.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 01:28:04 -0700 (PDT)
Subject: Re: [PATCH 09/10] x86, pkeys: allow configuration of init_pkru
References: <20160729163009.5EC1D38C@viggo.jf.intel.com>
 <20160729163023.407672D2@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2cd6331c-7fa7-b358-6892-580bef430755@suse.cz>
Date: Tue, 2 Aug 2016 10:28:03 +0200
MIME-Version: 1.0
In-Reply-To: <20160729163023.407672D2@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, dave.hansen@linux.intel.com, arnd@arndb.de

On 07/29/2016 06:30 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> As discussed in the previous patch, there is a reliability
> benefit to allowing an init value for the Protection Keys Rights
> User register (PKRU) which differs from what the XSAVE hardware
> provides.
>
> But, having PKRU be 0 (its init value) provides some nonzero
> amount of optimization potential to the hardware.  It can, for
> instance, skip writes to the XSAVE buffer when it knows that PKRU
> is in its init state.

I'm not very happy with tuning options that need the admin to make 
choice between reliability and performance. Is there no way to to 
optimize similarly for a non-zero init state?

> The cost of losing this optimization is approximately 100 cycles
> per context switch for a workload which lightly using XSAVE
> state (something not using AVX much).  The overhead comes from a
> combinaation of actually manipulating PKRU and the overhead of
> pullin in an extra cacheline.

So the cost is in extra steps in software, not in hardware as you 
mentioned above?

> This overhead is not huge, but it's also not something that I
> think we should unconditionally inflict on everyone.

Here, everyone means really all processes on system, that never heard of 
PKEs, and pay the cost just because the kernel was configured for it? 
But in that case, all PTEs use the key 0 anyway, so the non-zero default 
actually provides no extra reliability/security? Seems suboptimal that 
admins of such system have to recognize such situation themselves and 
change the default?

Vlastimil

> So, make it
> configurable both at boot-time and from debugfs.
>
> Changes to the debugfs value affect all processes created after
> the write to debugfs.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: linux-api@vger.kernel.org
> Cc: linux-arch@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: x86@kernel.org
> Cc: torvalds@linux-foundation.org
> Cc: akpm@linux-foundation.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: mgorman@techsingularity.net
> ---
>
>  b/arch/x86/mm/pkeys.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 67 insertions(+)
>
> diff -puN arch/x86/mm/pkeys.c~pkeys-141-restrictive-init-pkru-debugfs arch/x86/mm/pkeys.c
> --- a/arch/x86/mm/pkeys.c~pkeys-141-restrictive-init-pkru-debugfs	2016-07-29 09:18:59.811625219 -0700
> +++ b/arch/x86/mm/pkeys.c	2016-07-29 09:18:59.814625355 -0700
> @@ -11,6 +11,7 @@
>   * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
>   * more details.
>   */
> +#include <linux/debugfs.h>		/* debugfs_create_u32()		*/
>  #include <linux/mm_types.h>             /* mm_struct, vma, etc...       */
>  #include <linux/pkeys.h>                /* PKEY_*                       */
>  #include <uapi/asm-generic/mman-common.h>
> @@ -159,3 +160,69 @@ void copy_init_pkru_to_fpregs(void)
>  	 */
>  	write_pkru(init_pkru_value_snapshot);
>  }
> +
> +static ssize_t init_pkru_read_file(struct file *file, char __user *user_buf,
> +			     size_t count, loff_t *ppos)
> +{
> +	char buf[32];
> +	unsigned int len;
> +
> +	len = sprintf(buf, "0x%x\n", init_pkru_value);
> +	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
> +}
> +
> +static ssize_t init_pkru_write_file(struct file *file,
> +		 const char __user *user_buf, size_t count, loff_t *ppos)
> +{
> +	char buf[32];
> +	ssize_t len;
> +	u32 new_init_pkru;
> +
> +	len = min(count, sizeof(buf) - 1);
> +	if (copy_from_user(buf, user_buf, len))
> +		return -EFAULT;
> +
> +	/* Make the buffer a valid string that we can not overrun */
> +	buf[len] = '\0';
> +	if (kstrtouint(buf, 0, &new_init_pkru))
> +		return -EINVAL;
> +
> +	/*
> +	 * Don't allow insane settings that will blow the system
> +	 * up immediately if someone attempts to disable access
> +	 * or writes to pkey 0.
> +	 */
> +	if (new_init_pkru & (PKRU_AD_BIT|PKRU_WD_BIT))
> +		return -EINVAL;
> +
> +	WRITE_ONCE(init_pkru_value, new_init_pkru);
> +	return count;
> +}
> +
> +static const struct file_operations fops_init_pkru = {
> +	.read = init_pkru_read_file,
> +	.write = init_pkru_write_file,
> +	.llseek = default_llseek,
> +};
> +
> +static int __init create_init_pkru_value(void)
> +{
> +	debugfs_create_file("init_pkru", S_IRUSR | S_IWUSR,
> +			arch_debugfs_dir, NULL, &fops_init_pkru);
> +	return 0;
> +}
> +late_initcall(create_init_pkru_value);
> +
> +static __init int setup_init_pkru(char *opt)
> +{
> +	u32 new_init_pkru;
> +
> +	if (kstrtouint(opt, 0, &new_init_pkru))
> +		return 1;
> +
> +	WRITE_ONCE(init_pkru_value, new_init_pkru);
> +
> +	return 1;
> +}
> +__setup("init_pkru=", setup_init_pkru);
> +
> _
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
