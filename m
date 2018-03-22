Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 15AFF6B0009
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:39:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i64so3448937wmd.8
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 01:39:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si4781551wrc.392.2018.03.22.01.39.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Mar 2018 01:39:09 -0700 (PDT)
Date: Thu, 22 Mar 2018 09:39:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: KVM hang after OOM
Message-ID: <20180322083907.GC22674@dhcp22.suse.cz>
References: <178719aa-b669-c443-bf87-5728b71557c0@i-love.sakura.ne.jp>
 <CABXGCsNecgRN7mn4OxZY2rqa2N4kVBw3f0s6XEvLob4uy3LOug@mail.gmail.com>
 <201803171213.BFF21361.OOSFVFHLJQOtFM@I-love.SAKURA.ne.jp>
 <CABXGCsN8mN7bGNDx9Tb2sewuXWp6DbcyKpMFv0UzGATAMELxqA@mail.gmail.com>
 <20180320065339.GA23100@dhcp22.suse.cz>
 <201803202120.FDI17671.VQMLOFJFOStHFO@I-love.SAKURA.ne.jp>
 <CABXGCsNBEpVoMzrhyNLKhzNxPs=9a+Z+2aUxJ8WtZ8gE+=OGSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsNBEpVoMzrhyNLKhzNxPs=9a+Z+2aUxJ8WtZ8gE+=OGSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, kvm@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu 22-03-18 02:14:42, Mikhail Gavrilov wrote:
> On 20 March 2018 at 17:20, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > Michal Hocko wrote:
> >> On Mon 19-03-18 21:23:12, Mikhail Gavrilov wrote:
> >> > using swap actively.
> >> > But I'm already satisfied with proposed patch.
> >> >
> >> > I am attached dmesg when I triggering OOM three times. And every time
> >> > after it system survived.
> >> > I think this patch should be merged in mainline.
> >>
> >> Could you be more specific what is _this_ patch, please?
> >
> > I think it is
> > "[PATCH] mm/thp: Do not wait for lock_page() in deferred_split_scan()".
> >
> > Unless the problem is something like commit 0b1d647a02c5a1b6
> > ("[PATCH] dm: work around mempool_alloc, bio_alloc_bioset deadlocks"),
> > there should be no need to use io_schedule_timeout().
> >
> > Mikhail, can you test with only
> > "[PATCH] mm/thp: Do not wait for lock_page() in deferred_split_scan()" and
> > "[PATCHv2] mm/shmem: Do not wait for lock_page() in shmem_unused_huge_shrink()"
> > applied? Because the last dmesg.txt was using io_schedule_timeout()...
> 
> 
> This is my fault that I'm not checked firstly fresh 4.16-rc6 (without patches).
> Now I am corrected. I conducted a series of experiments with the fresh
> rc6 kernel (without patches) and with applied mm/thp patch.
> The experiment showed that rc6 does not affected by described in this
> thread issue.
> Virtual machine in KVM not hangs after OOM occured.

OK, I have a suspicion that you have seen more issues triggering
simultaneously. One is a  mmap_sem deadlock reported by lockdep and
followed by VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY): mm/gup.c:498
which sounds suspicious on its own. I have quickly glanced through kvm
commits since 4.15 but nothing really jumped at me as a fix.

Then you have seen the lock_page in deferred_split_scan which might or
might not be a deadlock.

Hard to conclude what was the primary issue here. Let's see if the
problem reproduces for you with the current 4.16 kernel.

Thanks!
-- 
Michal Hocko
SUSE Labs
