Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 549D88E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 17:19:20 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r2-v6so1428561pgp.3
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 14:19:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h65-v6si20025114pfg.197.2018.09.18.14.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 14:19:18 -0700 (PDT)
Date: Tue, 18 Sep 2018 14:19:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: Fix panic caused by passing
 debug_guardpage_minorder or kernelcore to command line
Message-Id: <20180918141917.2cb16b01c122dbe1ead2f657@linux-foundation.org>
In-Reply-To: <1537284788-428784-1-git-send-email-zhe.he@windriver.com>
References: <1537284788-428784-1-git-send-email-zhe.he@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhe.he@windriver.com
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, osalvador@suse.de, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 18 Sep 2018 23:33:08 +0800 <zhe.he@windriver.com> wrote:

> From: He Zhe <zhe.he@windriver.com>
> 
> debug_guardpage_minorder_setup and cmdline_parse_kernelcore do not check
> input argument before using it. The argument would be a NULL pointer if
> "debug_guardpage_minorder" or "kernelcore", without its value, is set in
> command line and thus causes the following panic.
> 
> PANIC: early exception 0xe3 IP 10:ffffffffa08146f1 error 0 cr2 0x0
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.19.0-rc4-yocto-standard+ #1
> [    0.000000] RIP: 0010:parse_option_str+0x11/0x90
> ...
> [    0.000000] Call Trace:
> [    0.000000]  cmdline_parse_kernelcore+0x19/0x41
> [    0.000000]  do_early_param+0x57/0x8e
> [    0.000000]  parse_args+0x208/0x320
> [    0.000000]  ? rdinit_setup+0x30/0x30
> [    0.000000]  parse_early_options+0x29/0x2d
> [    0.000000]  ? rdinit_setup+0x30/0x30
> [    0.000000]  parse_early_param+0x36/0x4d
> [    0.000000]  setup_arch+0x336/0x99e
> [    0.000000]  start_kernel+0x6f/0x4ee
> [    0.000000]  x86_64_start_reservations+0x24/0x26
> [    0.000000]  x86_64_start_kernel+0x6f/0x72
> [    0.000000]  secondary_startup_64+0xa4/0xb0

>From my quick reading, more than half of the __setup handlers in mm/
will crash in the same way if misused in this fashion.

> This patch adds a check to prevent the panic and adds KBUILD_MODNAME to
> prints.

So a better solution might be to add a check into the calling code
(presumably in init/main.c) to print a warning if we have kernel
command line arguments such as "kernelcore=".  That way, users will see
the warning immediately before the oops and will know how to fix things
up.

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -14,6 +14,8 @@
>   *          (lots of bits borrowed from Ingo Molnar & Andrew Morton)
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/stddef.h>
>  #include <linux/mm.h>
>  #include <linux/swap.h>
> @@ -630,6 +632,11 @@ static int __init debug_guardpage_minorder_setup(char *buf)
>  {
>  	unsigned long res;
>  
> +	if (!buf) {
> +		pr_err("Config string not provided\n");

If were going to do it this way, we should tell the operator which
argument was bad.  pr_err("kernel option debug_guardpage_minorder
requires an argument").

And then perhaps we should just let the kernel crash anyway.  That
seems better than hoping that the user will notice that line in the
logs one day.  

And note that the preceding two paragraphs will produce the same result
as my do-it-in-init/main.c suggestion!
