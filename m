Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3B06B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:46:02 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n126so1376827wma.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:46:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19sor8044825ede.24.2017.12.19.08.46.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 08:46:00 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20171219094848.GE2787@dhcp22.suse.cz>
References: <20171219094848.GE2787@dhcp22.suse.cz>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Tue, 19 Dec 2017 17:45:40 +0100
Message-ID: <CAKgNAkjJrmCFY-h2oqKS3zM_D+Csx-17A27mh08WKahyOVzrgQ@mail.gmail.com>
Subject: Re: shmctl(SHM_STAT) vs. /proc/sysvipc/shm permissions discrepancies
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux API <linux-api@vger.kernel.org>, Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Waychison <mikew@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello Michal,

On 19 December 2017 at 10:48, Michal Hocko <mhocko@kernel.org> wrote:
> Hi,
> we have been contacted by our partner about the following permission
> discrepancy
>
> 1. Create a shared memory segment with permissions 600 with user A using
>    shmget(key, 1024, 0600 | IPC_CREAT)
> 2. ipcs -m should return an output as follows:
>
> ------ Shared Memory Segments --------
> key        shmid      owner      perms      bytes      nattch     status
> 0x58b74326 759562241  A          600        1024       0
>
> 3. Try to read the metadata with shmctl(0, SHM_STAT,...) as user B.
> 4. shmctl will return -EACCES
>
> The supper set information provided by shmctl can be retrieved by
> reading /proc/sysvipc/shm which does not require read permissions
> because it is 444.
>
> It seems that the discrepancy is there since ae7817745eef ("[PATCH] ipc:
> add generic struct ipc_ids seq_file iteration") when the proc interface
> has been introduced. The changelog is really modest on information or
> intention but I suspect this just got overlooked during review. SHM_STAT
> has always been about read permission and it is explicitly documented
> that way.

Yes, this was always a weirdness on Linux. Back before we got
/proc/sysvipc, it meant that ipcs(1) on Linux did not did not display
all IPC objects (unlike most other implementations, where ipcs(1)
showed everyone's objects, regardless of permissions). I remember
having an email conversation with Andries Brouwer about this, around
15 years ago. Eventually, an October 2012 series of util-linux patches
by Sami Kerola switched ipcs(1) to use /proc/sysvipc so that ipcs(1)
does now show all System V IPC objects.

> I am not a security expert to judge whether this leak can have some
> interesting consequences but I am really interested whether this is
> something we want to keep that way.  Do we want to filter and dump only
> shmids the caller has access to?

Do you mean change /proc/sysvipc/* output? I don't think that should
be changed. Modern ipcs(1) relies on it to do The Right Thing.

> This would break the delegation AFAICS.
> Do we want to make the file root only? That would probably break an
> existing userspace as well.
>
> Or should we simply allow SHM_STAT for processes without a read permission
> because the same information can be read by other means already?
>
> Any other ideas?

The situation is certainly odd. The only risk that I see is that
modifying *_STAT behavior could lead to behavior changes in (strange?)
programs that expect SHM_STAT / MSG_STAT / SEM_STAT to return only
information about objects for which they have read permission. But, is
there a pressing reason to make the change? (Okay, I guess iterating
using *_STAT is nicer than parsing /proc/sysvipc/*.)

Cheers,

Michael


> --
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
