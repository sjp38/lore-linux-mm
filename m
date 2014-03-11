Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 419926B0069
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 01:08:03 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i8so9014573qcq.3
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 22:08:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c10si4122030qcg.81.2014.03.10.22.08.02
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 22:08:02 -0700 (PDT)
Date: Tue, 11 Mar 2014 01:07:52 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140311050752.GA14329@redhat.com>
References: <20140305174503.GA16335@redhat.com>
 <20140305175725.GB16335@redhat.com>
 <20140307002210.GA26603@redhat.com>
 <20140311024906.GA9191@redhat.com>
 <20140310201340.81994295.akpm@linux-foundation.org>
 <20140310214612.3b4de36a.akpm@linux-foundation.org>
 <20140311045109.GB12551@redhat.com>
 <20140310220158.7e8b7f2a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140310220158.7e8b7f2a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Mon, Mar 10, 2014 at 10:01:58PM -0700, Andrew Morton wrote:
 > On Tue, 11 Mar 2014 00:51:09 -0400 Dave Jones <davej@redhat.com> wrote:
 > 
 > > On Mon, Mar 10, 2014 at 09:46:12PM -0700, Andrew Morton wrote:
 > >  > On Mon, 10 Mar 2014 20:13:40 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
 > >  > 
 > >  > > > Anyone ? I'm hitting this trace on an almost daily basis, which is a pain
 > >  > > > while trying to reproduce a different bug..
 > >  > > 
 > >  > > Damn, I thought we'd fixed that but it seems not.  Cc's added.
 > >  > > 
 > >  > > Guys, what stops the migration target page from coming unlocked in
 > >  > > parallel with zap_pte_range()'s call to migration_entry_to_page()?
 > >  > 
 > >  > page_table_lock, sort-of.  At least, transitions of is_migration_entry()
 > >  > and page_locked() happen under ptl.
 > >  > 
 > >  > I don't see any holes in regular migration.  Do you know if this is
 > >  > reproducible with CONFIG_NUMA_BALANCING=n or CONFIG_NUMA=n?
 > > 
 > > CONFIG_NUMA_BALANCING was n already btw, so I'll do a NUMA=n run.
 > 
 > There probably isn't much point unless trinity is using
 > sys_move_pages().  Is it?

Trinity will do every syscall an arch has.

In the test case I have so far, I've narrowed it down to the vm group of syscalls
(so running with '-g vm' will do anything that I deemed 'vm'. Including.. sys_move_pages)
I'll try to narrow it down further tomorrow.

 >  If so it would be interesting to disable
 > trinity's move_pages calls and see if it still fails.
 
Ok, I'll try that first.

 > Grasping at straws here, trying to reduce the amount of code to look at :(

*nod*, it's not helped by the fact that the trace happens at process exit time
which could be considerably later after the syscall that buggers everything up
has happened.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
