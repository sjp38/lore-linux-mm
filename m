Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BD6AC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:21:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B4F020679
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 14:21:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B4F020679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 764B78E0005; Wed, 31 Jul 2019 10:21:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 715B08E0001; Wed, 31 Jul 2019 10:21:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 605578E0005; Wed, 31 Jul 2019 10:21:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4164C8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:21:48 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id q196so51826221ybg.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:21:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=2juxTmh+9wBrb4WwhkNRSKV161WiiGXZjFyeYQzKMno=;
        b=j23MICVz+tw7Y4H09Dlag6xYFsNDJOBG5jImo4+EElzUTaJo0WfB2x9/aIJsiZ4vaX
         /2tczq6e/9lm1xhBhyaAhT0Jwvj5NRpANNT4noGqM0sb3RUjyolXRUUt6TSzsXHm2vB2
         j7CxeSQEGdPJPsLYNfkpJjrHCiZl0dgATKGRTrRGfoF/0RDT87Wa7LO9D0c0+8zLHbh2
         EI8ZiE9GztGVUMwgERvxL9Pz0OdMEFM5H5mAHQe+t94o2Zf3XQKxMgKjeNMckd5xjPKq
         b8hjMn66kwjqdxph7GXgZ+W/hhseYFHZ/p6v3cpsHr2LuB05lBmI4KV89fkGCocOyzDx
         RYqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUnv8BK2sRNTVIoGag8n6VZuul5nPsSKPWogcq+luUlJrsWhio8
	u+oLHJhzsKOwI3NSNYpCY6afWb9bSVF/rhcRos9OgTNfGV6NFqR6aesR4ST17f1oHtdJ/KpVQbB
	/wI5S5l3Hrn/2gOir2SSbrfcZzEAkQPa7gv/G1Yex+Yu5SL5lF9V3qJTi7HlDyOyFEw==
X-Received: by 2002:a81:5386:: with SMTP id h128mr73838736ywb.509.1564582907926;
        Wed, 31 Jul 2019 07:21:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNfAx4OsxxMJZbHqHmmfEkiO33gLv2FamzEJ6HyEXFwbvHTU6AvLPSzZ4f+shS3XnJ0h7o
X-Received: by 2002:a81:5386:: with SMTP id h128mr73838681ywb.509.1564582907240;
        Wed, 31 Jul 2019 07:21:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564582907; cv=none;
        d=google.com; s=arc-20160816;
        b=JO0YWR7KJwRoJ7KYxz2v0O9hTI46yIahX5bB/yTYuyZKIYJjmzldsKUrb3LB2EjByW
         Yc374Xa82S2o4zM1StkygA3b9Slt0cremvWjMKXS8YYdx8t9RMhi+HmgHzF+BLJqawed
         k/P0ERdD9mwCJVNxU0FgEoSMWmhscFFaS4epxQp7hYrKUTZ77o59JINGI1T3uNnwrBaS
         q1A3ho+gF+j0a/hIpD1nIWW8k8vyEPTb1A1zKvHY/Mnw6Ejk/VTHIuCkYNkmKvco87xU
         LnWtEIXsmGNkidz2gapp4mBYLwcotOviiFJ9G3YjmDrCyUAlI5Y+1mYH5X8oy2OtayTR
         BZqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=2juxTmh+9wBrb4WwhkNRSKV161WiiGXZjFyeYQzKMno=;
        b=BXJ1vrmlA8eNMyrcpone9ReeUvLi67Rot4z6bC12CUltu5pcp8YLYn4pT+DKeV/uQH
         2YccKRfrydcTPaaBw97H4DZQCOFoCqxzLknKeTCOXlIAC4j3VwgymfNFTEZKD3Yv9Puh
         OyZk0qxI/myXmaNuL2mTMU9VS851w7o6azu7oBV9BcfGVhpHwkq3yXWkFVG1WuoZVOIf
         SqBDpDMCjeY+vhSZLQ4m7EItKHch2Lz4/Mtpb56OILAw7NL0oJrxg19STKPrYWbu9rXb
         hOxlpoRID3182EcHAbZN8xLd3TAEz1NEhKJV56gEg17cSkuHghv1TBp8U5vky0pSwTLE
         OUaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j10si22537473ybb.217.2019.07.31.07.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 07:21:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6VEFIJe026895
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:21:46 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2u3br3keax-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:21:46 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 31 Jul 2019 15:21:44 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 31 Jul 2019 15:21:37 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6VELZYv35258606
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 14:21:35 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 32CF3A4066;
	Wed, 31 Jul 2019 14:21:34 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 958CCA406D;
	Wed, 31 Jul 2019 14:21:31 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.240])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 31 Jul 2019 14:21:31 +0000 (GMT)
Date: Wed, 31 Jul 2019 17:21:29 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hoan Tran OS <hoan@os.amperecomputing.com>, Will Deacon <will@kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
        Paul Mackerras <paulus@samba.org>, "H . Peter Anvin" <hpa@zytor.com>,
        "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        "x86@kernel.org" <x86@kernel.org>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Open Source Submission <patches@amperecomputing.com>,
        Pavel Tatashin <pavel.tatashin@microsoft.com>,
        Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>,
        Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>,
        "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
        Oscar Salvador <osalvador@suse.de>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "David S . Miller" <davem@davemloft.net>,
        "willy@infradead.org" <willy@infradead.org>
Subject: Re: microblaze HAVE_MEMBLOCK_NODE_MAP dependency (was Re: [PATCH v2
 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA)
References: <20190712143730.au3662g4ua2tjudu@willie-the-truck>
 <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
 <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz>
 <20190731111422.GA14538@rapoport-lnx>
 <20190731114016.GI9330@dhcp22.suse.cz>
 <20190731122631.GB14538@rapoport-lnx>
 <20190731130037.GN9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731130037.GN9330@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19073114-0028-0000-0000-00000389AADE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19073114-0029-0000-0000-00002449FC15
Message-Id: <20190731142129.GA24998@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310144
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 03:00:37PM +0200, Michal Hocko wrote:
> On Wed 31-07-19 15:26:32, Mike Rapoport wrote:
> > On Wed, Jul 31, 2019 at 01:40:16PM +0200, Michal Hocko wrote:
> > > On Wed 31-07-19 14:14:22, Mike Rapoport wrote:
> > > > On Wed, Jul 31, 2019 at 10:03:09AM +0200, Michal Hocko wrote:
> > > > > On Wed 31-07-19 09:24:21, Mike Rapoport wrote:
> > > > > > [ sorry for a late reply too, somehow I missed this thread before ]
> > > > > > 
> > > > > > On Tue, Jul 30, 2019 at 10:14:15AM +0200, Michal Hocko wrote:
> > > > > > > [Sorry for a late reply]
> > > > > > > 
> > > > > > > On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> > > > > > > > Hi,
> > > > > > > > 
> > > > > > > > On 7/12/19 10:00 PM, Michal Hocko wrote:
> > > > > > > [...]
> > > > > > > > > Hmm, I thought this was selectable. But I am obviously wrong here.
> > > > > > > > > Looking more closely, it seems that this is indeed only about
> > > > > > > > > __early_pfn_to_nid and as such not something that should add a config
> > > > > > > > > symbol. This should have been called out in the changelog though.
> > > > > > > > 
> > > > > > > > Yes, do you have any other comments about my patch?
> > > > > > > 
> > > > > > > Not really. Just make sure to explicitly state that
> > > > > > > CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
> > > > > > > doesn't really deserve it's own config and can be pulled under NUMA.
> > > > > > > 
> > > > > > > > > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > > > > > > > > bucket? Do we have any NUMA architecture that doesn't enable it?
> > > > > > > > > 
> > > > > > 
> > > > > > HAVE_MEMBLOCK_NODE_MAP makes huge difference in node/zone initialization
> > > > > > sequence so it's not only about a singe function.
> > > > > 
> > > > > The question is whether we want to have this a config option or enable
> > > > > it unconditionally for each NUMA system.
> > > > 
> > > > We can make it 'default NUMA', but we can't drop it completely because
> > > > microblaze uses sparse_memory_present_with_active_regions() which is
> > > > unavailable when HAVE_MEMBLOCK_NODE_MAP=n.
> > > 
> > > I suppose you mean that microblaze is using
> > > sparse_memory_present_with_active_regions even without CONFIG_NUMA,
> > > right?
> > 
> > Yes.
> > 
> > > I have to confess I do not understand that code. What is the deal
> > > with setting node id there?
> > 
> > The sparse_memory_present_with_active_regions() iterates over
> > memblock.memory regions and uses the node id of each region as the
> > parameter to memory_present(). The assumption here is that sometime before
> > each region was assigned a proper non-negative node id. 
> > 
> > microblaze uses device tree for memory enumeration and the current FDT code
> > does memblock_add() that implicitly sets nid in memblock.memory regions to -1.
> > 
> > So in order to have proper node id passed to memory_present() microblaze
> > has to call memblock_set_node() before it can use
> > sparse_memory_present_with_active_regions().
> 
> I am sorry, but I still do not follow. Who is consuming that node id
> information when NUMA=n. In other words why cannot we simply do
 
We can, I think nobody cared to change it.

> diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> index a015a951c8b7..3a47e8db8d1c 100644
> --- a/arch/microblaze/mm/init.c
> +++ b/arch/microblaze/mm/init.c
> @@ -175,14 +175,9 @@ void __init setup_memory(void)
>  
>  		start_pfn = memblock_region_memory_base_pfn(reg);
>  		end_pfn = memblock_region_memory_end_pfn(reg);
> -		memblock_set_node(start_pfn << PAGE_SHIFT,
> -				  (end_pfn - start_pfn) << PAGE_SHIFT,
> -				  &memblock.memory, 0);
> +		memory_present(0, start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);

memory_present() expects pfns, the shift is not needed.

>  	}
>  
> -	/* XXX need to clip this if using highmem? */
> -	sparse_memory_present_with_active_regions(0);
> -
>  	paging_init();
>  }
>  
> -- 
> Michal Hocko
> SUSE Labs

-- 
Sincerely yours,
Mike.

