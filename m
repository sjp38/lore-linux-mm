Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 936286B0254
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:29:18 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so16841615wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:29:18 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id gf7si39147151wjd.98.2015.08.25.07.29.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 07:29:17 -0700 (PDT)
Received: by wijp15 with SMTP id p15so17848285wij.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:29:16 -0700 (PDT)
Date: Tue, 25 Aug 2015 16:29:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150825142914.GF6285@dhcp22.suse.cz>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
 <20150825134154.GB6285@dhcp22.suse.cz>
 <55DC73E2.6050509@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55DC73E2.6050509@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue 25-08-15 15:55:46, Vlastimil Babka wrote:
> On 08/25/2015 03:41 PM, Michal Hocko wrote:
[...]
> >So what we have as a result is that partially populated ranges are
> >preserved and fully populated ones work in the best effort mode the same
> >way as they are now.
> >
> >Does that sound at least remotely reasonably?
> 
> I'll basically repeat what I said earlier:
> 
> - mremap scanning existing pte's to figure out the population would slow it
> down for no good reason

So do we really need to populate the enlarged range? All the man page is
saying is that the lock is maintained. Which will be still the case. It
is true that the failure is unlikely (unless you are running in the
memcg) but you cannot rely on the full mlock semantic so what would be a
problem?

> - it would be unreliable anyway:
>   - example: was the area completely populated because MLOCK_ONFAULT was not
> used or because the  process faulted it already

OK, I see this as being a problem. Especially if the buffer is increase
2*original_len

>   - example: was the area not completely populated because MLOCK_ONFAULT was
> used, or because mmap(MAP_LOCKED) failed to populate it fully?

What would be the difference? Both are ONFAULT now.

> I think the first point is a pointless regression for workloads that use
> just plain mlock() and don't want the onfault semantics. Unless there's some
> shortcut? Does vma have a counter of how much is populated? (I don't think
> so?)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
