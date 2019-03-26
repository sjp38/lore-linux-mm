Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B7B3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:23:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 333262084B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:23:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 333262084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4E866B0005; Tue, 26 Mar 2019 05:23:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFC7C6B0006; Tue, 26 Mar 2019 05:23:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B13E06B0007; Tue, 26 Mar 2019 05:23:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72DFF6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:23:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u8so11598316pfm.6
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:23:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=7iatnQ4pXQL8fUPFqfEmYY/L2q1VzCaJmyKTtbeGFWM=;
        b=rTR7MDiqgxr881rf+YAiy+EwGHy6wtw08nlikXvxG7xSJqV+F+/2mRWuqLXL3xZeOj
         3ubsFGcPwqwpLDvGsFL5FCajgUsAH0Wg+R43X2ykRMiIe+A4NgoOdrAZ6pwjxIpLK94I
         a9q/3RDWi10iBZ6L4RUTUcTVIJbNGYHdtFAKeS2LUZSdheNVkDBtbl1S/ZaV4rSE4rhw
         TqhjOarUGKzpCK+DPCyPfIPAxlww4+xozNusgPhBK7WKvgVT78KILg4U+mK69nRfCY06
         NMFfiIROrtxBOVOHdJnvTcgbcOE+PjQrUJRy/KOpF6KzW6RwIO4sflSpmfpYybkgKWUL
         mOfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVioO6838gVYZc7EJodx6oCqcMfpcOjwOMt0J8ipGK9NH+wgtbK
	8fw/FPVyefDyziNgPrr/k/fliyNlMbNDm2ks/pn4kzqpHJHHAu+2u6ghJc1FrvifDwUZFpo1mW9
	yFl4gZRstDNoYAb0LqIVKVypxSZZ/muRO4MyUxemnUhcdVhxhae2eIt2Rm7NB6fsR6w==
X-Received: by 2002:a65:538e:: with SMTP id x14mr27232279pgq.79.1553592195075;
        Tue, 26 Mar 2019 02:23:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWaCYFO9fdbhxCLdNw3SAzuC7YYRNq4/kyh8pXJMmwgU/7WpCpGpgrB/2LLdLM258p6Gw0
X-Received: by 2002:a65:538e:: with SMTP id x14mr27232240pgq.79.1553592194401;
        Tue, 26 Mar 2019 02:23:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553592194; cv=none;
        d=google.com; s=arc-20160816;
        b=CTsxe84Hl1vpo/zHUz+yb884tVE2B6hSK9r6FGBa5l5qnjLnxKNJ0svn1y5IX6kgkb
         G5+7QSQbdZ04PazcKdEblPWa4VMaAzWkdN2hCR3Wy4E5N+z4JfDbLgq/Gr3/1w8gw659
         8zGphWLuWGPsl2LAMxxjkuCSY5WeE4tkUkoFa+WiI4OxfO9Hr5oeggJcOLdZZ/eziJEp
         hjB1BfN+vO0H4GEi51ZdlGpIrg3MKu6PK0K5V42VIsRojck5fXQs9Nh/2GxvSmxAr7e4
         TMqhE2kTPuYplJMNoSKI3FncvD8nVMTGX/mW7HLK8HlSLwcDHTnJMobEGKH6MOdf+63M
         /Hqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=7iatnQ4pXQL8fUPFqfEmYY/L2q1VzCaJmyKTtbeGFWM=;
        b=R77nKW0deMRNkf1q/NOBpY/KCzKrukhCH2jSrb8bPk9U2uw+Z3xmnPmQ0zQtPxhRi7
         +0/8zqk9PBZh653cZlA7OqOsVp8xu9U4HiktAJvtPVrGbjKM8J1moAFpDjI9OVn9lsI2
         Yv/ksnLvsxyQotasQQxkDkdR78pCfxWr9g3BT5+HBbuUZB2PJdrr3uiAzgdCZUlA79V5
         n68oQaV0O3H1XqBL2NHxbduPFbPMvs2Gyd6oCRZDxPUdb85IubYhAXe12D0gR/FZyRN4
         2ucHRjeqaiVMjOGiRwQPQYsAoAyJ6ryFCRS12tEMS7y5IM1SNFVrwkLb6Ejin87ugYzH
         YuSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c3si15832795pfa.8.2019.03.26.02.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:23:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2Q99Lre026224
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:23:13 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rffue40y7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:23:13 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Mar 2019 09:23:11 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Mar 2019 09:23:07 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2Q9N6ko44826790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Mar 2019 09:23:06 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 25906AE059;
	Tue, 26 Mar 2019 09:23:06 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 73B62AE055;
	Tue, 26 Mar 2019 09:23:05 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Mar 2019 09:23:05 +0000 (GMT)
Date: Tue, 26 Mar 2019 11:23:03 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de,
        willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 1/4] mm/sparse: Clean up the obsolete code comment
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-2-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326090227.3059-2-bhe@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032609-0008-0000-0000-000002D19F20
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032609-0009-0000-0000-0000223DCAB2
Message-Id: <20190326092303.GB6297@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-26_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903260069
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 05:02:24PM +0800, Baoquan He wrote:
> The code comment above sparse_add_one_section() is obsolete and
> incorrect, clean it up and write new one.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
> v1-v2:
>   Add comments to explain what the returned value means for
>   each error code.
> 
>  mm/sparse.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 69904aa6165b..b2111f996aa6 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -685,9 +685,18 @@ static void free_map_bootmem(struct page *memmap)
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>  
>  /*
> - * returns the number of sections whose mem_maps were properly
> - * set.  If this is <=0, then that means that the passed-in
> - * map was not consumed and must be freed.
> + * sparse_add_one_section - add a memory section
> + * @nid: The node to add section on
> + * @start_pfn: start pfn of the memory range
> + * @altmap: device page map
> + *
> + * This is only intended for hotplug.
> + *
> + * Returns:
> + *   0 on success.
> + *   Other error code on failure:
> + *     - -EEXIST - section has been present.
> + *     - -ENOMEM - out of memory.
>   */
>  int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  				     struct vmem_altmap *altmap)
> -- 
> 2.17.2
> 

-- 
Sincerely yours,
Mike.

