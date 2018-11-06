Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1FF26B02E8
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:16:30 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k203so26098549qke.2
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:16:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q4si6374357qtb.265.2018.11.06.01.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 01:16:29 -0800 (PST)
Date: Tue, 6 Nov 2018 17:16:24 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181106091624.GL27491@MiWiFi-R3L-srv>
References: <20181102155528.20358-1-mhocko@kernel.org>
 <20181105002009.GF27491@MiWiFi-R3L-srv>
 <20181105091407.GB4361@dhcp22.suse.cz>
 <20181105092851.GD4361@dhcp22.suse.cz>
 <20181105102520.GB22011@MiWiFi-R3L-srv>
 <20181105123837.GH4361@dhcp22.suse.cz>
 <20181105142308.GJ27491@MiWiFi-R3L-srv>
 <20181105171002.GO4361@dhcp22.suse.cz>
 <20181106002216.GK27491@MiWiFi-R3L-srv>
 <20181106082826.GC27423@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106082826.GC27423@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On 11/06/18 at 09:28am, Michal Hocko wrote:
> > > > > > It failed. Paste the log and patch diff here, please help check if I made
> > > > > > any mistake on manual code change. The log is at bottom.
> > > > > 
> > > > > The retry patch is obviously still racy, it just makes the race window
> > > > > slightly smaller and I hoped it would catch most of those races but this
> > > > > is obviously not the case.
> > > > > 
> > > > > I was thinking about your MIGRATE_MOVABLE check some more and I still do
> > > > > not like it much, we just change migrate type at many places and I have
> > > > > hard time to actually see this is always safe wrt. to what we need here.
> > > > > 
> > > > > We should be able to restore the zone type check though. The
> > > > > primary problem fixed by 15c30bc09085 ("mm, memory_hotplug: make
> > > > > has_unmovable_pages more robust") was that early allocations made it to
> > > > > the zone_movable range. If we add the check _after_ the PageReserved()
> > > > > check then we should be able to rule all bootmem allocation out.
> > > > > 
> > > > > So what about the following (on top of the previous patch which makes
> > > > > sense on its own I believe).
> > > > 
> > > > Yes, I think this looks very reasonable and should be robust.
> > > > 
> > > > Have tested it, hot removing 4 hotpluggable nodes continusously
> > > > succeeds, and then hot adding them back, still works well.
> > > > 
> > > > So please feel free to add my Tested-by or Acked-by.
> > > > 
> > > > Tested-by: Baoquan He <bhe@redhat.com>
> > > > or
> > > > Acked-by: Baoquan He <bhe@redhat.com>
> > > 
> > > Thanks for retesting! Does this apply to both patches?
> > 
> > Sorry, don't get it. I just applied this on top of linus's tree and
> > tested. Do you mean applying it on top of previous code change?
> 
> Yes. While the first patch will obviously not help for movable zone
> because the movable check will override any later check it
> seems still useful to reduce false positives on normal zones.

Hmm, I don't know if it will bring a little bit confusion on code
understanding. Since we only recognize the movable zone issue, and I can
only reproduce and verify it on the movable zone issue with the movable
zone check adding.

Not sure if there are any scenario or use cases to cover those newly added
checking other movable zone checking. Surely, I have no objection to
adding them. But the two patches are separate issues, they have no
dependency on each other.

I just tested the movable zone checking yesterday, will add your
previous check back, then test again. I believe the result will be
positive. Will udpate once done.

Thanks
Baoquan
