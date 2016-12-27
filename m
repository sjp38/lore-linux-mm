Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 53AA36B0289
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 21:32:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so52467415wmw.0
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 18:32:12 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id kn2si48132190wjc.158.2016.12.26.18.32.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 18:32:11 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u144so55249235wmu.0
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 18:32:11 -0800 (PST)
Date: Tue, 27 Dec 2016 05:32:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161227023208.GB8780@node.shutemov.name>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161223085150.GA23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com>
 <20161223111817.GC23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com>
 <20161226090211.GA11455@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612261639550.99744@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1612261639550.99744@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 26, 2016 at 04:53:39PM -0800, David Rientjes wrote:
> > If there is really a need for an immediate solution^Wworkaround then I
> > think that tweaking the madvise option should be reasonably safe. Admins
> > are really prepared for stalls because they are explicitly opting in for
> > madvise behavior and they will get a background compaction on top. This
> > is a new behavior but I do not see how it would be harmful. If an
> > excessive compaction is a problem then THP can be reduced to madvise
> > only vmas.
> > 
> > But, I really _do_ care about having a stall free option which is not a
> > complete disable of the background compaction for THP.
> > 
> 
> This is completely wrong.  Before the "defer" option has been introduced, 
> we had "madvise" and should maintain its behavior as much as possible so 
> there are no surprises.  We don't change behavior for a tunable out from 
> under existing users because you think you know better.  With the new 
> "defer" option, we can make this a stronger variant of "madvise", which 
> Kirill acked, so that existing users of MADV_HUGEPAGE have no change in 
> behavior and we can configure whether we do direct or background 
> compaction for everybody else.  If people don't want background 
> compaction, they can set defrag to "madvise".  If they want it, they can 
> set it to "defer".  It's very simple.
> 
> That said, I simply don't have the time to continue in circular arguments 
> and would respectfully ask Andrew to apply this acked patch.

+1.

I don't see a point to make "defer" weaker than "madvise". MADV_HUGEPAGE
is a way for an application to say that it's okay with paying price for
huge page allocation.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
