Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03315C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 12:30:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B822F206E0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 12:30:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B822F206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55E7A6B0003; Thu, 20 Jun 2019 08:30:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50EB68E0002; Thu, 20 Jun 2019 08:30:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FD9C8E0001; Thu, 20 Jun 2019 08:30:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03B7A6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:30:29 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o6so1489393plk.23
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=XebB9AqXXzeQ/tJY7IKg/TwQTDmglDy9a1QL8HP0VN8=;
        b=kRGCAbJUK3USWavKs4CGtqMFuGsqVIMP5P6ffGsCC+Y8tJrM3WRyxp1vyAmdHyaSXq
         2rznhFCsMY3+71hGlju561OYJeePQKPIBIpTiNDfDOnr5kAykPVkgyqsj4LAKpeH4BHt
         IsAZOxhDz7ilqElb5vUC5iVrHYlmsvQh5biudmFj88WagAOyP5OpHrN7hGr+isRqqgw9
         hB2I1DPDJe9vmO3pirJThjTILB7PLKIPln/gBW1usEfPlxa9AFR8DQVKPE+6nUcgVPDc
         uqaM828wBgev6/87sxXTctzRapeiBYg1c0Yaj1MqfH0Kazp+LyO1vbxCfVcha97dtWap
         HnaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWegok31Ra9GwKo9q1aHiD2yetflaxdsIq5luLLNGC5zJgL25/x
	/GEqKase7ZwOttMxcWuQ3YuGHUsoo+J4OdwoNfUORxOtkkqyGVEKLY41OHwYnKjlCcckVjrsBjM
	LsTMhoF1qloahquaBeN+Zi6uFykZNRLEhI+Rlit89lJXrXS24M/y2ZbBpBpIzR7Y4fA==
X-Received: by 2002:a63:3d8d:: with SMTP id k135mr5047133pga.23.1561033828535;
        Thu, 20 Jun 2019 05:30:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlqa/9Xzb22Nzg4LeSi5j4Iu/1hq8MW93qi7PiTFLgxg50Yu9Pz/1mESyCrj9xG651m9Lx
X-Received: by 2002:a63:3d8d:: with SMTP id k135mr5047072pga.23.1561033827529;
        Thu, 20 Jun 2019 05:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561033827; cv=none;
        d=google.com; s=arc-20160816;
        b=qBjHA2NulvxyFeg3FSHHG4yKmlthM3F1h9qs6X1F9LXlXvOCx0VjhKvEN+EU2wcevr
         e6l/feMgCf9uxwB+y9zbVC0RMT0/pColGuIE4baLL3dBRwH8xtQsXCnzghNS2KsSjh1C
         FReZDivH2v0oDW8T68Jk9AWgN7TAHVhg9dqdFbHjWXC2h8E4ZVc+DqcrUcHn8kB/30gv
         HdQcXu8knuWspykd40PeWtNtR/Lf590PYKsLyOeBpcPdNd4hAFPzEWuGur4p6GL/A5Ur
         cFzaatJiy14qucFjMf9IZ9luBoxaySlnh0jN3M5OjgeHqo4i6yureYcHB9Gcy+m/mMyd
         d2+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=XebB9AqXXzeQ/tJY7IKg/TwQTDmglDy9a1QL8HP0VN8=;
        b=QNljS+cy13nEyxqU+x2WemSVGAkvGPPB6p6qSDq1hUj3bLY9nDhCR8fSsvvJ8EGfop
         QMD0p/8vwbcyASY1UrQ6JnXvxYf1JUzctkfiYnumU4+1/pgFlzMrUjGyYBLCbROfYxLG
         inNRckoV/S5qp7rTdA4DtZhhzbF3Y1oD4MP0npQ2aSjI0ZnUHGbcEN+5U3QsL+KvVd1d
         6AEHGFz30ZRDFFMnG/809NXE0ioi4spchrX6CjuADAMFnQp6RaTB7kOBB2yvsc0JZOz1
         TIRZwHHtNZ5daT2jULnPv7DBIdWi6KFhXITDXoduzvez7jrQ4qb3mq05g0SVS4mjWL+e
         9viQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q7si6037463pgc.374.2019.06.20.05.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 05:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KCJMxU036516
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:30:26 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t8a1grgnq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:30:26 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 20 Jun 2019 13:30:24 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 20 Jun 2019 13:30:21 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5KCUBdr37552596
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Jun 2019 12:30:11 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 57D6DAE04D;
	Thu, 20 Jun 2019 12:30:20 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C5D45AE055;
	Thu, 20 Jun 2019 12:30:19 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 20 Jun 2019 12:30:19 +0000 (GMT)
Date: Thu, 20 Jun 2019 15:30:18 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jonathan Corbet <corbet@lwn.net>,
        linux-mm@kvack.org, linux-nvdimm@lists.01.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v10 10/13] mm: Document ZONE_DEVICE memory-model
 implications
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
 <156092354985.979959.15763234410543451710.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156092354985.979959.15763234410543451710.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19062012-4275-0000-0000-0000034413CD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19062012-4276-0000-0000-000038544349
Message-Id: <20190620123017.GB18387@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200091
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 10:52:29PM -0700, Dan Williams wrote:
> Explain the general mechanisms of 'ZONE_DEVICE' pages and list the users
> of 'devm_memremap_pages()'.
> 
> Cc: Jonathan Corbet <corbet@lwn.net>
> Reported-by: Mike Rapoport <rppt@linux.ibm.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

With one nit below

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  Documentation/vm/memory-model.rst |   39 +++++++++++++++++++++++++++++++++++++
>  1 file changed, 39 insertions(+)
> 
> diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
> index 382f72ace1fc..e0af47e02e78 100644
> --- a/Documentation/vm/memory-model.rst
> +++ b/Documentation/vm/memory-model.rst
> @@ -181,3 +181,42 @@ that is eventually passed to vmemmap_populate() through a long chain
>  of function calls. The vmemmap_populate() implementation may use the
>  `vmem_altmap` along with :c:func:`altmap_alloc_block_buf` helper to
>  allocate memory map on the persistent memory device.
> +
> +ZONE_DEVICE
> +===========
> +The `ZONE_DEVICE` facility builds upon `SPARSEMEM_VMEMMAP` to offer
> +`struct page` `mem_map` services for device driver identified physical
> +address ranges. The "device" aspect of `ZONE_DEVICE` relates to the fact
> +that the page objects for these address ranges are never marked online,
> +and that a reference must be taken against the device, not just the page
> +to keep the memory pinned for active use. `ZONE_DEVICE`, via
> +:c:func:`devm_memremap_pages`, performs just enough memory hotplug to
> +turn on :c:func:`pfn_to_page`, :c:func:`page_to_pfn`, and
> +:c:func:`get_user_pages` service for the given range of pfns. Since the
> +page reference count never drops below 1 the page is never tracked as
> +free memory and the page's `struct list_head lru` space is repurposed
> +for back referencing to the host device / driver that mapped the memory.
> +
> +While `SPARSEMEM` presents memory as a collection of sections,
> +optionally collected into memory blocks, `ZONE_DEVICE` users have a need
> +for smaller granularity of populating the `mem_map`. Given that
> +`ZONE_DEVICE` memory is never marked online it is subsequently never
> +subject to its memory ranges being exposed through the sysfs memory
> +hotplug api on memory block boundaries. The implementation relies on
> +this lack of user-api constraint to allow sub-section sized memory
> +ranges to be specified to :c:func:`arch_add_memory`, the top-half of
> +memory hotplug. Sub-section support allows for `PMD_SIZE` as the minimum
> +alignment granularity for :c:func:`devm_memremap_pages`.
> +
> +The users of `ZONE_DEVICE` are:

Sphinx wants an empty line here:
/home/rapoport/git/linux-docs/Documentation/vm/memory-model.rst:213: ERROR:
Unexpected indentation.

> +* pmem: Map platform persistent memory to be used as a direct-I/O target
> +  via DAX mappings.
> +
> +* hmm: Extend `ZONE_DEVICE` with `->page_fault()` and `->page_free()`
> +  event callbacks to allow a device-driver to coordinate memory management
> +  events related to device-memory, typically GPU memory. See
> +  Documentation/vm/hmm.rst.
> +
> +* p2pdma: Create `struct page` objects to allow peer devices in a
> +  PCI/-E topology to coordinate direct-DMA operations between themselves,
> +  i.e. bypass host memory.
> 

-- 
Sincerely yours,
Mike.

