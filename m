Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C73D86B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 18:38:45 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so70606389pdb.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 15:38:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ff7si25176330pac.120.2015.03.16.15.38.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 15:38:44 -0700 (PDT)
Date: Mon, 16 Mar 2015 15:38:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] Move away from non-failing small allocations
Message-Id: <20150316153843.af945a9e452404c22c4db999@linux-foundation.org>
In-Reply-To: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, 11 Mar 2015 16:54:52 -0400 Michal Hocko <mhocko@suse.cz> wrote:

> as per discussion at LSF/MM summit few days back it seems there is a
> general agreement on moving away from "small allocations do not fail"
> concept.

Such a change affects basically every part of the kernel and every
kernel developer.  I expect most developers will say "it works well
enough and I'm not getting any bug reports so why should I spend time
on this?".  It would help if we were to explain the justification very
clearly.  https://lwn.net/Articles/636017/ is Jon's writeup of the
conference discussion.

Realistically, I don't think this overall effort will be successful -
we'll add the knob, it won't get enough testing and any attempt to
alter the default will be us deliberately destabilizing the kernel
without knowing how badly :(


I wonder if we can alter the behaviour only for filesystem code, so we
constrain the new behaviour just to that code where we're having
problems.  Most/all fs code goes via vfs methods so there's a reasonably
small set of places where we can call

static inline void enter_fs_code(struct super_block *sb)
{
	if (sb->my_small_allocations_can_fail)
		current->small_allocations_can_fail++;
}

that way (or something similar) we can select the behaviour on a per-fs
basis and the rest of the kernel remains unaffected.  Other subsystems
can opt in as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
