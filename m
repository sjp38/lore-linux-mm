Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 444AE6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:55:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z36so191269wrb.13
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 23:55:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si6712799wrd.130.2017.08.14.23.55.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 23:55:47 -0700 (PDT)
Date: Tue, 15 Aug 2017 08:55:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170815065544.GA29067@dhcp22.suse.cz>
References: <201708120046.AFI81780.OHMFtFSOFVQJOL@I-love.SAKURA.ne.jp>
 <20170814135919.GO19063@dhcp22.suse.cz>
 <201708142251.v7EMp3j9081456@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708142251.v7EMp3j9081456@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 15-08-17 07:51:02, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > Were you able to reproduce with other filesystems?
> 
> Yes, I can reproduce this problem using both xfs and ext4 on 4.11.11-200.fc25.x86_64
> on Oracle VM VirtualBox on Windows.
> 
> I believe that this is not old data from disk, for I can reproduce this problem
> using newly attached /dev/sdb which has never written any data (other than data
> written by mkfs.xfs and mkfs.ext4).
> 
>   /dev/sdb /tmp ext4 rw,seclabel,relatime,data=ordered 0 0
>   
> The garbage pattern (the last 4096 bytes) is identical for both xfs and ext4.

Thanks a lot for retesting. It is now obvious that FS doesn't have
anything to do with this issue which is in line with my investigation
from yesterday and Friday. I simply cannot see any way the file position
would be updated with a zero length write. So this must be something
else. I have double checked the MM side of the page fault I couldn't
find anything there either so this smells like a stray pte while the
underlying page got reused or something TLB related.
 
> >                                                    I wonder what is
> > different in my testing because I cannot reproduce this at all. Well, I
> > had to reduce the number of competing writer threads to 128 because I
> > quickly hit the trashing behavior with more of them (and 4 CPUs). I will
> > try on a larger machine.
> 
> I don't think a larger machine is necessary.
> I can reproduce this problem with 8 competing writer threads on 4 CPUs.

OK, I will try with fewer writers which should make it easier to have it
run for long time without any trashing.
 
> I don't have native Linux environment. Maybe that is the difference.
> Can you try VMware Workstation Player or Oracle VM VirtualBox environment?

Hmm, I do not have any of those handy for use, unfortunately. I will
keep focusing on the native HW and KVM for today.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
