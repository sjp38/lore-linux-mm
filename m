Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85EC16B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 03:25:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so37146894wme.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 00:25:39 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id b186si55198028wmc.47.2016.06.03.00.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 00:25:38 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a20so9839248wma.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 00:25:38 -0700 (PDT)
Date: Fri, 3 Jun 2016 09:25:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603072536.GB20676@dhcp22.suse.cz>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <20160602092113.GH1995@dhcp22.suse.cz>
 <20160603071551.GA453@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603071551.GA453@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri 03-06-16 16:15:51, Sergey Senozhatsky wrote:
> Hello,
> 
> On (06/02/16 11:21), Michal Hocko wrote:
> [..]
> > @@ -2863,6 +2854,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
> >  
> >  		collect_mm_slot(mm_slot);
> >  	}
> > +	mmput(mm);
> >  
> >  	return progress;
> >  }
> 
> this possibly sleeping mmput() is called from
> under the spin_lock(&khugepaged_mm_lock).

You are right. khugepaged_scan_mm_slot returns with the lock held.
mmput_async would deal with it.
 
> there is also a trivial build fixup needed
> (move collect_mm_slot() before __khugepaged_exit()).

will fix that. Thanks!

> it's quite hard to trigger the bug (somehow), so I can't
> follow up with more information as of now.

Thanks anyway!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
