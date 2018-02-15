Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 844136B0005
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:46:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r1so3966059pgp.2
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:46:37 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c21si2604643pfk.354.2018.02.15.05.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 05:46:36 -0800 (PST)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1FDg2pq158292
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:46:35 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2g5b2k84cy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:46:35 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w1FDkYJV016708
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:46:34 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w1FDkXww029992
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:46:34 GMT
Received: by mail-ot0-f179.google.com with SMTP id e64so23409373ote.4
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:46:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180215124320.GE7275@dhcp22.suse.cz>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-5-pasha.tatashin@oracle.com> <20180215124320.GE7275@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 15 Feb 2018 08:46:33 -0500
Message-ID: <CAOAebxsf21pKsHoJQ7+5mWnfj=TA_Nd2h=YvuEfj=SmpFfvjxQ@mail.gmail.com>
Subject: Re: [PATCH v3 4/4] mm/memory_hotplug: optimize memory hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

> This should be a separate patch IMHO. It is an optimization on its
> own. The original code tries to be sparse neutral but we do depend on
> sparse anyway.

Yes, Mingo already asked me to split this patch. I've done just that
and will send it out soon.

>
> [...]
>>  /* register memory section under specified node if it spans that node */
>> -int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>> +int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
>> +                              bool check_nid)
>
> This check_nid begs for a documentation. When do we need to set it? I
> can see that register_new_memory path doesn't check node id. It is quite
> reasonable to expect that a new memblock doesn't span multiple numa
> nodes which can be the case for register_one_node but a word or two are
> really due.

OK, I will add a comment, and BTW, this is also going to be a separate
patch for ease of review.

>
>>  {
>>       int ret;
>>       unsigned long pfn, sect_start_pfn, sect_end_pfn;
>> @@ -423,11 +424,13 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>>                       continue;
>>               }
>>
>> -             page_nid = get_nid_for_pfn(pfn);
>> -             if (page_nid < 0)
>> -                     continue;
>> -             if (page_nid != nid)
>> -                     continue;
>> +             if (check_nid) {
>> +                     page_nid = get_nid_for_pfn(pfn);
>> +                     if (page_nid < 0)
>> +                             continue;
>> +                     if (page_nid != nid)
>> +                             continue;
>> +             }
>>               ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
>>                                       &mem_blk->dev.kobj,
>>                                       kobject_name(&mem_blk->dev.kobj));
>> @@ -502,7 +505,7 @@ int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
>>
>>               mem_blk = find_memory_block_hinted(mem_sect, mem_blk);
>>
>> -             ret = register_mem_sect_under_node(mem_blk, nid);
>> +             ret = register_mem_sect_under_node(mem_blk, nid, true);
>>               if (!err)
>>                       err = ret;
>>
>
> I would be tempted to split this into a separate patch as well. The
> review will be much easier.

Yes, but that would be the last patch in the series.

> This is quite ugly. You allocate 256MB for small numa systems and 512MB
> for larger NUMAs unconditionally for MEMORY_HOTPLUG. I see you need it
> to safely replace page_to_nid by get_section_nid but this is just too
> high of the price. Please note that this shouldn't be really needed. At
> least not for onlining. We already _do_ know the node association with
> the pfn range. So we should be able to get the nid from memblock.

OK, I will think for a different place to store nid temporarily, or
how to get it.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
