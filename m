Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3396B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 16:37:20 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 101so208143472qtb.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 13:37:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u129si1851707pfu.78.2016.09.01.13.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 13:37:19 -0700 (PDT)
Date: Thu, 1 Sep 2016 13:37:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] memory-hotplug: fix store_mem_state() return value
Message-Id: <20160901133717.8d753013cfbb640dd28c2783@linux-foundation.org>
In-Reply-To: <1472743777-24266-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1472743777-24266-1-git-send-email-arbab@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  1 Sep 2016 10:29:37 -0500 Reza Arbab <arbab@linux.vnet.ibm.com> wrote:

> If store_mem_state() is called to online memory which is already online,
> it will return 1, the value it got from device_online().
> 
> This is wrong because store_mem_state() is a device_attribute .store
> function. Thus a non-negative return value represents input bytes read.
> 
> Set the return value to -EINVAL in this case.
> 

I actually made the mistake of reading this code.

What the heck are the return value semantics of bus_type.online? 
Sometimes 0, sometimes 1 and apparently sometimes -Efoo values.  What
are these things trying to tell the caller and why is "1" ever useful
and why doesn't anyone document anything.  grr.

And now I don't understand this patch.  Because:

static int memory_subsys_online(struct device *dev)
{
	struct memory_block *mem = to_memory_block(dev);
	int ret;

	if (mem->state == MEM_ONLINE)
		return 0;

Doesn't that "return 0" contradict the changelog?

Also, is store_mem_state() the correct place to fix this?  Instead,
should memory_block_change_state() detect an attempt to online
already-online memory and itself return -EINVAL, and permit that to be
propagated back?  Well, that depends on the bus_type.online rules which
appear to be undocumented.  What is the bus implementation supposed to
do when a request is made to online an already-online device?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
