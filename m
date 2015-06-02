Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 27426900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 16:22:44 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so140300370pdb.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 13:22:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qo2si27635547pbc.38.2015.06.02.13.22.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 13:22:43 -0700 (PDT)
Date: Tue, 2 Jun 2015 13:22:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/2] mapping_gfp_mask from the page fault path
Message-Id: <20150602132241.26fbbc98be71920da8485b73@linux-foundation.org>
In-Reply-To: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
References: <1433163603-13229-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Mon,  1 Jun 2015 15:00:01 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> I somehow forgot about these patches. The previous version was
> posted here: http://marc.info/?l=linux-mm&m=142668784122763&w=2. The
> first attempt was broken but even when fixed it seems like ignoring
> mapping_gfp_mask in page_cache_read is too fragile because
> filesystems might use locks in their filemap_fault handlers
> which could trigger recursion problems as pointed out by Dave
> http://marc.info/?l=linux-mm&m=142682332032293&w=2.
> 
> The first patch should be straightforward fix to obey mapping_gfp_mask
> when allocating for mapping. It can be applied even without the second
> one.

I'm not so sure about that.  If only [1/2] is applied then those
filesystems which are setting mapping_gfp_mask to GFP_NOFS will now
actually start using GFP_NOFS from within page_cache_read() etc.  The
weaker allocation mode might cause problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
