Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 443BA6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 04:33:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a17so9604264wme.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:33:52 -0700 (PDT)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id z5si6136565lbv.49.2016.05.18.01.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 01:33:51 -0700 (PDT)
Received: by mail-lb0-x22d.google.com with SMTP id ww9so14751516lbc.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:33:50 -0700 (PDT)
Date: Wed, 18 May 2016 11:33:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: make faultaround produce old ptes
Message-ID: <20160518083348.GA23276@node.shutemov.name>
References: <1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160518072550.GB21654@dhcp22.suse.cz>
 <20160518080432.GA22982@node.shutemov.name>
 <20160518082228.GD21654@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518082228.GD21654@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, Minchan Kim <minchan@kernel.org>

On Wed, May 18, 2016 at 10:22:28AM +0200, Michal Hocko wrote:
> On Wed 18-05-16 11:04:33, Kirill A. Shutemov wrote:
> > On Wed, May 18, 2016 at 09:25:50AM +0200, Michal Hocko wrote:
> > > On Tue 17-05-16 15:32:46, Kirill A. Shutemov wrote:
> > > > Currently, faultaround code produces young pte. This can screw up vmscan
> > > > behaviour[1], as it makes vmscan think that these pages are hot and not
> > > > push them out on first round.
> > > > 
> > > > Let modify faultaround to produce old pte, so they can easily be
> > > > reclaimed under memory pressure.
> > > 
> > > Could you be more specific about what was the original issue that led to
> > > this patch? I can understand that marking all those pages new might be
> > > too optimistic but when does it matter actually? Sparsely access file
> > > mmap?
> > 
> > Yes, sparse file access. Faultaround gets more pages mapped and all of
> > them are young. Under memory pressure, this makes vmscan to swap out anon
> > pages instead or drop other page cache pages which otherwise stay
> > resident.
> 
> I am wondering whether it would make more sense to do the fault around
> only when chances are that the memory will be used. E.g. ~VM_RAND_READ
> resp VM_SEQ_READ rather than unconditionally.

I'm not sure about this.

The idea of faularound is that we already have almost everything in our
hands to map additional pages for very little cost: all required locks
has been taken and radix-tree look up will be done anyway.

So I don't see a benefit from limiting us here. Do you?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
