Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0456B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:58:34 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so23786971wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:58:33 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id p11si296608wjw.192.2015.08.25.11.58.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 11:58:32 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so23535393wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:58:32 -0700 (PDT)
Date: Tue, 25 Aug 2015 20:58:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150825185829.GA10222@dhcp22.suse.cz>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
 <20150825134154.GB6285@dhcp22.suse.cz>
 <20150825142902.GF17005@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150825142902.GF17005@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue 25-08-15 10:29:02, Eric B Munson wrote:
> On Tue, 25 Aug 2015, Michal Hocko wrote:
[...]
> > Considering the current behavior I do not thing it would be terrible
> > thing to do what Konstantin was suggesting and populate only the full
> > ranges in a best effort mode (it is done so anyway) and document the
> > behavior properly.
> > "
> >        If the memory segment specified by old_address and old_size is
> >        locked (using mlock(2) or similar), then this lock is maintained
> >        when the segment is resized and/or relocated. As a consequence,
> >        the amount of memory locked by the process may change.
> > 
> >        If the range is already fully populated and the range is
> >        enlarged the new range is attempted to be fully populated
> >        as well to preserve the full mlock semantic but there is no
> >        guarantee this will succeed. Partially populated (e.g. created by
> >        mlock(MLOCK_ONFAULT)) ranges do not have the full mlock semantic
> >        so they are not populated on resize.
> > "
> 
> You are proposing that mremap would scan the PTEs as Vlastimil has
> suggested?

As Vlastimil pointed out this would be unnecessarily too costly. But I
am wondering whether we should populate at all during mremap considering
the full mlock semantic is not guaranteed anyway. Man page mentions only
that the lock is maintained which will be true without population as
well.

If somebody really depends on the current (and broken) implementation we
can offer MREMAP_POPULATE which would do a best effort population. This
would be independent on the locked state and would be usable for other
mappings as well (the usecase would be to save page fault overhead by
batching them).

If this would be seen as an unacceptable user visible change of behavior
then we can go with the VMA flag but I would still prefer to not export
it to the userspace so that we have a way to change this in future.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
