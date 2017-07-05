Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7DE46B03A5
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:18:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z81so316097wrc.2
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:18:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k8si17040412wmh.116.2017.07.05.14.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:18:52 -0700 (PDT)
Date: Wed, 5 Jul 2017 14:18:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes
 in the stack
Message-Id: <20170705141849.2e0e4721d975277183eb178f@linux-foundation.org>
In-Reply-To: <20170705182849.GA18027@dhcp22.suse.cz>
References: <20170705165602.15005-1-mhocko@kernel.org>
	<CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
	<20170705182849.GA18027@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 5 Jul 2017 20:28:49 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> "mm: enlarge stack guard gap" has introduced a regression in some rust
> and Java environments which are trying to implement their own stack
> guard page.  They are punching a new MAP_FIXED mapping inside the
> existing stack Vma.
> 
> This will confuse expand_{downwards,upwards} into thinking that the stack
> expansion would in fact get us too close to an existing non-stack vma
> which is a correct behavior wrt. safety. It is a real regression on
> the other hand. Let's work around the problem by considering PROT_NONE
> mapping as a part of the stack. This is a gros hack but overflowing to
> such a mapping would trap anyway an we only can hope that usespace
> knows what it is doing and handle it propely.
> 
> Fixes: d4d2d35e6ef9 ("mm: larger stack guard gap, between vmas")

That should be 1be7107fbe18, yes?

> Debugged-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
