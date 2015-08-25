Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 532B46B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 09:41:59 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so15706646wic.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 06:41:58 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id it9si3323606wid.64.2015.08.25.06.41.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 06:41:57 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so15488502wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 06:41:57 -0700 (PDT)
Date: Tue, 25 Aug 2015 15:41:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150825134154.GB6285@dhcp22.suse.cz>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150821183132.GA12835@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Fri 21-08-15 14:31:32, Eric B Munson wrote:
[...]
> I am in the middle of implementing lock on fault this way, but I cannot
> see how we will hanlde mremap of a lock on fault region.  Say we have
> the following:
> 
>     addr = mmap(len, MAP_ANONYMOUS, ...);
>     mlock(addr, len, MLOCK_ONFAULT);
>     ...
>     mremap(addr, len, 2 * len, ...)
> 
> There is no way for mremap to know that the area being remapped was lock
> on fault so it will be locked and prefaulted by remap.  How can we avoid
> this without tracking per vma if it was locked with lock or lock on
> fault?

Yes mremap is a problem and it is very much similar to mmap(MAP_LOCKED).
It doesn't guarantee the full mlock semantic because it leaves partially
populated ranges behind without reporting any error.

Considering the current behavior I do not thing it would be terrible
thing to do what Konstantin was suggesting and populate only the full
ranges in a best effort mode (it is done so anyway) and document the
behavior properly.
"
       If the memory segment specified by old_address and old_size is
       locked (using mlock(2) or similar), then this lock is maintained
       when the segment is resized and/or relocated. As a consequence,
       the amount of memory locked by the process may change.

       If the range is already fully populated and the range is
       enlarged the new range is attempted to be fully populated
       as well to preserve the full mlock semantic but there is no
       guarantee this will succeed. Partially populated (e.g. created by
       mlock(MLOCK_ONFAULT)) ranges do not have the full mlock semantic
       so they are not populated on resize.
"

So what we have as a result is that partially populated ranges are
preserved and fully populated ones work in the best effort mode the same
way as they are now.

Does that sound at least remotely reasonably?


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
