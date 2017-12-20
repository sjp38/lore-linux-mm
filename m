Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E57776B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:20:27 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n13so2371491wmc.3
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:20:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 184si2664876wmo.215.2017.12.20.01.20.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 01:20:26 -0800 (PST)
Date: Wed, 20 Dec 2017 10:20:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: shmctl(SHM_STAT) vs. /proc/sysvipc/shm permissions discrepancies
Message-ID: <20171220092025.GD4831@dhcp22.suse.cz>
References: <20171219094848.GE2787@dhcp22.suse.cz>
 <CAKgNAkjJrmCFY-h2oqKS3zM_D+Csx-17A27mh08WKahyOVzrgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgNAkjJrmCFY-h2oqKS3zM_D+Csx-17A27mh08WKahyOVzrgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Linux API <linux-api@vger.kernel.org>, Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Waychison <mikew@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue 19-12-17 17:45:40, Michael Kerrisk wrote:
> Hello Michal,
> 
> On 19 December 2017 at 10:48, Michal Hocko <mhocko@kernel.org> wrote:
> > Hi,
> > we have been contacted by our partner about the following permission
> > discrepancy
> >
> > 1. Create a shared memory segment with permissions 600 with user A using
> >    shmget(key, 1024, 0600 | IPC_CREAT)
> > 2. ipcs -m should return an output as follows:
> >
> > ------ Shared Memory Segments --------
> > key        shmid      owner      perms      bytes      nattch     status
> > 0x58b74326 759562241  A          600        1024       0
> >
> > 3. Try to read the metadata with shmctl(0, SHM_STAT,...) as user B.
> > 4. shmctl will return -EACCES
> >
> > The supper set information provided by shmctl can be retrieved by
> > reading /proc/sysvipc/shm which does not require read permissions
> > because it is 444.
> >
> > It seems that the discrepancy is there since ae7817745eef ("[PATCH] ipc:
> > add generic struct ipc_ids seq_file iteration") when the proc interface
> > has been introduced. The changelog is really modest on information or
> > intention but I suspect this just got overlooked during review. SHM_STAT
> > has always been about read permission and it is explicitly documented
> > that way.
> 
> Yes, this was always a weirdness on Linux. Back before we got
> /proc/sysvipc, it meant that ipcs(1) on Linux did not did not display
> all IPC objects (unlike most other implementations, where ipcs(1)
> showed everyone's objects, regardless of permissions). I remember
> having an email conversation with Andries Brouwer about this, around
> 15 years ago. Eventually, an October 2012 series of util-linux patches
> by Sami Kerola switched ipcs(1) to use /proc/sysvipc so that ipcs(1)
> does now show all System V IPC objects.

Thanks for the clarification.

> > I am not a security expert to judge whether this leak can have some
> > interesting consequences but I am really interested whether this is
> > something we want to keep that way.  Do we want to filter and dump only
> > shmids the caller has access to?
> 
> Do you mean change /proc/sysvipc/* output? I don't think that should
> be changed. Modern ipcs(1) relies on it to do The Right Thing.

OK, I somehow suspected somebody will rely on this.

> > This would break the delegation AFAICS.
> > Do we want to make the file root only? That would probably break an
> > existing userspace as well.
> >
> > Or should we simply allow SHM_STAT for processes without a read permission
> > because the same information can be read by other means already?
> >
> > Any other ideas?
> 
> The situation is certainly odd. The only risk that I see is that
> modifying *_STAT behavior could lead to behavior changes in (strange?)
> programs that expect SHM_STAT / MSG_STAT / SEM_STAT to return only
> information about objects for which they have read permission.

Hmm, do you mean those would iterate shmid space to find their own? That
would be certainly odd.

> But, is
> there a pressing reason to make the change? (Okay, I guess iterating
> using *_STAT is nicer than parsing /proc/sysvipc/*.)

The reporter of this issue claims that "Reading /proc/sysvipc/shm is way
slower than executing the system call." I haven't checked that but I can
imagine that /proc/sysvipc/shm can take quite some time when there are
_many_ segments registered. So they would like to use the syscall but
the interacting parties do not have compatible permissions.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
