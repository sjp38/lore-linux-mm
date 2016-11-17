Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3926B0359
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:07:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so59140335wmw.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 13:07:36 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id g1si4390654wmd.9.2016.11.17.13.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 13:07:35 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id g23so337342851wme.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 13:07:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161117204707.GB10421@1wt.eu>
References: <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
 <87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
 <CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
 <87pomwi5p2.fsf@xmission.com> <CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
 <87pomwghda.fsf@xmission.com> <CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
 <87twb6avk8.fsf_-_@xmission.com> <87inrmavax.fsf_-_@xmission.com> <20161117204707.GB10421@1wt.eu>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 17 Nov 2016 13:07:33 -0800
Message-ID: <CAGXu5jJc6TmzdVp+4OMDAt5Kd68hHbNBXaRPD8X0+m558hx3qw@mail.gmail.com>
Subject: Re: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an
 unreadable file
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Andy Lutomirski <luto@amacapital.net>

On Thu, Nov 17, 2016 at 12:47 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Thu, Nov 17, 2016 at 11:08:22AM -0600, Eric W. Biederman wrote:
>>
>> It is the reasonable expectation that if an executable file is not
>> readable there will be no way for a user without special privileges to
>> read the file.  This is enforced in ptrace_attach but if we are
>> already attached there is no enforcement if a readonly executable
>> is exec'd.
>
> I'm really scared by this Eric. At least you want to make it a hardening
> option that can be disabled at run time, otherwise it can easily break a
> lot of userspace :
>
> admin@aloha:~$ ll /bin/bash /bin/coreutils /bin/ls /usr/bin/telnet
> -r-xr-x--x 1 root adm 549272 Oct 28 16:25 /bin/bash
> -rwx--x--x 1 root adm 765624 Oct 28 16:27 /bin/coreutils
> lrwxrwxrwx 1 root root 9 Oct 28 16:27 /bin/ls -> coreutils
> -r-xr-x--x 1 root adm  70344 Oct 28 16:34 /usr/bin/telnet
>
> And I've not invented it, I've being taught to do this more than 20
> years ago and been doing this since on any slightly hardened server
> just because in pratice it's efficient at stopping quite a bunch of
> rootkits which require to copy and modify your executables. Sure
> they could get the contents using ptrace, but using cp is much more
> common than ptrace in scripts and that works. This has prooven quite
> efficient in field at stopping some rootkits several times over the
> last two decades and I know I'm not the only one to do it. In fact
> I *never* install an executable with read permissions for users if
> there's no need for random users to copy it. Does it mean that
> nobody should be able to see why their favorite utility doesn't
> work anymore ? Not in my opinion, at least not by default.
>
> So here I fear that we'll break strace at many places where strace
> precisely matters to debug things.
>
> However I'd love to have this feature controlled by a sysctl (to
> enforce it by default where possible).

I'm not opposed to a sysctl for this. Regardless, I think we need to
embrace this idea now, though, since we'll soon end up with
architectures that enforce executable-only memory, in which case
ptrace will again fail. Almost better to get started here and then not
have more surprises later.

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
