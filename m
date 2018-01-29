Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32AD96B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 18:48:06 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g187so11426403wmg.2
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 15:48:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i194si8998645wme.62.2018.01.29.15.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 15:48:05 -0800 (PST)
Date: Mon, 29 Jan 2018 15:48:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
Message-Id: <20180129154802.594025d081789b6620f001bd@linux-foundation.org>
In-Reply-To: <07425013-A7A9-4BB8-8FAA-9581D966A29B@cs.rutgers.edu>
References: <20180103082555.14592-1-mhocko@kernel.org>
	<20180103082555.14592-2-mhocko@kernel.org>
	<8ECFD324-D8A0-47DC-A6FD-B9F7D29445DC@cs.rutgers.edu>
	<20180129143522.68a5332ae80d28461441a6be@linux-foundation.org>
	<07425013-A7A9-4BB8-8FAA-9581D966A29B@cs.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 29 Jan 2018 18:39:01 -0500 "Zi Yan" <zi.yan@cs.rutgers.edu> wrote:

> On 29 Jan 2018, at 17:35, Andrew Morton wrote:
> 
> > On Mon, 29 Jan 2018 17:06:14 -0500 "Zi Yan" <zi.yan@cs.rutgers.edu> wrote:
> >
> >> I discover that this patch does not hold mmap_sem while migrating pages in
> >> do_move_pages_to_node().
> >>
> >> A simple fix below moves mmap_sem from add_page_for_migration()
> >> to the outmost do_pages_move():
> >
> > I'm not surprised.  Why does do_move_pages_to_node() need mmap_sem
> > and how is a reader to discover that fact???
> 
> do_move_pages_to_node() calls migrate_pages(), which requires down_read(&mmap_sem).
> 
> In the outmost do_pages_move(), both add_page_for_migration() and
> do_move_pages_to_node() inside it need to hold read lock of mmap_sem.
> 
> Do we need to add comments for both functions?

Just for migrate_pages(), I guess.  Let's include a description of
*why* mmap_sem is needed.  What it is protecting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
