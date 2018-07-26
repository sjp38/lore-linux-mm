Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA816B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:50:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x2-v6so1553966pgp.4
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:50:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x21-v6si1934867pll.24.2018.07.26.12.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 12:50:14 -0700 (PDT)
Date: Thu, 26 Jul 2018 12:50:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Message-Id: <20180726125013.ea82bfa3194386733b3943ab@linux-foundation.org>
In-Reply-To: <21c31952-7632-b8e1-aa33-d124ce96b88e@redhat.com>
References: <20180720123422.10127-1-david@redhat.com>
	<9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
	<f8d7b5f9-e5ee-0625-f53d-50d1841e1388@redhat.com>
	<20180724072237.GA28386@dhcp22.suse.cz>
	<e5264f8e-2bb5-7a9b-6352-ad18f04d49c2@redhat.com>
	<20180726083042.GC28386@dhcp22.suse.cz>
	<21c31952-7632-b8e1-aa33-d124ce96b88e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?ISO-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On Thu, 26 Jul 2018 10:45:54 +0200 David Hildenbrand <david@redhat.com> wrote:

> > Does each user of PG_balloon check for PG_reserved? If this is the case
> > then yes this would be OK.
> > 
> 
> I can only spot one user of PageBalloon() at all (fs/proc/page.c) ,
> which makes me wonder if this bit is actually still relevant. I think
> the last "real" user was removed with
> 
> commit b1123ea6d3b3da25af5c8a9d843bd07ab63213f4
> Author: Minchan Kim <minchan@kernel.org>
> Date:   Tue Jul 26 15:23:09 2016 -0700
> 
>     mm: balloon: use general non-lru movable page feature
> 
>     Now, VM has a feature to migrate non-lru movable pages so balloon
>     doesn't need custom migration hooks in migrate.c and compaction.c.
> 
> 
> The only user of PG_balloon in general is
> "include/linux/balloon_compaction.h", used effectively only by
> virtio_balloon.
> 
> All such pages are allocated via balloon_page_alloc() and never set
> reserved.
> 
> So to me it looks like PG_balloon could be easily reused, especially to
> also exclude virtio-balloon pages from dumps.

Agree.  Maintaining a thingy for page-types.c which hardly anyone uses
(surely) isn't sufficient justification for consuming a page flag.  We
should check with the virtio developers first, but this does seem to be
begging to be reclaimed.
