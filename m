Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7AA56B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:10:30 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a9so11236318pff.0
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 08:10:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10-v6si4663018plz.169.2018.01.30.08.10.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 08:10:29 -0800 (PST)
Date: Tue, 30 Jan 2018 17:10:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Lock mmap_sem when calling migrate_pages() in
 do_move_pages_to_node()
Message-ID: <20180130161025.GH21609@dhcp22.suse.cz>
References: <20180130030011.4310-1-zi.yan@sent.com>
 <20180130081415.GO21609@dhcp22.suse.cz>
 <5A7094DA.4000804@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A7094DA.4000804@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Zi Yan <zi.yan@sent.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 30-01-18 10:52:58, Zi Yan wrote:
> 
> 
> Michal Hocko wrote:
> > On Mon 29-01-18 22:00:11, Zi Yan wrote:
> >> From: Zi Yan <zi.yan@cs.rutgers.edu>
> >>
> >> migrate_pages() requires at least down_read(mmap_sem) to protect
> >> related page tables and VMAs from changing. Let's do it in
> >> do_page_moves() for both do_move_pages_to_node() and
> >> add_page_for_migration().
> >>
> >> Also add this lock requirement in the comment of migrate_pages().
> > 
> > This doesn't make much sense to me, to be honest. We are holding
> > mmap_sem for _read_ so we allow parallel updates like page faults
> > or unmaps. Therefore we are isolating pages prior to the migration.
> > 
> > The sole purpose of the mmap_sem in add_page_for_migration is to protect
> > from vma going away _while_ need it to get the proper page.
> 
> Then, I am wondering why we are holding mmap_sem when calling
> migrate_pages() in existing code.
> http://elixir.free-electrons.com/linux/latest/source/mm/migrate.c#L1576

You mean in the original code? I strongly suspect this was to not take
it for each page.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
