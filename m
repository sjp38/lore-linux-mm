Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B49566B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 06:54:11 -0500 (EST)
Received: by wmpp66 with SMTP id p66so57351692wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:54:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7si22284699wmg.5.2015.12.14.03.54.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 03:54:10 -0800 (PST)
Date: Mon, 14 Dec 2015 12:54:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm related crash
Message-ID: <20151214115408.GC9544@dhcp22.suse.cz>
References: <20151210154801.GA12007@lahna.fi.intel.com>
 <20151214092433.GA90449@black.fi.intel.com>
 <20151214100556.GB4540@dhcp22.suse.cz>
 <CAPAsAGzrOQAABhOta_o-MzocnikjPtwJLfEKQJ3n5mbBm0T7Bw@mail.gmail.com>
 <20151214105719.GA9544@dhcp22.suse.cz>
 <CAPAsAGxkYf0b_ZzhyuvxyNcWWvAyXHehGJbeGUAgu2Zb2u=31Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGxkYf0b_ZzhyuvxyNcWWvAyXHehGJbeGUAgu2Zb2u=31Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mika Westerberg <mika.westerberg@intel.com>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon 14-12-15 14:14:41, Andrey Ryabinin wrote:
> 2015-12-14 13:57 GMT+03:00 Michal Hocko <mhocko@suse.cz>:
> > On Mon 14-12-15 13:13:22, Andrey Ryabinin wrote:
> >> 2015-12-14 13:05 GMT+03:00 Michal Hocko <mhocko@suse.cz>:
> >> > On Mon 14-12-15 11:24:33, Kirill A. Shutemov wrote:
> >> >> On Thu, Dec 10, 2015 at 05:48:01PM +0200, Mika Westerberg wrote:
> >> >> > Hi Kirill,
> >> >> >
> >> >> > I got following crash on my desktop machine while building swift. It
> >> >> > reproduces pretty easily on 4.4-rc4.
> >> >> >
> >> >> > Before it happens the ld process is killed by OOM killer. I attached the
> >> >> > whole dmesg.
> >> >> >
> >> >> > [  254.740603] page:ffffea00111c31c0 count:2 mapcount:0 mapping:          (null) index:0x0
> >> >> > [  254.740636] flags: 0x5fff8000048028(uptodate|lru|swapcache|swapbacked)
> >> >> > [  254.740655] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> >> >> > [  254.740679] ------------[ cut here ]------------
> >> >> > [  254.740690] kernel BUG at mm/memcontrol.c:5270!
> >> >>
> >> >>
> >> >> Hm. I don't see how this can happen.
> >> >
> >> > What a coincidence. I have just posted a similar report:
> >> > http://lkml.kernel.org/r/20151214100156.GA4540@dhcp22.suse.cz except I
> >> > have hit the VM_BUG_ON from a different path. My suspicion is that
> >> > somebody unlocks the page while we are waiting on the writeback.
> >> > I am trying to reproduce this now.
> >>
> >> Guys, this is fixed in rc5 - dfd01f026058a ("sched/wait: Fix the
> >> signal handling fix").
> >> http://lkml.kernel.org/r/<20151212162342.GF11257@ret.masoncoding.com>
> >
> > Hmm, so you think that some callpath was doing wait_on_page_locked and
> > the above bug would allow a race and then unlock the page under our
> > feet?
> 
> It rather more simple, read report carefully from the link I gave.
>  __wait_on_bit_lock() in __lock_page() could just return  -EINTR and
> leave the page unlocked.
> So in rc4 lock_page() simply didn't work (sometimes).

Ohhh, right you are! Thanks for the clarification.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
