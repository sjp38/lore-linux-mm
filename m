Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06D216B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:06:18 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id 18so7735257ybc.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:06:18 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id pv7si1534967pac.166.2016.08.31.14.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 14:06:17 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id h186so23122728pfg.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:06:17 -0700 (PDT)
Date: Wed, 31 Aug 2016 14:06:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND PATCH v2] memory-hotplug: fix store_mem_state() return
 value
In-Reply-To: <20160831132557.c5cf0985e3da5f2850a10b1d@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1608311402520.33967@chino.kir.corp.google.com>
References: <20160831150105.GB26702@kroah.com> <1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com> <20160831132557.c5cf0985e3da5f2850a10b1d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 31 Aug 2016, Andrew Morton wrote:

> > Attempting to online memory which is already online will cause this:
> > 
> > 1. store_mem_state() called with buf="online"
> > 2. device_online() returns 1 because device is already online
> > 3. store_mem_state() returns 1
> > 4. calling code interprets this as 1-byte buffer read
> > 5. store_mem_state() called again with buf="nline"
> > 6. store_mem_state() returns -EINVAL
> > 
> > Example:
> > 
> > $ cat /sys/devices/system/memory/memory0/state
> > online
> > $ echo online > /sys/devices/system/memory/memory0/state
> > -bash: echo: write error: Invalid argument
> > 
> > Fix the return value of store_mem_state() so this doesn't happen.
> 
> So..  what *does* happen after the patch?  Is some sort of failure still
> reported?  Or am I correct in believing that the operation will appear
> to have succeeded?  If so, is that desirable?
> 

It's not desirable, before commit 4f3549d72 this would have returned 
EINVAL since __memory_block_change_state() does not see the state as 
MEM_OFFLINE when the write is done.  The correct fix is for 
store_mem_state() to return -EINVAL when device_online() returns non-zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
