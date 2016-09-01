Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 597326B0069
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 17:46:02 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id j4so204339421uaj.2
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 14:46:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c127si5738685qkd.190.2016.09.01.14.46.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 14:46:01 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u81LhGBH116734
	for <linux-mm@kvack.org>; Thu, 1 Sep 2016 17:46:01 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 256bg7kdrc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Sep 2016 17:46:01 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 1 Sep 2016 15:46:00 -0600
Date: Thu, 1 Sep 2016 16:45:53 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v3] memory-hotplug: fix store_mem_state() return value
References: <1472743777-24266-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20160901133717.8d753013cfbb640dd28c2783@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160901133717.8d753013cfbb640dd28c2783@linux-foundation.org>
Message-Id: <20160901214553.h7mbmpyzcuxgnloy@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 01, 2016 at 01:37:17PM -0700, Andrew Morton wrote:
>What the heck are the return value semantics of bus_type.online?
>Sometimes 0, sometimes 1 and apparently sometimes -Efoo values.  What
>are these things trying to tell the caller and why is "1" ever useful
>and why doesn't anyone document anything.  grr.

You might be getting tangled in the two codepaths the way I was.

If you do 'echo 1 > online':
	dev_attr_store
		online_store
			device_online
				memory_subsys_online
					memory_block_change_state

If you do 'echo online > state':
	dev_attr_store
		store_mem_state
			device_online
				memory_subsys_online
					memory_block_change_state

>static int memory_subsys_online(struct device *dev)
>{
>	struct memory_block *mem = to_memory_block(dev);
>	int ret;
>
>	if (mem->state == MEM_ONLINE)
>		return 0;
>
>Doesn't that "return 0" contradict the changelog?

The online-to-online check being used is higher in the call chain:

int device_online(struct device *dev)
{
	if (device_supports_offline(dev)) {
		if (dev->offline) {
			...
		} else {
			ret = 1;
		}
	}

>Also, is store_mem_state() the correct place to fix this?  Instead,
>should memory_block_change_state() detect an attempt to online
>already-online memory and itself return -EINVAL, and permit that to be
>propagated back?

Doing that would affect both codepaths, and as David made clear, would 
break backwards compatibility because their established behaviors are 
different.

'echo 1 > online' returns 0 if the device is already online
'echo online > state' returns -EINVAL if the device is already online

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
