Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5686B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:37:49 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id w7so4935059qcr.25
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:37:48 -0700 (PDT)
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
        by mx.google.com with ESMTPS id t96si2409583qge.101.2014.04.10.13.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 13:37:48 -0700 (PDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so4406740qgd.23
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:37:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140410203246.GB31614@thunk.org>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
 <20140320153250.GC20618@thunk.org> <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
 <20140320163806.GA10440@thunk.org> <5346ED93.9040500@amacapital.net> <20140410203246.GB31614@thunk.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 10 Apr 2014 13:37:26 -0700
Message-ID: <CALCETrVmaGNCxo-L4-dPbUev3VXXEPR7xBzo3Fux6ny7yh_Gzw@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andy Lutomirski <luto@amacapital.net>, David Herrmann <dh.herrmann@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Thu, Apr 10, 2014 at 1:32 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Thu, Apr 10, 2014 at 12:14:27PM -0700, Andy Lutomirski wrote:
>>
>> This is the second time in a week that someone has asked for a way to
>> have a struct file (or struct inode or whatever) that can't be reopened
>> through /proc/pid/fd.  This should be quite easy to implement as a
>> separate feature.
>
> What I suggested on a different thread was to add the following new
> file descriptor flags, to join FD_CLOEXEC, which would be maniuplated
> using the F_GETFD and F_SETFD fcntl commands:
>
> FD_NOPROCFS     disallow being able to open the inode via /proc/<pid>/fd
>
> FD_NOPASSFD     disallow being able to pass the fd via a unix domain socket
>
> FD_LOCKFLAGS    if this bit is set, disallow any further changes of FD_CLOEXEC,
>                 FD_NOPROCFS, FD_NOPASSFD, and FD_LOCKFLAGS flags.
>
> Regardless of what else we might need to meet the use case for the
> proposed File Sealing API, I think this is a useful feature that could
> be used in many other contexts besides just the proposed
> memfd_create() use case.

It occurs to me that, before going nuts with these kinds of flags, it
may pay to just try to fix the /proc/self/fd issue for real -- we
could just make open("/proc/self/fd/3", O_RDWR) fail if fd 3 is
read-only.  That may be enough for the file sealing thing.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
