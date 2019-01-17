Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9598E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 02:54:29 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 75so6767779pfq.8
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 23:54:28 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s13si823279pgh.583.2019.01.16.23.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 23:54:27 -0800 (PST)
Date: Thu, 17 Jan 2019 16:54:22 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 17/17] module: Prevent module removal racing with
 text_poke()
Message-Id: <20190117165422.d33d1af83db8716e24960a3c@kernel.org>
In-Reply-To: <20190117003259.23141-18-rick.p.edgecombe@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	<20190117003259.23141-18-rick.p.edgecombe@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Nadav Amit <namit@vmware.com>

On Wed, 16 Jan 2019 16:32:59 -0800
Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> From: Nadav Amit <namit@vmware.com>
> 
> It seems dangerous to allow code modifications to take place
> concurrently with module unloading. So take the text_mutex while the
> memory of the module is freed.

At that point, since the module itself is removed from module list,
it seems no actual harm. Or would you have any concern?

Thank you,

> 
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  kernel/module.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/kernel/module.c b/kernel/module.c
> index 1af5c8e19086..90cfc4988d98 100644
> --- a/kernel/module.c
> +++ b/kernel/module.c
> @@ -64,6 +64,7 @@
>  #include <linux/bsearch.h>
>  #include <linux/dynamic_debug.h>
>  #include <linux/audit.h>
> +#include <linux/memory.h>
>  #include <uapi/linux/module.h>
>  #include "module-internal.h"
>  
> @@ -2157,6 +2158,9 @@ static void free_module(struct module *mod)
>  	synchronize_rcu();
>  	mutex_unlock(&module_mutex);
>  
> +	/* Protect against patching of the module while it is being removed */
> +	mutex_lock(&text_mutex);
> +
>  	/* This may be empty, but that's OK */
>  	module_arch_freeing_init(mod);
>  	module_memfree(mod->init_layout.base);
> @@ -2168,6 +2172,7 @@ static void free_module(struct module *mod)
>  
>  	/* Finally, free the core (containing the module structure) */
>  	module_memfree(mod->core_layout.base);
> +	mutex_unlock(&text_mutex);
>  }
>  
>  void *__symbol_get(const char *symbol)
> -- 
> 2.17.1
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
