Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B41AC6B005A
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 22:47:24 -0400 (EDT)
Date: Wed, 2 Sep 2009 10:47:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Message-ID: <20090902024707.GB6248@localhost>
References: <20090831102640.092092954@intel.com> <20090901084626.ac4c8879.kamezawa.hiroyu@jp.fujitsu.com> <20090901022514.GA11974@localhost> <20090901113214.60e7ae32.kamezawa.hiroyu@jp.fujitsu.com> <20090901064652.GA20342@localhost> <20090901161228.9fb33234.kamezawa.hiroyu@jp.fujitsu.com> <20090901085549.GA4454@localhost> <20090901163152.GC5022@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090901163152.GC5022@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 02, 2009 at 12:31:52AM +0800, Balbir Singh wrote:
> * Wu Fengguang <fengguang.wu@intel.com> [2009-09-01 16:55:49]:
> 
> > > My point is that memcg can show 'owner' of pages but the page may
> > > be shared with something important task _and_ if a task is migrated,
> > > its pages' memcg information is not updated now. Then, you can kill
> > > a task which is not in memcg.
> > 
> > Ah thanks! I'm not aware of that tricky fact, and it does make a
> > very good reason not to use memcg, although I guess locked page won't
> > be migrated.
> >
> 
> I think what Kamezawa-San is pointing to is that the task can migrate,
> leaving behind the page in the memcg and poisioning those pages can
> kill a task outside the memcg. 

Yeah Kame's words reminded me of the memcg goal: it may not have to
track task pages 100% accurately for all the tricky racy windows/cases.
So could be risky to use memcg for hwpoison testing.

Otherwise I felt like using memcg for hwpoison testing because the
exported things are not that bad, and our hwpoison stress testing
efforts may also be very good exercises to some aspects of memcg ;)

Back to the page sharing problem. For hwpoison testing, it is
acceptable for the test program and the init process to share _clean_
libc.so pages. Because the hwpoison of such pages can be recovered
gracefully by simply unmap and drop the hwpoisoned ones.

But if two tasks share some dirty pages (eg. shmem), then it could
be killing more tasks than expected. However
- this is a general problem independent the use of memcg
- could be avoided by checking page dirtiness and map count
- our test schemes simply won't try to create such insane conditions
  (It will include both tasks as the target.)

btw, hwpoison testing also allows "mis-killing" of no-owner pages (ie.
newly freed pages by the target task in some racy windows) which won't
affect the test correctness.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
