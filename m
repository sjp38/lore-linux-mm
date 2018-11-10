Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 606A66B0756
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 20:36:16 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id x5-v6so2786817pfn.22
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 17:36:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10-v6sor10524404pgn.78.2018.11.09.17.36.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 17:36:14 -0800 (PST)
Date: Fri, 9 Nov 2018 17:36:11 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to
 memfd
Message-ID: <20181110013611.GA199560@google.com>
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
 <CAKOZuesw1wG-YynWL7bVb+4BWtYp0Ei62vweWF+mqF1Ln-_2Tg@mail.gmail.com>
 <BB64C995-F374-49EB-8469-4820231D8152@amacapital.net>
 <CAKOZuetZrL10zWwn4Jzzg0QL2nd3Fm0JxGtzC79SZAfOK525Ag@mail.gmail.com>
 <F8A6A5DC-3BA0-43BD-B7EC-EDE199B33A02@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <F8A6A5DC-3BA0-43BD-B7EC-EDE199B33A02@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Colascione <dancol@google.com>, Jann Horn <jannh@google.com>, kernel list <linux-kernel@vger.kernel.org>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, valdis.kletnieks@vt.edu, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Nov 09, 2018 at 03:14:02PM -0800, Andy Lutomirski wrote:
> >>>> That aside: I wonder whether a better API would be something that
> >>>> allows you to create a new readonly file descriptor, instead of
> >>>> fiddling with the writability of an existing fd.
> >>> 
> >>> That doesn't work, unfortunately. The ashmem API we're replacing with
> >>> memfd requires file descriptor continuity. I also looked into opening
> >>> a new FD and dup2(2)ing atop the old one, but this approach doesn't
> >>> work in the case that the old FD has already leaked to some other
> >>> context (e.g., another dup, SCM_RIGHTS). See
> >>> https://developer.android.com/ndk/reference/group/memory. We can't
> >>> break ASharedMemory_setProt.
> >> 
> >> 
> >> Hmm.  If we fix the general reopen bug, a way to drop write access from
> >> an existing struct file would do what Android needs, right?  I dona??t
> >> know if there are general VFS issues with that.
> > 

I don't think there is a way to fix this in /proc/pid/fd. At the proc
level, the /proc/pid/fd/N files are just soft symlinks that follow through to
the actual file. The open is actually done on that inode/file. I think
changing it the way being discussed here means changing the way symlinks work
in Linux.

I think the right way to fix this is at the memfd inode level. I am working
on a follow up patch on top of this patch, and will send that out in a few
days (along with the man page updates).

thanks!

 - Joel
