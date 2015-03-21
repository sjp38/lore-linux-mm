Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7785A6B0038
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 09:33:29 -0400 (EDT)
Received: by wibg7 with SMTP id g7so10183216wib.1
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 06:33:29 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id jr10si11641892wjc.61.2015.03.21.06.33.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Mar 2015 06:33:25 -0700 (PDT)
Date: Sat, 21 Mar 2015 14:33:11 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V7] Allow compaction of unevictable pages
Message-ID: <20150321133311.GA23123@twins.programming.kicks-ass.net>
References: <1426859390-10974-1-git-send-email-emunson@akamai.com>
 <20150320151703.dfd116931ddb397ade8bfd8c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150320151703.dfd116931ddb397ade8bfd8c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-doc@vger.kernel.org, linux-rt-users@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 20, 2015 at 03:17:03PM -0700, Andrew Morton wrote:
> On Fri, 20 Mar 2015 09:49:50 -0400 Eric B Munson <emunson@akamai.com> wrote:
> 
> > Currently, pages which are marked as unevictable are protected from
> > compaction, but not from other types of migration.  The POSIX real time
> > extension explicitly states that mlock() will prevent a major page
> > fault, but the spirit of this is that mlock() should give a process the
> > ability to control sources of latency, including minor page faults.
> > However, the mlock manpage only explicitly says that a locked page will
> > not be written to swap and this can cause some confusion.  The
> > compaction code today does not give a developer who wants to avoid swap
> > but wants to have large contiguous areas available any method to achieve
> > this state.  This patch introduces a sysctl for controlling compaction
> > behavior with respect to the unevictable lru.  Users that demand no page
> > faults after a page is present can set compact_unevictable_allowed to 0
> > and users who need the large contiguous areas can enable compaction on
> > locked memory by leaving the default value of 1.
> 
> Do we really really really need the /proc knob?  We're already
> migrating these pages so users of mlock will occasionally see some
> latency - how likely is it that this patch will significantly damage
> anyone?

-rt disables everything that causes those migrations (with exception of
sys_migrate_pages).

And like I've argued before; mlock() is part of the posix real-time
extensions and the real-time people really do not want those migrations.
And while the letter of the posix spec allows migrations, the spirit
clearly does not.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
