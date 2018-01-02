Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF2016B02A8
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 07:12:42 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v25so34863306pfg.14
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 04:12:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si33452215pll.585.2018.01.02.04.12.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Jan 2018 04:12:41 -0800 (PST)
Date: Tue, 2 Jan 2018 13:12:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20180102121237.GC25397@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <2e467ad3-a443-bde4-afa2-664bca57914f@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2e467ad3-a443-bde4-afa2-664bca57914f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 02-01-18 16:55:46, Anshuman Khandual wrote:
> On 12/08/2017 09:45 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > do_pages_move is supposed to move user defined memory (an array of
> > addresses) to the user defined numa nodes (an array of nodes one for
> > each address). The user provided status array then contains resulting
> > numa node for each address or an error. The semantic of this function is
> > little bit confusing because only some errors are reported back. Notably
> > migrate_pages error is only reported via the return value. This patch
> 
> It does report back the migration failures as well. In new_page_node
> there is '*result = &pm->status' which going forward in unmap_and_move
> will hold migration error or node ID of the new page.
> 
> 	newpage = get_new_page(page, private, &result);
> 	............
> 	if (result) {
> 		if (rc)
> 			*result = rc;
> 		else
> 			*result = page_to_nid(newpage);
> 	}
> 

This is true, except the user will not get this information. Have a look
how we do not copy status on error up in the do_pages_move layer.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
