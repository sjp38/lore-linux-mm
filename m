Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 047AA6B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 20:03:29 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id j4so141362094uaj.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:03:28 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id o21si30937935ita.100.2016.08.31.17.03.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 17:03:28 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id hb8so23301021pac.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:03:28 -0700 (PDT)
Date: Wed, 31 Aug 2016 17:03:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND PATCH v2] memory-hotplug: fix store_mem_state() return
 value
In-Reply-To: <20160831233811.g6kf24fdhnfhn637@arbab-vm>
Message-ID: <alpine.DEB.2.10.1608311652110.112811@chino.kir.corp.google.com>
References: <20160831150105.GB26702@kroah.com> <1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com> <20160831132557.c5cf0985e3da5f2850a10b1d@linux-foundation.org> <alpine.DEB.2.10.1608311402520.33967@chino.kir.corp.google.com>
 <20160831233811.g6kf24fdhnfhn637@arbab-vm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 31 Aug 2016, Reza Arbab wrote:

> > The correct fix is for store_mem_state() to return -EINVAL when
> > device_online() returns non-zero.
> 
> Let me put it to you this way--which one of these sysfs operations is behaving
> correctly?
> 
> 	# cd /sys/devices/system/memory/memory0
> 	# cat online
> 	1
> 	# echo 1 > online; echo $?
> 	0
> 
> or
> 
> 	# cd /sys/devices/system/memory/memory0
> 	# cat state
> 	online
> 	# echo online > state; echo $?
> 	-bash: echo: write error: Invalid argument
> 	1
> 
> One of them should change to match the other.
> 

Nope, the return value of changing state from online to online was 
established almost 11 years ago in commit 3947be1969a9.  This was broken 
by commit fa2be40fe7c0 ("drivers: base: use standard device online/offline 
for state change") which was not intended to introduce a functional 
change, but it did (memory_block_change_state() would have returned 
EINVAL, device_online() does not).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
