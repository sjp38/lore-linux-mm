Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id C9E496B0106
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 11:14:53 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hn9so3829581wib.4
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 08:14:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wu7si12427434wjb.140.2014.03.18.08.14.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 08:14:52 -0700 (PDT)
Date: Tue, 18 Mar 2014 16:14:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHv3] mm: implement POSIX_FADV_NOREUSE
Message-ID: <20140318151448.GB8051@dhcp22.suse.cz>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
 <1394812370-13454-1-git-send-email-matthias.wirth@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394812370-13454-1-git-send-email-matthias.wirth@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Wirth <matthias.wirth@gmail.com>
Cc: Lukas Senger <lukas@fridolin.com>, i4passt@lists.cs.fau.de, Dave Hansen <dave.hansen@linux.intel.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rafael Aquini <aquini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 14-03-14 16:52:38, Matthias Wirth wrote:
[...]
> The idea of the patch is to add pages from files with FMODE_NOREUSE at
> the tail of the lru list. Therefore these pages are the first to be
> reclaimed. We added add_to_page_cache_lru_tail and corresponding
> functions, complementing add_to_page_cache_lru.

If this is set before the read then you can end up trashing on those
pages during heavy memory pressure I am afraid. Page would get reclaimed
before the read gets to it.

What you could do instead, I think, is to reclaim pages belonging to
a FMODE_NOREUSE file away when they would be activated normally during
reclaim. That would require tweaking page_check_references which
implements used-once logic currently.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
