Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 207906B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 04:22:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so24398623wme.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:22:31 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ck5si8911391wjb.78.2016.05.18.01.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 01:22:29 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w143so10705301wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:22:29 -0700 (PDT)
Date: Wed, 18 May 2016 10:22:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: make faultaround produce old ptes
Message-ID: <20160518082228.GD21654@dhcp22.suse.cz>
References: <1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160518072550.GB21654@dhcp22.suse.cz>
 <20160518080432.GA22982@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518080432.GA22982@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, Minchan Kim <minchan@kernel.org>

On Wed 18-05-16 11:04:33, Kirill A. Shutemov wrote:
> On Wed, May 18, 2016 at 09:25:50AM +0200, Michal Hocko wrote:
> > On Tue 17-05-16 15:32:46, Kirill A. Shutemov wrote:
> > > Currently, faultaround code produces young pte. This can screw up vmscan
> > > behaviour[1], as it makes vmscan think that these pages are hot and not
> > > push them out on first round.
> > > 
> > > Let modify faultaround to produce old pte, so they can easily be
> > > reclaimed under memory pressure.
> > 
> > Could you be more specific about what was the original issue that led to
> > this patch? I can understand that marking all those pages new might be
> > too optimistic but when does it matter actually? Sparsely access file
> > mmap?
> 
> Yes, sparse file access. Faultaround gets more pages mapped and all of
> them are young. Under memory pressure, this makes vmscan to swap out anon
> pages instead or drop other page cache pages which otherwise stay
> resident.

I am wondering whether it would make more sense to do the fault around
only when chances are that the memory will be used. E.g. ~VM_RAND_READ
resp VM_SEQ_READ rather than unconditionally.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
