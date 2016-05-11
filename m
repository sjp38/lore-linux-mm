Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1176B0253
	for <linux-mm@kvack.org>; Wed, 11 May 2016 15:23:37 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id c67so110312213vkh.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 12:23:37 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id s205si6239023qhs.11.2016.05.11.12.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 11 May 2016 12:23:36 -0700 (PDT)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 11 May 2016 13:23:35 -0600
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 03A3C1FF004B
	for <linux-mm@kvack.org>; Wed, 11 May 2016 13:23:17 -0600 (MDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u4BJNWtJ36700270
	for <linux-mm@kvack.org>; Wed, 11 May 2016 19:23:32 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u4BJNUqs028065
	for <linux-mm@kvack.org>; Wed, 11 May 2016 15:23:31 -0400
Date: Wed, 11 May 2016 14:23:26 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] memory-hotplug: more general validation of zone
 during online
Message-ID: <20160511192326.GE22115@arbab-laptop.austin.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1462816419-4479-3-git-send-email-arbab@linux.vnet.ibm.com>
 <573223b8.c52b8d0a.9a3c0.6217@mx.google.com>
 <20160510203943.GA22115@arbab-laptop.austin.ibm.com>
 <57334d15.524a370a.4b1f7.fffff006@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <57334d15.524a370a.4b1f7.fffff006@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Wed, May 11, 2016 at 08:17:41AM -0700, Yasuaki Ishimatsu wrote:
>On Tue, 10 May 2016 15:39:43 -0500
>Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
><snip>
>> +	if (idx < target) {
>> +		/* pages must be at end of current zone */
>> +		if (pfn + nr_pages != zone_end_pfn(zone))
>> +			return 0;
><snip>
>> +	if (target < idx) {
>> +		/* pages must be at beginning of current zone */
>> +		if (pfn != zone->zone_start_pfn)
>> +			return 0;
>
>According your patch, memory address must be continuous for changing zone.
>So if memory address is uncontinuous as follows, memory address 0x180000000-0x1FFFFFFFF
>can be changed from ZONE_NORMAL to ZONE_MOVABLE. But memory address 0x80000000-0xFFFFFFFF
>can not be changed from ZONE_NORMAL to ZONE_MOVABLE since it does not meet
>above condition.
>
>Memory address
>  0x80000000 -  0xFFFFFFFF
> 0x180000000 - 0x1FFFFFFFF

Ah, I see. What do you think of this instead?

<snip>
+	if (idx < target) {
+		/* must be the last pages present in current zone */
+		for (i = pfn + nr_pages; i < zone_end_pfn(zone); i++)
+			if (pfn_present(i))
+				return 0;
<snip>
+	if (target < idx) {
+		/* must be the first pages present in current zone */
+		for (i = zone->zone_start_pfn; i < pfn; i++)
+			if (pfn_present(i))
+				return 0;

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
