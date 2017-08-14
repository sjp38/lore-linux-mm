Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 810C96B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:51:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b20so118011303itd.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:51:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g24si8013309ioi.371.2017.08.14.15.51.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 15:51:14 -0700 (PDT)
Message-Id: <201708142251.v7EMp3j9081456@www262.sakura.ne.jp>
Subject: Re: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 =?ISO-2022-JP?B?b29tX3JlYXBlciByYWNlcyB3aXRoIHdyaXRlcg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 15 Aug 2017 07:51:02 +0900
References: <201708120046.AFI81780.OHMFtFSOFVQJOL@I-love.SAKURA.ne.jp> <20170814135919.GO19063@dhcp22.suse.cz>
In-Reply-To: <20170814135919.GO19063@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 12-08-17 00:46:18, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 11-08-17 16:54:36, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Fri 11-08-17 11:28:52, Tetsuo Handa wrote:
> > > > > > Will you explain the mechanism why random values are written instead of zeros
> > > > > > so that this patch can actually fix the race problem?
> > > > > 
> > > > > I am not sure what you mean here. Were you able to see a write with an
> > > > > unexpected content?
> > > > 
> > > > Yes. See http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp .
> > > 
> > > Ahh, I've missed that random part of your output. That is really strange
> > > because AFAICS the oom reaper shouldn't really interact here. We are
> > > only unmapping anonymous memory and even if a refault slips through we
> > > should always get zeros.
> > > 
> > > Your test case doesn't mmap MAP_PRIVATE of a file so we shouldn't even
> > > get any uninitialized data from a file by missing CoWed content. The
> > > only possible explanations would be that a page fault returned a
> > > non-zero data which would be a bug on its own or that a file write
> > > extend the file without actually writing to it which smells like a fs
> > > bug to me.
> > 
> > As I wrote at http://lkml.kernel.org/r/201708112053.FIG52141.tHJSOQFLOFMFOV@I-love.SAKURA.ne.jp ,
> > I don't think it is a fs bug.
> 
> Were you able to reproduce with other filesystems?

Yes, I can reproduce this problem using both xfs and ext4 on 4.11.11-200.fc25.x86_64
on Oracle VM VirtualBox on Windows.

I believe that this is not old data from disk, for I can reproduce this problem
using newly attached /dev/sdb which has never written any data (other than data
written by mkfs.xfs and mkfs.ext4).

  /dev/sdb /tmp ext4 rw,seclabel,relatime,data=ordered 0 0
  
The garbage pattern (the last 4096 bytes) is identical for both xfs and ext4.

>                                                    I wonder what is
> different in my testing because I cannot reproduce this at all. Well, I
> had to reduce the number of competing writer threads to 128 because I
> quickly hit the trashing behavior with more of them (and 4 CPUs). I will
> try on a larger machine.

I don't think a larger machine is necessary.
I can reproduce this problem with 8 competing writer threads on 4 CPUs.

I don't have native Linux environment. Maybe that is the difference.
Can you try VMware Workstation Player or Oracle VM VirtualBox environment?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
