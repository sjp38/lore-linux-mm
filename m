Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5816B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 12:35:45 -0500 (EST)
Received: by wmvv187 with SMTP id v187so224230826wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 09:35:44 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m186si6252820wmb.108.2015.12.08.09.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 09:35:44 -0800 (PST)
Date: Tue, 8 Dec 2015 12:35:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH mmotm] memcg: Ignore partial THP when moving task
Message-ID: <20151208173528.GA32265@cmpxchg.org>
References: <1449594789-15866-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449594789-15866-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 08, 2015 at 06:13:09PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> After "mm: rework mapcount accounting to enable 4k mapping of THPs"
> it is possible to have a partial THP accessible via ptes. Memcg task
> migration code is not prepared for this situation and uncharges the tail
> page from the original memcg while the original THP is still charged via
> the head page which is not mapped to the moved task. The page counter
> of the origin memcg will underflow when the whole THP is uncharged later
> on and lead to:
> WARNING: CPU: 0 PID: 1340 at mm/page_counter.c:26 page_counter_cancel+0x34/0x40()
> reported by Minchan Kim.
> 
> This patch prevents from the underflow by skipping any partial THP pages
> in mem_cgroup_move_charge_pte_range. PageTransCompound is checked when
> we do pte walk. This means that a process might leave a partial THP
> behind in the original memcg if there is no other process mapping it via
> pmd but this is considered acceptable because it shouldn't happen often
> and this is not considered a memory leak because the original THP is
> still accessible and reclaimable. Moreover the task migration has always
> been racy and never guaranteed to move all pages.
> 
> Reported-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> this is a patch tested by Minchan in the original thread [1]. I have
> only replaced PageCompound with PageTransCompound because other similar
> fixes in mmotm used this one. The underlying implementation is the same.
> Johannes, I have kept your a-b but let me know if you are not OK with the
> changelog.

Looks good to me, thanks Michal. Please keep my Acked-by.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
