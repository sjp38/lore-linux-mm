Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 991346B0038
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 15:39:53 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id hz1so6350960pad.9
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:39:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e4si2184330pas.199.2015.02.11.12.39.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 12:39:49 -0800 (PST)
Date: Wed, 11 Feb 2015 12:39:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] driver core: export
 lock_device_hotplug/unlock_device_hotplug
Message-Id: <20150211123947.3318933f2aca54e11324b088@linux-foundation.org>
In-Reply-To: <1423669462-30918-2-git-send-email-vkuznets@redhat.com>
References: <1423669462-30918-1-git-send-email-vkuznets@redhat.com>
	<1423669462-30918-2-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, 11 Feb 2015 16:44:20 +0100 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:

> add_memory() is supposed to be run with device_hotplug_lock grabbed, otherwise
> it can race with e.g. device_online(). Allow external modules (hv_balloon for
> now) to lock device hotplug.
> 
> ...
>
> --- a/drivers/base/core.c
> +++ b/drivers/base/core.c
> @@ -55,11 +55,13 @@ void lock_device_hotplug(void)
>  {
>  	mutex_lock(&device_hotplug_lock);
>  }
> +EXPORT_SYMBOL_GPL(lock_device_hotplug);
>  
>  void unlock_device_hotplug(void)
>  {
>  	mutex_unlock(&device_hotplug_lock);
>  }
> +EXPORT_SYMBOL_GPL(unlock_device_hotplug);
>  
>  int lock_device_hotplug_sysfs(void)
>  {

It's kinda crazy that lock_device_hotplug_sysfs() didn't get any
documentation.  I suggest adding this while you're in there:


--- a/drivers/base/core.c~a
+++ a/drivers/base/core.c
@@ -61,6 +61,9 @@ void unlock_device_hotplug(void)
 	mutex_unlock(&device_hotplug_lock);
 }
 
+/*
+ * "git show 5e33bc4165f3ed" for details
+ */
 int lock_device_hotplug_sysfs(void)
 {
 	if (mutex_trylock(&device_hotplug_lock))

which is a bit lazy but whatev.

I'll assume that Greg (or Rafael?) will be processing this patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
