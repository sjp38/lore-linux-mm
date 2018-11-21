Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E69246B24C7
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 02:11:35 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x98-v6so2578347ede.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:11:35 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p25-v6si7348146ejg.328.2018.11.20.23.11.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 23:11:34 -0800 (PST)
Date: Wed, 21 Nov 2018 08:11:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
Message-ID: <20181121071132.GD12932@dhcp22.suse.cz>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-4-mhocko@kernel.org>
 <alpine.LSU.2.11.1811201721470.2061@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811201721470.2061@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue 20-11-18 17:47:21, Hugh Dickins wrote:
> On Tue, 20 Nov 2018, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > filemap_map_pages takes a speculative reference to each page in the
> > range before it tries to lock that page. While this is correct it
> > also can influence page migration which will bail out when seeing
> > an elevated reference count. The faultaround code would bail on
> > seeing a locked page so we can pro-actively check the PageLocked
> > bit before page_cache_get_speculative and prevent from pointless
> > reference count churn.
> > 
> > Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> > Suggested-by: Jan Kara <jack@suse.cz>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Hugh Dickins <hughd@google.com>

Thanks!

> though I think this patch is more useful to the avoid atomic ops,
> and unnecessary dirtying of the cacheline, than to avoid the very
> transient elevation of refcount, which will not affect page migration
> very much.

Are you sure it would really be transient? In other words is it possible
that the fault around can block migration repeatedly under refault heavy
workload? I just couldn't convince myself, to be honest.
-- 
Michal Hocko
SUSE Labs
