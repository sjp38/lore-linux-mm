Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3FBB280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 19:43:34 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j58so30860797qtc.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 16:43:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si10273371qtn.87.2017.05.19.16.43.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 16:43:33 -0700 (PDT)
Date: Fri, 19 May 2017 19:43:23 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] dm ioctl: Restore __GFP_HIGH in copy_params()
In-Reply-To: <20170519074647.GC13041@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com>
References: <20170518185040.108293-1-junaids@google.com> <20170518190406.GB2330@dhcp22.suse.cz> <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com> <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com> <20170519074647.GC13041@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Junaid Shahid <junaids@google.com>, David Rientjes <rientjes@google.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org



On Fri, 19 May 2017, Michal Hocko wrote:

> On Thu 18-05-17 19:50:46, Junaid Shahid wrote:
> > (Adding back the correct linux-mm email address and also adding linux-kernel.)
> > 
> > On Thursday, May 18, 2017 01:41:33 PM David Rientjes wrote:
> [...]
> > > Let's ask Mikulas, who changed this from PF_MEMALLOC to __GFP_HIGH, 
> > > assuming there was a reason to do it in the first place in two different 
> > > ways.
> 
> Hmm, the old PF_MEMALLOC used to have the following comment
>         /*
>          * Trying to avoid low memory issues when a device is
>          * suspended. 
>          */
> 
> I am not really sure what that means but __GFP_HIGH certainly have a
> different semantic than PF_MEMALLOC. The later grants the full access to
> the memory reserves while the prior on partial access. If this is _really_
> needed then it deserves a comment explaining why.
> -- 
> Michal Hocko
> SUSE Labs

Sometimes, I/O to a device mapper device is blocked until the userspace 
daemon dmeventd does some action (for example, when dm-mirror leg fails, 
dmeventd needs to mark the leg as failed in the lvm metadata and then 
reload the device).

The dmeventd daemon mlocks itself in memory so that it doesn't generate 
any I/O. But it must be able to call ioctls. __GFP_HIGH is there so that 
the ioctls issued by dmeventd have higher chance of succeeding if some I/O 
is blocked, waiting for dmeventd action. It reduces the possibility of 
low-memory-deadlock, though it doesn't eliminate it entirely.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
