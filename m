Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E440D6B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:32:36 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o23-v6so13664598pll.12
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:32:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r14-v6si18290211pfa.296.2018.05.23.01.32.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 01:32:35 -0700 (PDT)
Date: Wed, 23 May 2018 10:32:32 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC] Checking for error code in __offline_pages
Message-ID: <20180523083232.GI20441@dhcp22.suse.cz>
References: <20180523073547.GA29266@techadventures.net>
 <20180523075239.GF20441@dhcp22.suse.cz>
 <20180523081649.GA30518@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523081649.GA30518@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

On Wed 23-05-18 10:16:49, Oscar Salvador wrote:
[...]
> AFAIU, permament errors are things like -EBUSY, -ENOSYS, -ENOMEM,
> and a temporary one would be -EAGAIN?

It would be really great to have EBUSY as permanent and ENOMEM and
EAGAIN as temporary failures. But this is not so easy. The migration
code failes on the elevated ref count usually and we simply do not know
whether this is a short term pin or somebody holding the reference
basically for ever (from the migration POV). There was some discussion
about longterm pins on pages at LSFMM this year but it will take quite
some time before we will get some working solution.

> Maybe it is overcomplicated, but what about adding another parameter to
> migrate_pages() where we set the real error.
> something like:
> 
> int migrate_pages(struct list_head *from, new_page_t get_new_page,
> 		free_page_t put_new_page, unsigned long private,
> 		enum migrate_mode mode, int reason, int *error)

I am not sure we really need a new parameter. migrate_pages will tell us
the failure. We just do not know _which_ error to return currently.

-- 
Michal Hocko
SUSE Labs
