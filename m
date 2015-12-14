Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 556156B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:06:30 -0500 (EST)
Received: by wmnn186 with SMTP id n186so117709155wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:06:30 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id t200si8345175wmt.109.2015.12.14.04.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 04:06:24 -0800 (PST)
Received: by wmpp66 with SMTP id p66so57795514wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:06:24 -0800 (PST)
Date: Mon, 14 Dec 2015 13:06:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: !PageLocked from shmem charge path hits VM_BUG_ON with 4.4-rc4
Message-ID: <20151214120621.GA4339@dhcp22.suse.cz>
References: <20151214100156.GA4540@dhcp22.suse.cz>
 <20151214110320.GB9544@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214110320.GB9544@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Daniel Vetter <daniel.vetter@intel.com>, David Airlie <airlied@linux.ie>, Mika Westerber <mika.westerberg@intel.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 14-12-15 12:03:20, Michal Hocko wrote:
> JFYI: Andrey Ryabinin has noticed that this might be related to
> http://lkml.kernel.org/r/CAPAsAGzrOQAABhOta_o-MzocnikjPtwJLfEKQJ3n5mbBm0T7Bw@mail.gmail.com
> 
> and indeed if somebody with pending signals would do wait_on_page_locked
> then it could race AFAIU.

No, a simple lock_page would fail to lock the page (thanks Andrey for
the clarification in the parallel email thread). I have missed that
__lock_page uses bit_wait_io and that would return EINTR when using
signal_pending. The fix has changed that to singnal_pending_state so
this will not happen anymore. I think the mystery is solved...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
