Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id lBCN35Xa026449
	for <linux-mm@kvack.org>; Wed, 12 Dec 2007 15:03:06 -0800
Received: from py-out-1112.google.com (pybu77.prod.google.com [10.34.97.77])
	by zps76.corp.google.com with ESMTP id lBCN2T4w014689
	for <linux-mm@kvack.org>; Wed, 12 Dec 2007 15:03:05 -0800
Received: by py-out-1112.google.com with SMTP id u77so1120939pyb.3
        for <linux-mm@kvack.org>; Wed, 12 Dec 2007 15:03:04 -0800 (PST)
Message-ID: <532480950712121503r64dbd51oc4778e96cbd37e3c@mail.gmail.com>
Date: Wed, 12 Dec 2007 15:03:04 -0800
From: "Michael Rubin" <mrubin@google.com>
Subject: Re: [patch 1/1] Writeback fix for concurrent large and small file writes.
In-Reply-To: <1197492954.6353.64.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071211020255.CFFB21080E@localhost>
	 <1197492954.6353.64.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Dec 12, 2007 12:55 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> On Mon, 2007-12-10 at 18:02 -0800, Michael Rubin wrote:
> > From: Michael Rubin <mrubin@google.com>
> The part I miss here is the rationale on _how_ you solve the problem.
>
> The patch itself is simple enough, but I've been staring at this code
> for a while now, and I'm just not getting it.

Apologies for the lack of rationale. I have been staring at this code
for awhile also and it makes my head hurt. I have a patch coming
(hopefully today) that proposes using one data  structure with a more
consistent priority scheme for 2.6.25. To me it's simpler, but I am
biased.

The problem we encounter when we append to a large file at a fast rate
while also writing to smaller files is that the wb_kupdate thread does
not keep up with disk traffic. In this workload often the inodes end
up at fs/fs-writeback.c:287 after do_writepages, since do_writepages
did not write all the pages.  This can be due to congestion but I
think there are other causes also since I have observed so.

The first issue is that the inode is put on the s_more_io queue. This
ensures that more_io is set at the end of sync_sb_inodes. The result
from that is the wb_kupdate routine will perform a sleep at
mm/page-writeback.c:642. This slows us down enough that the wb_kupdate
cannot keep up with traffic.

The other issue is that the inode that has been placed on the
s_more_io queue cannot be processed by sync_sb_inodes until the entire
s_io list is empty. With lots of small files that are not being
dirtied as quickly as the one large inode on the s_more_io queue the
inode with the most pages being dirtied is not given attention and
wb_kupdate cannot keep up again.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
