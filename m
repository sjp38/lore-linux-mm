Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id D782F6B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 13:24:54 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id u23so231397639vkb.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 10:24:54 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id v63si12622958qhc.83.2016.05.13.10.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 10:24:53 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id i7so8814821qkd.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 10:24:53 -0700 (PDT)
Message-ID: <57360de4.ec5c8c0a.ebac0.50c6@mx.google.com>
Date: Fri, 13 May 2016 10:24:52 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH 2/3] memory-hotplug: more general validation of zone
 during online
In-Reply-To: <20160511192326.GE22115@arbab-laptop.austin.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
	<1462816419-4479-3-git-send-email-arbab@linux.vnet.ibm.com>
	<573223b8.c52b8d0a.9a3c0.6217@mx.google.com>
	<20160510203943.GA22115@arbab-laptop.austin.ibm.com>
	<57334d15.524a370a.4b1f7.fffff006@mx.google.com>
	<20160511192326.GE22115@arbab-laptop.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>


On Wed, 11 May 2016 14:23:26 -0500
Reza Arbab <arbab@linux.vnet.ibm.com> wrote:

> On Wed, May 11, 2016 at 08:17:41AM -0700, Yasuaki Ishimatsu wrote:
> >On Tue, 10 May 2016 15:39:43 -0500
> >Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
> ><snip>
> >> +	if (idx < target) {
> >> +		/* pages must be at end of current zone */
> >> +		if (pfn + nr_pages != zone_end_pfn(zone))
> >> +			return 0;
> ><snip>
> >> +	if (target < idx) {
> >> +		/* pages must be at beginning of current zone */
> >> +		if (pfn != zone->zone_start_pfn)
> >> +			return 0;
> >
> >According your patch, memory address must be continuous for changing zone.
> >So if memory address is uncontinuous as follows, memory address 0x180000000-0x1FFFFFFFF
> >can be changed from ZONE_NORMAL to ZONE_MOVABLE. But memory address 0x80000000-0xFFFFFFFF
> >can not be changed from ZONE_NORMAL to ZONE_MOVABLE since it does not meet
> >above condition.
> >
> >Memory address
> >  0x80000000 -  0xFFFFFFFF
> > 0x180000000 - 0x1FFFFFFFF
> 
> Ah, I see. What do you think of this instead?
> 
> <snip>
> +	if (idx < target) {
> +		/* must be the last pages present in current zone */
> +		for (i = pfn + nr_pages; i < zone_end_pfn(zone); i++)
> +			if (pfn_present(i))
> +				return 0;
> <snip>
> +	if (target < idx) {
> +		/* must be the first pages present in current zone */
> +		for (i = zone->zone_start_pfn; i < pfn; i++)
> +			if (pfn_present(i))
> +				return 0;
> 
> -- 

Ahh, sorry. I completely misread your patch. And I understood that
you don't need to change your first patch.

Thank,
Yasuaki Ishimatsu

> Reza Arbab
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
