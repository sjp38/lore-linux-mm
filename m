Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82C346B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 07:38:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x1-v6so5293068eds.16
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 04:38:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n25-v6si1245557edo.15.2018.11.05.04.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 04:38:39 -0800 (PST)
Date: Mon, 5 Nov 2018 13:38:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181105123837.GH4361@dhcp22.suse.cz>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181102155528.20358-1-mhocko@kernel.org>
 <20181105002009.GF27491@MiWiFi-R3L-srv>
 <20181105091407.GB4361@dhcp22.suse.cz>
 <20181105092851.GD4361@dhcp22.suse.cz>
 <20181105102520.GB22011@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105102520.GB22011@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon 05-11-18 18:25:20, Baoquan He wrote:
> Hi Michal,
> 
> On 11/05/18 at 10:28am, Michal Hocko wrote:
> > 
> > Or something like this. Ugly as hell, no question about that. I also
> > have to think about this some more to convince myself this will not
> > result in an endless loop under some situations.
> 
> It failed. Paste the log and patch diff here, please help check if I made
> any mistake on manual code change. The log is at bottom.

The retry patch is obviously still racy, it just makes the race window
slightly smaller and I hoped it would catch most of those races but this
is obviously not the case.

I was thinking about your MIGRATE_MOVABLE check some more and I still do
not like it much, we just change migrate type at many places and I have
hard time to actually see this is always safe wrt. to what we need here.

We should be able to restore the zone type check though. The
primary problem fixed by 15c30bc09085 ("mm, memory_hotplug: make
has_unmovable_pages more robust") was that early allocations made it to
the zone_movable range. If we add the check _after_ the PageReserved()
check then we should be able to rule all bootmem allocation out.

So what about the following (on top of the previous patch which makes
sense on its own I believe).
