Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 591966B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 11:17:42 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v81so101641401ywa.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 08:17:42 -0700 (PDT)
Received: from mail-qg0-x243.google.com (mail-qg0-x243.google.com. [2607:f8b0:400d:c04::243])
        by mx.google.com with ESMTPS id p10si5484467qgp.123.2016.05.11.08.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 08:17:41 -0700 (PDT)
Received: by mail-qg0-x243.google.com with SMTP id b14so2440953qge.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 08:17:41 -0700 (PDT)
Message-ID: <57334d15.524a370a.4b1f7.fffff006@mx.google.com>
Date: Wed, 11 May 2016 08:17:41 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH 2/3] memory-hotplug: more general validation of zone
 during online
In-Reply-To: <20160510203943.GA22115@arbab-laptop.austin.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
	<1462816419-4479-3-git-send-email-arbab@linux.vnet.ibm.com>
	<573223b8.c52b8d0a.9a3c0.6217@mx.google.com>
	<20160510203943.GA22115@arbab-laptop.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>


On Tue, 10 May 2016 15:39:43 -0500
Reza Arbab <arbab@linux.vnet.ibm.com> wrote:

> On Tue, May 10, 2016 at 11:08:56AM -0700, Yasuaki Ishimatsu wrote:
> >On Mon,  9 May 2016 12:53:38 -0500
> >Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
> >> * If X is lower than Y, the onlined memory must lie at the end of X.
> >> * If X is higher than Y, the onlined memory must lie at the start of X.
> >
> >If memory address has hole, memory address gets uncotinuous. Then memory
> >cannot be changed the zone by above the two conditions. So the conditions
> >shouold be removed.
> 
> I don't understand what you mean by this. Could you give an example?

> +int zone_can_shift(unsigned long pfn, unsigned long nr_pages,
> +		   enum zone_type target)
> +{
<snip>
> +	if (idx < target) {
> +		/* pages must be at end of current zone */
> +		if (pfn + nr_pages != zone_end_pfn(zone))
> +			return 0;
<snip>
> +	if (target < idx) {
> +		/* pages must be at beginning of current zone */
> +		if (pfn != zone->zone_start_pfn)
> +			return 0;

According your patch, memory address must be continuous for changing zone.
So if memory address is uncontinuous as follows, memory address 0x180000000-0x1FFFFFFFF
can be changed from ZONE_NORMAL to ZONE_MOVABLE. But memory address 0x80000000-0xFFFFFFFF
can not be changed from ZONE_NORMAL to ZONE_MOVABLE since it does not meet
above condition.

Memory address
  0x80000000 -  0xFFFFFFFF
 0x180000000 - 0x1FFFFFFFF

Thanks,
Yasuaki Ishimatsu




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
