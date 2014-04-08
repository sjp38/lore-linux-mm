Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 708376B0035
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 15:53:05 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so1472185wgh.4
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 12:53:04 -0700 (PDT)
Received: from mail-we0-x232.google.com (mail-we0-x232.google.com [2a00:1450:400c:c03::232])
        by mx.google.com with ESMTPS id eh10si1504177wib.58.2014.04.08.12.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 12:53:03 -0700 (PDT)
Received: by mail-we0-f178.google.com with SMTP id u56so1485738wes.9
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 12:53:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1404080914280.8782@nuc>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de>
	<5343A494.9070707@suse.cz>
	<alpine.DEB.2.10.1404080914280.8782@nuc>
Date: Tue, 8 Apr 2014 15:53:02 -0400
Message-ID: <CA+TgmoY=vUdtdnJUEK1h-UcaNoqqLUctt44S8vj2B7EVUXUOyA@mail.gmail.com>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default
From: Robert Haas <robertmhaas@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sivanich@sgi.com

On Tue, Apr 8, 2014 at 10:17 AM, Christoph Lameter <cl@linux.com> wrote:
> Another solution here would be to increase the threshhold so that
> 4 socket machines do not enable zone reclaim by default. The larger the
> NUMA system is the more memory is off node from the perspective of a
> processor and the larger the hit from remote memory.

Well, as Josh quite rightly said, the hit from accessing remote memory
is never going to be as large as the hit from disk.  If and when there
is a machine where remote memory is more expensive to access than
disk, that's a good argument for zone_reclaim_mode.  But I don't
believe that's anywhere close to being true today, even on an 8-socket
machine with an SSD.

Now, perhaps the fear is that if we access that remote memory
*repeatedly* the aggregate cost will exceed what it would have cost to
fault that page into the local node just once.  But it takes a lot of
accesses for that to be true, and most of the time you won't get them.
 Even if you do, I bet many workloads will prefer even performance
across all the accesses over a very slow first access followed by
slightly faster subsequent accesses.

In an ideal world, the kernel would put the hottest pages on the local
node and the less-hot pages on remote nodes, moving pages around as
the workload shifts.  In practice, that's probably pretty hard.
Fortunately, it's not nearly as important as making sure we don't
unnecessarily hit the disk, which is infinitely slower than any memory
bank.

-- 
Robert Haas
EnterpriseDB: http://www.enterprisedb.com
The Enterprise PostgreSQL Company

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
