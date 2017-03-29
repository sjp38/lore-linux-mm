Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A689E6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 07:04:28 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d69so11718923ith.20
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:04:28 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0125.outbound.protection.outlook.com. [104.47.1.125])
        by mx.google.com with ESMTPS id o127si6392195ite.99.2017.03.29.04.04.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 04:04:27 -0700 (PDT)
Subject: Re: [PATCH v2] module: check if memory leak by module.
References: <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcas5p1.samsung.com>
 <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <460c5798-1f4d-6fd0-cf32-349fbd605862@virtuozzo.com>
Date: Wed, 29 Mar 2017 14:05:39 +0300
MIME-Version: 1.0
In-Reply-To: <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maninder Singh <maninder1.s@samsung.com>, jeyu@redhat.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, chris@chris-wilson.co.uk, joonas.lahtinen@linux.intel.com, mhocko@suse.com, keescook@chromium.org, pavel@ucw.cz, jinb.park7@gmail.com, anisse@astier.eu, rafael.j.wysocki@intel.com, zijun_hu@htc.com, mingo@kernel.org, mawilcox@microsoft.com, thgarnie@google.com, joelaf@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: pankaj.m@samsung.com, ajeet.y@samsung.com, hakbong5.lee@samsung.com, a.sahrawat@samsung.com, lalit.mohan@samsung.com, cpgs@samsung.com, Vaneet Narang <v.narang@samsung.com>

On 03/29/2017 09:02 AM, Maninder Singh wrote:

> diff --git a/kernel/module.c b/kernel/module.c
> index f953df9..98a8018 100644
> --- a/kernel/module.c
> +++ b/kernel/module.c
> @@ -2117,9 +2117,31 @@ void __weak module_arch_freeing_init(struct module *mod)
>  {
>  }
>  
> +static void check_memory_leak(struct module *mod)
> +{
> +	struct vmap_area *va;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(va, &vmap_area_list, list) {

vmap_area_list is protected by spin_lock(&vmap_area_lock); not the RCU.

Also some other points:
 1) kmemleak already detects leaks of that kind.

 2) All this could be implemented in userspace, e.g. in rmmod tool
      - Read /proc/vmalloc and find areas belonging to the module
      - unload module
      - read /proc/vmalloc and check if anything left from that module

 3) This might produce false positives. E.g. module may defer vfree() in workqueue, so the 
     actual vfree() call happens after module unloaded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
