Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9AE7C10F0C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:04:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 961B12075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:04:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 961B12075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1007C8E000C; Mon, 11 Mar 2019 05:04:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 087888E0002; Mon, 11 Mar 2019 05:04:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB6E08E000C; Mon, 11 Mar 2019 05:04:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C82888E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:04:21 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id e25so1353372qkj.12
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 02:04:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EZGrVHTNl3bipmE1CeosgRQxxqQbbdPXAWWbkLc656k=;
        b=c43nnLVbLlNmEfivyn0wx2tFlxdLHBuhQRDOfLfo9PDqZHSu8MAYkfMcpsZkFgq2nc
         9z+YGYH5/gFaq463T2GQLgPMR8C2YYctPvNPl70At+NZnxOE7/faTmUwCXIw7NcNBy92
         RKfmH2gNK9OSuPpMwDcrRVv88OHq/CnJzqPY9ClhHBwXYyxQ8mgKjvlqdubOSB1Ro4U4
         7IkbJEa3cPFHbn+YO2T9U14dzttL3Zu8UHNJ2t4uxcl20SqGUYSXpwHpbYj/c6KiqjNw
         H1NSIZYfL3e18jabj7RXAUYmuykuYjDNv/U1p39hULASKYHkhcIjjqV6zu3BHClvJU64
         3T4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUGLHR8kxrZat9x2Conavef0rRQW8jca3dlJANF5DZCGjH+LSNX
	MZjkuecqqD993c+ph7ENYoTu1WBV3h7sbAwUUQU0ifIB8PmFjZavw9qDhFCD04Mjv2m+Ns2MWcu
	4GlXGlDgH4lRcA0pxSj5ZeKUTLR6gGKDnjgEHirbOEHTDO/1Hbk7VfdLo11czYAG79Q==
X-Received: by 2002:a0c:9609:: with SMTP id 9mr9160910qvx.195.1552295061543;
        Mon, 11 Mar 2019 02:04:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuJ7cLQlpG6CqubRs+4KCLbXd8+LIple4xxKIzi3Pv6eeiRyH1HEnhu2byxyM6CKD5XZT1
X-Received: by 2002:a0c:9609:: with SMTP id 9mr9160868qvx.195.1552295060784;
        Mon, 11 Mar 2019 02:04:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552295060; cv=none;
        d=google.com; s=arc-20160816;
        b=jl1f9p/YwQnCdY1rLF8K6NUxA2ofzIPe4UNg3VNxwjdPFLaES3fhtGkfxj/TdiI93K
         QQNcdjSKKm2e5GoSfmOyd2wGw87M2D9prl+Wj1VYDWhOg/k60b+1nY4C141Su/qtHHY7
         blvtpM0AIYyfosAJQbD7nePwDtk0i7v+3VQLeRxoccO2k5oj/o9khgIpxshS4ZMcUtAE
         3wt68NLKjYCQYJ92cnXtYKsywL4dQmbu5D4PE2J9nN4p9Bi46FYJRqFMdXwPC2q/qrG8
         om+mdRb/5HYOih9Odca2GFHuN1qIQe83+eZlNT/Uw2fstK+cltirXQOv0oldveEbTG6Q
         T/ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EZGrVHTNl3bipmE1CeosgRQxxqQbbdPXAWWbkLc656k=;
        b=ZVyEG7gyAoZ/vVuufk8GKrAHYPKiulwKu0ZD5KbseRAqCBuN6yros9sOEbNzRyPuI6
         2gvchL7dXh0lychPLm2XJdnAjCX3F7pPqfQZ1YPA6leZFN9theRCLpv5/PmkPHE6FUw1
         8YI8vqcfTCWeSTRMBDolKbWODv/+yHT87uQc45dpU1qiE1qJipBFJ6OGNKv5UA3MdwxY
         amrTUjyTj2gZ0YVWZ3yPCGL7846emIT/4Dhp+RRB+8GrGox6k/tGskzBfwPIvSq0KnwK
         u2UIeYmk5VlSjQ0gkvbhK6i3cHtDMieyxUm3CcANLfj4BEs+3Ddozc1FVXBbRK4j1C+1
         djsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a9si733667qtg.234.2019.03.11.02.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 02:04:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C5602E6A81;
	Mon, 11 Mar 2019 09:04:19 +0000 (UTC)
Received: from dhcp-128-65.nay.redhat.com (ovpn-12-113.pek2.redhat.com [10.72.12.113])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0E5845DA62;
	Mon, 11 Mar 2019 09:04:06 +0000 (UTC)
Date: Mon, 11 Mar 2019 17:04:02 +0800
From: Dave Young <dyoung@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, devel@linuxdriverproject.org,
	linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>,
	Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Lianbo Jiang <lijiang@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Kazuhito Hagio <k-hagio@ab.jp.nec.com>
Subject: Re: [PATCH v2 3/8] kexec: export PG_offline to VMCOREINFO
Message-ID: <20190311090402.GA12071@dhcp-128-65.nay.redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
 <20181122100627.5189-4-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122100627.5189-4-david@redhat.com>
User-Agent: Mutt/1.9.5 (2018-04-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 11 Mar 2019 09:04:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,
On 11/22/18 at 11:06am, David Hildenbrand wrote:
> Right now, pages inflated as part of a balloon driver will be dumped
> by dump tools like makedumpfile. While XEN is able to check in the
> crash kernel whether a certain pfn is actuall backed by memory in the
> hypervisor (see xen_oldmem_pfn_is_ram) and optimize this case, dumps of
> other balloon inflated memory will essentially result in zero pages getting
> allocated by the hypervisor and the dump getting filled with this data.
> 
> The allocation and reading of zero pages can directly be avoided if a
> dumping tool could know which pages only contain stale information not to
> be dumped.
> 
> We now have PG_offline which can be (and already is by virtio-balloon)
> used for marking pages as logically offline. Follow up patches will
> make use of this flag also in other balloon implementations.
> 
> Let's export PG_offline via PAGE_OFFLINE_MAPCOUNT_VALUE, so
> makedumpfile can directly skip pages that are logically offline and the
> content therefore stale. (we export is as a macro to match how it is
> done for PG_buddy. This way it is clearer that this is not actually a flag
> but only a very specific mapcount value to represent page types).
> 
> Please note that this is also helpful for a problem we were seeing under
> Hyper-V: Dumping logically offline memory (pages kept fake offline while
> onlining a section via online_page_callback) would under some condicions
> result in a kernel panic when dumping them.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Young <dyoung@redhat.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Baoquan He <bhe@redhat.com>
> Cc: Omar Sandoval <osandov@fb.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Lianbo Jiang <lijiang@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Kazuhito Hagio <k-hagio@ab.jp.nec.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Dave Young <dyoung@redhat.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  kernel/crash_core.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/kernel/crash_core.c b/kernel/crash_core.c
> index 933cb3e45b98..093c9f917ed0 100644
> --- a/kernel/crash_core.c
> +++ b/kernel/crash_core.c
> @@ -464,6 +464,8 @@ static int __init crash_save_vmcoreinfo_init(void)
>  	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
>  #ifdef CONFIG_HUGETLB_PAGE
>  	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
> +#define PAGE_OFFLINE_MAPCOUNT_VALUE	(~PG_offline)
> +	VMCOREINFO_NUMBER(PAGE_OFFLINE_MAPCOUNT_VALUE);
>  #endif
>  
>  	arch_crash_save_vmcoreinfo();

The patch has been merged, would you mind to send a documentation patch
for the vmcoreinfo, which is added recently in Documentation/kdump/vmcoreinfo.txt

A brief description about how this vmcoreinfo field is used is good to
have.

Thanks
Dave

