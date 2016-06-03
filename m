Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7299C6B025E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 09:38:21 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w143so105561230oiw.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 06:38:21 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id uk2si5834921pab.226.2016.06.03.06.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 06:38:20 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 62so11565958pfd.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 06:38:20 -0700 (PDT)
Date: Fri, 3 Jun 2016 22:38:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603133813.GA578@swordfish>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <20160602092113.GH1995@dhcp22.suse.cz>
 <20160603071551.GA453@swordfish>
 <20160603072536.GB20676@dhcp22.suse.cz>
 <20160603084347.GA502@swordfish>
 <20160603095549.GD20676@dhcp22.suse.cz>
 <20160603100505.GE20676@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603100505.GE20676@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On (06/03/16 12:05), Michal Hocko wrote:
> > > RIP collect_mm_slot() + 0x42/0x84
> > > 	khugepaged
> > 
> > So is this really collect_mm_slot called directly from khugepaged or is
> > some inlining going on there?

inlining I suppose.

> > > 	prepare_to_wait_event
> > > 	maybe_pmd_mkwrite
> > > 	kthread
> > > 	_raw_sin_unlock_irq
> > > 	ret_from_fork
> > > 	kthread_create_on_node
> > > 
> > > collect_mm_slot() + 0x42/0x84 is
> > 
> > I guess that the problem is that I have missed that __khugepaged_exit
> > doesn't clear the cached khugepaged_scan.mm_slot. Does the following on
> > top fixes that?
> 
> That wouldn't be sufficient after a closer look. We need to do the same
> from khugepaged_scan_mm_slot when atomic_inc_not_zero fails. So I guess
> it would be better to stick it into collect_mm_slot.

Michal, I'll try to test during the weekend (away from the affected box
now), but in the worst case it can as late as next Thursday (gonna travel
next week).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
