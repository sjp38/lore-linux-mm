Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62D786B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 20:40:30 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id a127so70482ywc.5
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 17:40:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor1007017ywc.216.2018.04.10.17.40.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 17:40:24 -0700 (PDT)
MIME-Version: 1.0
References: <201804080259.VS5U0mKT%fengguang.wu@intel.com> <20180410005908.167976-1-gthelen@google.com>
 <55efb2c6-04c5-d2bb-738e-8308aa0eaf8f@meituan.com>
In-Reply-To: <55efb2c6-04c5-d2bb-738e-8308aa0eaf8f@meituan.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 11 Apr 2018 00:40:11 +0000
Message-ID: <CAHH2K0aMhquqkpbxEWR3CoeDyHyZHViYK3y629U+=Hguo_vgKQ@mail.gmail.com>
Subject: Re: [PATCH v3] writeback: safer lock nesting
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <wanglong19@meituan.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, npiggin@gmail.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, Apr 10, 2018 at 1:15 AM Wang Long <wanglong19@meituan.com> wrote:

> > lock_page_memcg()/unlock_page_memcg() use spin_lock_irqsave/restore() i=
f
> > the page's memcg is undergoing move accounting, which occurs when a
> > process leaves its memcg for a new one that has
> > memory.move_charge_at_immigrate set.
> >
> > unlocked_inode_to_wb_begin,end() use spin_lock_irq/spin_unlock_irq() if
the
> > given inode is switching writeback domains.  Switches occur when enough
> > writes are issued from a new domain.
> >
> > This existing pattern is thus suspicious:
> >      lock_page_memcg(page);
> >      unlocked_inode_to_wb_begin(inode, &locked);
> >      ...
> >      unlocked_inode_to_wb_end(inode, locked);
> >      unlock_page_memcg(page);
> >
> > If both inode switch and process memcg migration are both in-flight the=
n
> > unlocked_inode_to_wb_end() will unconditionally enable interrupts while
> > still holding the lock_page_memcg() irq spinlock.  This suggests the
> > possibility of deadlock if an interrupt occurs before
> > unlock_page_memcg().
> >
> >      truncate
> >      __cancel_dirty_page
> >      lock_page_memcg
> >      unlocked_inode_to_wb_begin
> >      unlocked_inode_to_wb_end
> >      <interrupts mistakenly enabled>
> >                                      <interrupt>
> >                                      end_page_writeback
> >                                      test_clear_page_writeback
> >                                      lock_page_memcg
> >                                      <deadlock>
> >      unlock_page_memcg
> >
> > Due to configuration limitations this deadlock is not currently possibl=
e
> > because we don't mix cgroup writeback (a cgroupv2 feature) and
> > memory.move_charge_at_immigrate (a cgroupv1 feature).
> >
> > If the kernel is hacked to always claim inode switching and memcg
> > moving_account, then this script triggers lockup in less than a minute:
> >    cd /mnt/cgroup/memory
> >    mkdir a b
> >    echo 1 > a/memory.move_charge_at_immigrate
> >    echo 1 > b/memory.move_charge_at_immigrate
> >    (
> >      echo $BASHPID > a/cgroup.procs
> >      while true; do
> >        dd if=3D/dev/zero of=3D/mnt/big bs=3D1M count=3D256
> >      done
> >    ) &
> >    while true; do
> >      sync
> >    done &
> >    sleep 1h &
> >    SLEEP=3D$!
> >    while true; do
> >      echo $SLEEP > a/cgroup.procs
> >      echo $SLEEP > b/cgroup.procs
> >    done
> >
> > Given the deadlock is not currently possible, it's debatable if there's
> > any reason to modify the kernel.  I suggest we should to prevent future
> > surprises.
> This deadlock occurs three times in our environment=EF=BC=8C

> this deadlock occurs three times in our environment. It is better to cc
stable kernel and
> backport it.

That's interesting.  Are you using cgroup v1 or v2?  Do you enable
memory.move_charge_at_immigrate?
I assume you've been using 4.4 stable.  I'll look closer at it at a 4.4
stable backport.
