Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5CF6B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:10:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o126so116346352pfb.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 20:10:40 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e21si7163637pgi.84.2017.03.16.20.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 20:10:39 -0700 (PDT)
Date: Fri, 17 Mar 2017 11:10:48 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170317031048.GC18964@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <c2e172b1-fb2a-57a0-0074-a07a61693e6c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2e172b1-fb2a-57a0-0074-a07a61693e6c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed, Mar 15, 2017 at 03:56:02PM +0100, Vlastimil Babka wrote:
> I wonder if the difference would be larger if the parallelism was done
> on a higher level, something around unmap_page_range(). IIUC the current

I guess I misunderstand you in my last email - doing it at
unmap_page_range() level is essentially doing it at a per-VMA level
since it is the main function used in unmap_single_vma(). We have tried
that and felt that it's not flexible as the proposed approach since
it wouldn't parallize well for:
1 work load that uses only 1 or very few huge VMA;
2 work load that has a lot of small VMAs.

The code is nice and easy though(developed at v4.9 time frame):
