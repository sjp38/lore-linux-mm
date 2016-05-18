Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id D18126B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 04:04:37 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ga2so19822095lbc.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:04:37 -0700 (PDT)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id i4si6001093lbj.211.2016.05.18.01.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 01:04:36 -0700 (PDT)
Received: by mail-lb0-x22d.google.com with SMTP id h1so14457209lbj.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:04:36 -0700 (PDT)
Date: Wed, 18 May 2016 11:04:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: make faultaround produce old ptes
Message-ID: <20160518080432.GA22982@node.shutemov.name>
References: <1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160518072550.GB21654@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518072550.GB21654@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, Minchan Kim <minchan@kernel.org>

On Wed, May 18, 2016 at 09:25:50AM +0200, Michal Hocko wrote:
> On Tue 17-05-16 15:32:46, Kirill A. Shutemov wrote:
> > Currently, faultaround code produces young pte. This can screw up vmscan
> > behaviour[1], as it makes vmscan think that these pages are hot and not
> > push them out on first round.
> > 
> > Let modify faultaround to produce old pte, so they can easily be
> > reclaimed under memory pressure.
> 
> Could you be more specific about what was the original issue that led to
> this patch? I can understand that marking all those pages new might be
> too optimistic but when does it matter actually? Sparsely access file
> mmap?

Yes, sparse file access. Faultaround gets more pages mapped and all of
them are young. Under memory pressure, this makes vmscan to swap out anon
pages instead or drop other page cache pages which otherwise stay
resident.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
