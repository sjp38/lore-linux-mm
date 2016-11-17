Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 918596B0357
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:47:25 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so59014181wme.4
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 12:47:25 -0800 (PST)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id km9si4426569wjb.282.2016.11.17.12.47.23
        for <linux-mm@kvack.org>;
        Thu, 17 Nov 2016 12:47:24 -0800 (PST)
Date: Thu, 17 Nov 2016 21:47:07 +0100
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an
 unreadable file
Message-ID: <20161117204707.GB10421@1wt.eu>
References: <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
 <87y41kjn6l.fsf@xmission.com>
 <20161019172917.GE1210@laptop.thejh.net>
 <CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
 <87pomwi5p2.fsf@xmission.com>
 <CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
 <87pomwghda.fsf@xmission.com>
 <CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
 <87twb6avk8.fsf_-_@xmission.com>
 <87inrmavax.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87inrmavax.fsf_-_@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>

On Thu, Nov 17, 2016 at 11:08:22AM -0600, Eric W. Biederman wrote:
> 
> It is the reasonable expectation that if an executable file is not
> readable there will be no way for a user without special privileges to
> read the file.  This is enforced in ptrace_attach but if we are
> already attached there is no enforcement if a readonly executable
> is exec'd.

I'm really scared by this Eric. At least you want to make it a hardening
option that can be disabled at run time, otherwise it can easily break a
lot of userspace :

admin@aloha:~$ ll /bin/bash /bin/coreutils /bin/ls /usr/bin/telnet
-r-xr-x--x 1 root adm 549272 Oct 28 16:25 /bin/bash
-rwx--x--x 1 root adm 765624 Oct 28 16:27 /bin/coreutils
lrwxrwxrwx 1 root root 9 Oct 28 16:27 /bin/ls -> coreutils
-r-xr-x--x 1 root adm  70344 Oct 28 16:34 /usr/bin/telnet

And I've not invented it, I've being taught to do this more than 20
years ago and been doing this since on any slightly hardened server
just because in pratice it's efficient at stopping quite a bunch of
rootkits which require to copy and modify your executables. Sure
they could get the contents using ptrace, but using cp is much more
common than ptrace in scripts and that works. This has prooven quite
efficient in field at stopping some rootkits several times over the
last two decades and I know I'm not the only one to do it. In fact
I *never* install an executable with read permissions for users if
there's no need for random users to copy it. Does it mean that
nobody should be able to see why their favorite utility doesn't
work anymore ? Not in my opinion, at least not by default.

So here I fear that we'll break strace at many places where strace
precisely matters to debug things.

However I'd love to have this feature controlled by a sysctl (to
enforce it by default where possible).

Thanks,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
