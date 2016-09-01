Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35B4E6B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 20:28:29 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id j4so142535927uaj.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:28:29 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id kv2si2340068pab.145.2016.08.31.17.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 17:28:28 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id cy9so23513884pac.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:28:28 -0700 (PDT)
Date: Wed, 31 Aug 2016 17:28:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND PATCH v2] memory-hotplug: fix store_mem_state() return
 value
In-Reply-To: <20160901001751.m3z2snlop2djzqgd@arbab-vm>
Message-ID: <alpine.DEB.2.10.1608311722080.24833@chino.kir.corp.google.com>
References: <20160831150105.GB26702@kroah.com> <1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com> <20160831132557.c5cf0985e3da5f2850a10b1d@linux-foundation.org> <alpine.DEB.2.10.1608311402520.33967@chino.kir.corp.google.com> <20160831233811.g6kf24fdhnfhn637@arbab-vm>
 <alpine.DEB.2.10.1608311652110.112811@chino.kir.corp.google.com> <20160901001751.m3z2snlop2djzqgd@arbab-vm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 31 Aug 2016, Reza Arbab wrote:

> > Nope, the return value of changing state from online to online was
> > established almost 11 years ago in commit 3947be1969a9.
> 
> Fair enough. So if online-to-online is -EINVAL, 

online-to-online for state is -EINVAL, it has been since 2005.

> 1. Shouldn't 'echo 1 > online' then also return -EINVAL?
> 

No, it's a different tunable.  There's no requirement that two different 
tunables that do a similar thing have the same return values: the former 
existed long before device_online() and still exists for backwards 
compatibility.

> 2. store_mem_state() still needs a tweak, right? It was only returning -EINVAL
> by accident, due to the convoluted sequence I listed in the patch.
> 

Yes, absolutely.  It returning -EINVAL for "nline" is what is accidently 
preserving it's backwards compatibility :)  Note that device_online() 
returns 1 if already online and memory_subsys_online() returns 0 if online 
in this case.  So we want store_mem_state() to return -EINVAL if 
device_online() returns non-zero (this was in my first email).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
