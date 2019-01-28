Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 156C08E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:07:13 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t7so6569967edr.21
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 05:07:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si2436146edk.66.2019.01.28.05.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 05:07:11 -0800 (PST)
Date: Mon, 28 Jan 2019 14:07:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm: migrate: don't rely on PageMovable() of newpage
 after unlocking it
Message-ID: <20190128130709.GJ18811@dhcp22.suse.cz>
References: <20190128121609.9528-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128121609.9528-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Matthew Wilcox <willy@infradead.org>, Vratislav Bendel <vbendel@redhat.com>, Rafael Aquini <aquini@redhat.com>

On Mon 28-01-19 13:16:09, David Hildenbrand wrote:
[...]
> My theory:
> 
> In __unmap_and_move(), we lock the old and newpage and perform the
> migration. In case of vitio-balloon, the new page will become
> movable, the old page will no longer be movable.
> 
> However, after unlocking newpage, I think there is nothing stopping
> the newpage from getting dequeued and freed by virtio-balloon. This
> will result in the newpage
> 1. No longer having PageMovable()
> 2. Getting moved to the local list before finally freeing it (using
>    page->lru)

Does that mean that the virtio-balloon can change the Movable state
while there are other users of the page? Can you point to the code that
does it? How come this can be safe at all? Or is the PageMovable stable
only under the page lock?

-- 
Michal Hocko
SUSE Labs
