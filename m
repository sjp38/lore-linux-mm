Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0356B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 18:40:07 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so727806pdj.26
        for <linux-mm@kvack.org>; Tue, 20 May 2014 15:40:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fu6si7227117pac.106.2014.05.20.15.40.06
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 15:40:06 -0700 (PDT)
Date: Tue, 20 May 2014 15:40:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mem-hotplug: Avoid illegal state prefixed with
 legal state when changing state of memory_block.
Message-Id: <20140520154004.cc8599e59bc8ea3e1e9d82e5@linux-foundation.org>
In-Reply-To: <1400208149-9041-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1400208149-9041-1-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, hpa@zytor.com, toshi.kani@hp.com, mingo@elte.hu, hutao@cn.fujitsu.com, laijs@cn.fujitsu.com, guz.fnst@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 16 May 2014 10:42:29 +0800 Tang Chen <tangchen@cn.fujitsu.com> wrote:

> We use the following command to online a memory_block:
> 
> echo online|online_kernel|online_movable > /sys/devices/system/memory/memoryXXX/state
> 
> But, if we typed "online_movbale" by mistake (typo, not "online_movable"), it will be 
> recognized as "online", and it will online the memory block successfully. "online" command
> will put the memory block into the same zone as it was in before last offlined, which may 
> be ZONE_NORMAL, not ZONE_MOVABLE. Since it succeeds without any warning, it may confuse 
> users.
> 
> ...
>
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -319,19 +319,27 @@ store_mem_state(struct device *dev,
>  		struct device_attribute *attr, const char *buf, size_t count)
>  {
>  	struct memory_block *mem = to_memory_block(dev);
> -	int ret, online_type;
> +	int ret, online_type, len;
>  
>  	ret = lock_device_hotplug_sysfs();
>  	if (ret)
>  		return ret;
>  
> -	if (!strncmp(buf, "online_kernel", min_t(int, count, 13)))
> +	/*
> +	 * count passed from user space includes \0, so the real length
> +	 * is count-1.
> +	 */
> +	len = count - 1;
> +
> +	if (len == strlen("online_kernel") &&
> +	    !strncmp(buf, "online_kernel", len))
>  		online_type = ONLINE_KERNEL;
> -	else if (!strncmp(buf, "online_movable", min_t(int, count, 14)))
> +	else if (len == strlen("online_movable") &&
> +		 !strncmp(buf, "online_movable", len))
>  		online_type = ONLINE_MOVABLE;
> -	else if (!strncmp(buf, "online", min_t(int, count, 6)))
> +	else if (len == strlen("online") && !strncmp(buf, "online", len))
>  		online_type = ONLINE_KEEP;
> -	else if (!strncmp(buf, "offline", min_t(int, count, 7)))
> +	else if (len == strlen("offline") && !strncmp(buf, "offline", len))
>  		online_type = -1;
>  	else {
>  		ret = -EINVAL;

hm, why is this code so complicated?  Is it because it is trying not to
trip over possibly-absent trailing newline?  If so, please take a look
at sysfs_streq().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
