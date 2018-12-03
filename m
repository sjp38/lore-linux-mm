Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3049A6B68D6
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 06:28:56 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id l131so6710343pga.2
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 03:28:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z1sor18642241pfl.9.2018.12.03.03.28.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 03:28:54 -0800 (PST)
Date: Mon, 3 Dec 2018 14:28:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm: page_mapped: don't assume compound page is huge
 or THP
Message-ID: <20181203112849.jonqywnd4rx2wpe7@kshutemo-mobl1>
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
 <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
 <35a664c0-6dab-bb32-811e-65250200d195@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35a664c0-6dab-bb32-811e-65250200d195@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laszlo Ersek <lersek@redhat.com>
Cc: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, alex.williamson@redhat.com, aarcange@redhat.com, rientjes@google.com, mgorman@techsingularity.net, mhocko@suse.com, linux-kernel@vger.kernel.org

On Mon, Dec 03, 2018 at 11:23:58AM +0100, Laszlo Ersek wrote:
> Totally uninformed side-question:
> 
> how large can the return value of compound_order() be? MAX_ORDER?
> 
> Apparently, MAX_ORDER can be defined as CONFIG_FORCE_MAX_ZONEORDER.
> 
> "config FORCE_MAX_ZONEORDER" is listed in a number of Kconfig files.
> Among those, "arch/mips/Kconfig" permits "ranges" (?) that extend up to
> 64. Same applies to "arch/powerpc/Kconfig" and "arch/sh/mm/Kconfig".
> 
> If we left-shift "1" -- a signed int, which I assume in practice will
> always have two's complement representation, 1 sign bit, 31 value bits,
> and 0 padding bits --, by 31 or more bit positions, we get undefined
> behavior (as part of the left-shift operation).
> 
> Is this a practical concern?

Not really.

Assuming 4k PAGE_SIZE, compound_order() == 31 means 8 TiB pages. I doubt
we will see such allocation requests any time soon.

Even with 1k base page size, it's still 2 TiB.

We will see other limitations in page allocaiton path before the compund
order type will be an issue.

-- 
 Kirill A. Shutemov
