Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03F586B0038
	for <linux-mm@kvack.org>; Sat, 18 Nov 2017 23:19:57 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p2so5838041pfk.13
        for <linux-mm@kvack.org>; Sat, 18 Nov 2017 20:19:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g5si4308275plk.466.2017.11.18.20.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Nov 2017 20:19:55 -0800 (PST)
Date: Sat, 18 Nov 2017 20:19:54 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v2] prctl: prctl(PR_SET_IDLE, PR_IDLE_MODE_KILLME), for
 stateless idle loops
Message-ID: <20171119041954.GA12039@bombadil.infradead.org>
References: <20171101053244.5218-1-slandden@gmail.com>
 <20171103063544.13383-1-slandden@gmail.com>
 <20171103090915.uuaqo56phdbt6gnf@dhcp22.suse.cz>
 <CA+49okqZ8CME0EN1xS_cCTc5Q-fGRreg0makhzNNuRpGs3mjfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+49okqZ8CME0EN1xS_cCTc5Q-fGRreg0makhzNNuRpGs3mjfw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Fri, Nov 17, 2017 at 08:45:03PM -0800, Shawn Landden wrote:
> On Fri, Nov 3, 2017 at 2:09 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 02-11-17 23:35:44, Shawn Landden wrote:
> > > 16 bytes per process is kinda spendy, but I want to keep
> > > lru behavior, which mem_score_adj does not allow. When a supervisor,
> > > like Android's user input is keeping track this can be done in
> > user-space.
> > > It could be pulled out of task_struct if an cross-indexing additional
> > > red-black tree is added to support pid-based lookup.
> >
> > This is still an abuse and the patch is wrong. We really do have an API
> > to use I fail to see why you do not use it.
> >
> When I looked at wait_queue_head_t it was 20 byes.

24 bytes actually; the compiler will add 4 bytes of padding between
the spinlock and the list_head.  But there's one for the entire system.
Then you add a 40 byte structure (wait_queue_entry) on the stack for each
sleeping process.  There's no per-process cost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
