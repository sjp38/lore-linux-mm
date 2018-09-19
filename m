Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD0998E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 05:54:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l65-v6so2265169pge.17
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 02:54:03 -0700 (PDT)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id r18-v6si20033058pgj.194.2018.09.19.02.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 02:54:02 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: Fix panic caused by passing
 debug_guardpage_minorder or kernelcore to command line
References: <1537284788-428784-1-git-send-email-zhe.he@windriver.com>
 <20180918141917.2cb16b01c122dbe1ead2f657@linux-foundation.org>
From: He Zhe <zhe.he@windriver.com>
Message-ID: <1c32c1d2-a54a-30f7-1afb-ad6d3282f54a@windriver.com>
Date: Wed, 19 Sep 2018 17:51:40 +0800
MIME-Version: 1.0
In-Reply-To: <20180918141917.2cb16b01c122dbe1ead2f657@linux-foundation.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, osalvador@suse.de, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2018a1'09ae??19ae?JPY 05:19, Andrew Morton wrote:
> On Tue, 18 Sep 2018 23:33:08 +0800 <zhe.he@windriver.com> wrote:
>
>> From: He Zhe <zhe.he@windriver.com>
>>
>> debug_guardpage_minorder_setup and cmdline_parse_kernelcore do not check
>> input argument before using it. The argument would be a NULL pointer if
>> "debug_guardpage_minorder" or "kernelcore", without its value, is set in
>> command line and thus causes the following panic.
>>
>> PANIC: early exception 0xe3 IP 10:ffffffffa08146f1 error 0 cr2 0x0
>> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.19.0-rc4-yocto-standard+ #1
>> [    0.000000] RIP: 0010:parse_option_str+0x11/0x90
>> ...
>> [    0.000000] Call Trace:
>> [    0.000000]  cmdline_parse_kernelcore+0x19/0x41
>> [    0.000000]  do_early_param+0x57/0x8e
>> [    0.000000]  parse_args+0x208/0x320
>> [    0.000000]  ? rdinit_setup+0x30/0x30
>> [    0.000000]  parse_early_options+0x29/0x2d
>> [    0.000000]  ? rdinit_setup+0x30/0x30
>> [    0.000000]  parse_early_param+0x36/0x4d
>> [    0.000000]  setup_arch+0x336/0x99e
>> [    0.000000]  start_kernel+0x6f/0x4ee
>> [    0.000000]  x86_64_start_reservations+0x24/0x26
>> [    0.000000]  x86_64_start_kernel+0x6f/0x72
>> [    0.000000]  secondary_startup_64+0xa4/0xb0
> >From my quick reading, more than half of the __setup handlers in mm/
> will crash in the same way if misused in this fashion.
>
>> This patch adds a check to prevent the panic and adds KBUILD_MODNAME to
>> prints.
> So a better solution might be to add a check into the calling code
> (presumably in init/main.c) to print a warning if we have kernel
> command line arguments such as "kernelcore=".  That way, users will see
> the warning immediately before the oops and will know how to fix things
> up.

Thank you for your suggestion.

"kernelcore=" would not cause crash, "kernelcore' would. Andmany users of
early_param, e.g. the following two, depend on the validity of the "xxx"
format. If we fixed in the calling code, those parameters would become
invalid and need to be changed to a new format. That might affect too much.
Soit might be better to correct the users who misuse it.


static int __init cmdline_parse_movable_node(char *p)A A A A A A A A A A A A A A A A A A A A A A A A A A A 
{A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAPA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  movable_node_enabled = true;A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
#elseA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  pr_warn("movable_node parameter depends on CONFIG_HAVE_MEMBLOCK_NODE_MAP to work properly\n");
#endifA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  return 0;A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
}A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
early_param("movable_node", cmdline_parse_movable_node);


static int __init parse_alloc_mptable_opt(char *p)A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
{A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  enable_update_mptable = 1;A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
#ifdef CONFIG_PCIA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  pci_routeirq = 1;A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
#endifA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  alloc_mptable = 1;A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  if (!p)A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A A A A A A A A A  return 0;A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  mpc_new_length = memparse(p, &p);A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
A A A A A A A  return 0;A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
}A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A 
early_param("alloc_mptable", parse_alloc_mptable_opt);

>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -14,6 +14,8 @@
>>   *          (lots of bits borrowed from Ingo Molnar & Andrew Morton)
>>   */
>>  
>> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>> +
>>  #include <linux/stddef.h>
>>  #include <linux/mm.h>
>>  #include <linux/swap.h>
>> @@ -630,6 +632,11 @@ static int __init debug_guardpage_minorder_setup(char *buf)
>>  {
>>  	unsigned long res;
>>  
>> +	if (!buf) {
>> +		pr_err("Config string not provided\n");
> If were going to do it this way, we should tell the operator which
> argument was bad.  pr_err("kernel option debug_guardpage_minorder
> requires an argument").

Yes, this makes it more clear for users.I'd like to do in this way.

>
> And then perhaps we should just let the kernel crash anyway.  That
> seems better than hoping that the user will notice that line in the
> logs one day.  

If we want the PANIC info for these early parameters when crashing,
the parameter earlyprintk needs to be set correctly, especially in
embedded scenarios. Otherwise the system will hang without any error
info. Letting it boot up with an invalid parameter seems better than
that. And the owner of the parameter may give more errors to the
users if they don't get a valid value.

Thanks,
Zhe

>
> And note that the preceding two paragraphs will produce the same result
> as my do-it-in-init/main.c suggestion!
>
>
