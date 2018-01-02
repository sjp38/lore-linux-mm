Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99FFA6B02A2
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 06:26:03 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id g49so38196005qta.8
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 03:26:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j63si1892455qkd.84.2018.01.02.03.26.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 03:26:02 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w02BNtV0101225
	for <linux-mm@kvack.org>; Tue, 2 Jan 2018 06:26:01 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f86s1n3nb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Jan 2018 06:26:01 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 2 Jan 2018 11:25:58 -0000
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 2 Jan 2018 16:55:46 +0530
MIME-Version: 1.0
In-Reply-To: <20171208161559.27313-2-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <2e467ad3-a443-bde4-afa2-664bca57914f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/08/2017 09:45 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> do_pages_move is supposed to move user defined memory (an array of
> addresses) to the user defined numa nodes (an array of nodes one for
> each address). The user provided status array then contains resulting
> numa node for each address or an error. The semantic of this function is
> little bit confusing because only some errors are reported back. Notably
> migrate_pages error is only reported via the return value. This patch

It does report back the migration failures as well. In new_page_node
there is '*result = &pm->status' which going forward in unmap_and_move
will hold migration error or node ID of the new page.

	newpage = get_new_page(page, private, &result);
	............
	if (result) {
		if (rc)
			*result = rc;
		else
			*result = page_to_nid(newpage);
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
