Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 198998E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:28:48 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so3459600edb.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:28:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si3083886edq.352.2019.01.17.01.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 01:28:46 -0800 (PST)
Date: Thu, 17 Jan 2019 10:28:42 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 21/21] memblock: drop memblock_alloc_*_nopanic() variants
Message-ID: <20190117092842.wnvsc6em5mxga3rn@pathway.suse.cz>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-22-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547646261-32535-22-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org

On Wed 2019-01-16 15:44:21, Mike Rapoport wrote:
> As all the memblock allocation functions return NULL in case of error
> rather than panic(), the duplicates with _nopanic suffix can be removed.

[...]

> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index c4f0a41..ae65221 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -1147,17 +1147,14 @@ void __init setup_log_buf(int early)
>  	if (!new_log_buf_len)
>  		return;
>  
> -	if (early) {
> -		new_log_buf =
> -			memblock_alloc(new_log_buf_len, LOG_ALIGN);
> -	} else {
> -		new_log_buf = memblock_alloc_nopanic(new_log_buf_len,
> -							  LOG_ALIGN);
> -	}
> -
> +	new_log_buf = memblock_alloc(new_log_buf_len, LOG_ALIGN);

The above change is enough.

>  	if (unlikely(!new_log_buf)) {
> -		pr_err("log_buf_len: %lu bytes not available\n",
> -			new_log_buf_len);
> +		if (early)
> +			panic("log_buf_len: %lu bytes not available\n",
> +				new_log_buf_len);

panic() is not needed here. printk() will just continue using
the (smaller) static buffer.

> +		else
> +			pr_err("log_buf_len: %lu bytes not available\n",
> +			       new_log_buf_len);
>  		return;
>  	}

Best Regards,
Petr
