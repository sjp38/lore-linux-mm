Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4BB6B0022
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 18:21:57 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m21so19765036qkk.12
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 15:21:57 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l10si4235493qvi.42.2018.04.26.15.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 15:21:55 -0700 (PDT)
Date: Fri, 27 Apr 2018 01:21:52 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
Message-ID: <20180427005213-mutt-send-email-mst@kernel.org>
References: <alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
 <1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
 <alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
 <alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
 <1524694663.4100.21.camel@HansenPartnership.com>
 <alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com>
 <1524697697.4100.23.camel@HansenPartnership.com>
 <23266.8532.619051.784274@quad.stoffel.home>
 <alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: John Stoffel <john@stoffel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Michal@stoffel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Hocko <mhocko@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>, Andrew@stoffel.org, David Rientjes <rientjes@google.com>, Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, David Miller <davem@davemloft.net>, edumazet@google.com

On Thu, Apr 26, 2018 at 05:50:20PM -0400, Mikulas Patocka wrote:
> How is the user or developer supposed to learn about this option, if 
> he gets no crash at all?

Look in /sys/kernel/debug/fail* ? That actually lets you
filter by module, process etc.

I think this patch conflates two things:

1. Make kvmalloc use the vmalloc path.
    This seems a bit narrow.
    What is special about kvmalloc? IMHO nothing - it's yet another user
    of __GFP_NORETRY or __GFP_RETRY_MAYFAIL. As any such
    user, it either recovers correctly or not.
    So IMHO it's just a case of
    making __GFP_NORETRY, __GFP_RETRY_MAYFAIL, or both
    fail once in a while.
    Seems like a better extension to me than focusing on vmalloc.
    I think you will find more bugs this way.

2. Ability to control this from a separate config
   option.

   It's still not that clear to me why is this such a
   hard requirement.  If a distro wants to force specific
   boot time options, why isn't CONFIG_CMDLINE sufficient?

   But assuming it's important to control this kind of
   fault injection to be controlled from
   a dedicated menuconfig option, why not the rest of
   faults?

IMHO if you split 1/2 up, and generalize, the path upstream
will be much smoother.

Hope this helps.

-- 
MST
