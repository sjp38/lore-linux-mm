Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B224E6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:13:29 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 80so2361502wmb.7
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:13:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i23si2727434wmb.208.2017.12.20.01.13.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 01:13:28 -0800 (PST)
Date: Wed, 20 Dec 2017 10:13:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: shmctl(SHM_STAT) vs. /proc/sysvipc/shm permissions discrepancies
Message-ID: <20171220091326.GC4831@dhcp22.suse.cz>
References: <20171219094848.GE2787@dhcp22.suse.cz>
 <f8745470-b4fb-97ef-d6ab-40b437be181c@colorfullife.com>
 <CAKgNAkhkkx3znnfUN3rsY+SL7k5R+W0ui8__y1-WMLG=PFrCuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgNAkhkkx3znnfUN3rsY+SL7k5R+W0ui8__y1-WMLG=PFrCuQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: "Dr. Manfred Spraul" <manfred@colorfullife.com>, Linux API <linux-api@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Waychison <mikew@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed 20-12-17 09:44:47, Michael Kerrisk wrote:
> Hi Manfred,
> 
> On 20 December 2017 at 09:32, Dr. Manfred Spraul
> <manfred@colorfullife.com> wrote:
> > Hi Michal,
> >
> > On 12/19/2017 10:48 AM, Michal Hocko wrote:
> >>
> >> Hi,
> >> we have been contacted by our partner about the following permission
> >> discrepancy
> >> 1. Create a shared memory segment with permissions 600 with user A using
> >>     shmget(key, 1024, 0600 | IPC_CREAT)
> >> 2. ipcs -m should return an output as follows:
> >>
> >> ------ Shared Memory Segments --------
> >> key        shmid      owner      perms      bytes      nattch     status
> >> 0x58b74326 759562241  A          600        1024       0
> >>
> >> 3. Try to read the metadata with shmctl(0, SHM_STAT,...) as user B.
> >> 4. shmctl will return -EACCES
> >>
> >> The supper set information provided by shmctl can be retrieved by
> >> reading /proc/sysvipc/shm which does not require read permissions
> >> because it is 444.
> >>
> >> It seems that the discrepancy is there since ae7817745eef ("[PATCH] ipc:
> >> add generic struct ipc_ids seq_file iteration") when the proc interface
> >> has been introduced. The changelog is really modest on information or
> >> intention but I suspect this just got overlooked during review. SHM_STAT
> >> has always been about read permission and it is explicitly documented
> >> that way.
> >
> > Are you sure that this patch changed the behavior?
> > The proc interface is much older.
> 
> Yes, I think that's correct. The /proc/sysvipc interface appeared in
> 2.3.x, and AFAIK the behavior was already different from *_STAT back
> then.

I have probably misread the patch. It surely adds sysvipc_proc_fops,
maybe there was a different implementation previously. I haven't
checked.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
