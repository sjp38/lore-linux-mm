Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6093B6B0038
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 11:09:08 -0400 (EDT)
Received: by mail-yk0-f169.google.com with SMTP id q200so2142109ykb.14
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:09:08 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id j3si6165116yhc.175.2014.06.13.08.09.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 08:09:07 -0700 (PDT)
Message-ID: <1402671597.7963.15.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 1/2] mem-hotplug: Avoid illegal state prefixed with
 legal state when changing state of memory_block.
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 13 Jun 2014 08:59:57 -0600
In-Reply-To: <1402027134-14423-2-git-send-email-tangchen@cn.fujitsu.com>
References: <1402027134-14423-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1402027134-14423-2-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, tj@kernel.org, hpa@zytor.com, mingo@elte.hu, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, hutao@cn.fujitsu.com, guz.fnst@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2014-06-06 at 11:58 +0800, Tang Chen wrote:
> We use the following command to online a memory_block:
> 
> echo online|online_kernel|online_movable > /sys/devices/system/memory/memoryXXX/state
> 
> But, if we do the following:
> 
> echo online_fhsjkghfkd > /sys/devices/system/memory/memoryXXX/state
> 
> the block will also be onlined.
> 
> This is because the following code in store_mem_state() does not compare the whole string,
> but only the prefix of the string.
> 
> store_mem_state()
> {
> 	......
>  328         if (!strncmp(buf, "online_kernel", min_t(int, count, 13)))
> 
> Here, only compare the first 13 letters of the string. If we give "online_kernelXXXXXX",
> it will be recognized as online_kernel, which is incorrect.
> 
>  329                 online_type = ONLINE_KERNEL;
>  330         else if (!strncmp(buf, "online_movable", min_t(int, count, 14)))
> 
> We have the same problem here,
> 
>  331                 online_type = ONLINE_MOVABLE;
>  332         else if (!strncmp(buf, "online", min_t(int, count, 6)))
> 
> here,
> 
> (Here is more problematic. If we give online_movalbe, which is a typo of online_movable,
>  it will be recognized as online without noticing the author.)
> 
>  333                 online_type = ONLINE_KEEP;
>  334         else if (!strncmp(buf, "offline", min_t(int, count, 7)))
> 
> and here.
> 
>  335                 online_type = -1;
>  336         else {
>  337                 ret = -EINVAL;
>  338                 goto err;
>  339         }
> 	......
> }
> 
> This patch fix this problem by using sysfs_streq() to compare the whole string.
> 
> Reported-by: Hu Tao <hutao@cn.fujitsu.com>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
