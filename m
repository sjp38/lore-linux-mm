Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40C1B6B0362
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:53:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so122926596pfk.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 13:53:49 -0800 (PST)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id q71si4856106pfj.175.2016.11.17.13.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 13:53:48 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <87inrmavax.fsf_-_@xmission.com>
	<20161117204707.GB10421@1wt.eu>
	<CAGXu5jJc6TmzdVp+4OMDAt5Kd68hHbNBXaRPD8X0+m558hx3qw@mail.gmail.com>
	<20161117213258.GA10839@1wt.eu>
Date: Thu, 17 Nov 2016 15:51:09 -0600
In-Reply-To: <20161117213258.GA10839@1wt.eu> (Willy Tarreau's message of "Thu,
	17 Nov 2016 22:32:59 +0100")
Message-ID: <874m3522sy.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an unreadable file
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Kees Cook <keescook@chromium.org>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Andy Lutomirski <luto@amacapital.net>

Willy Tarreau <w@1wt.eu> writes:

> On Thu, Nov 17, 2016 at 01:07:33PM -0800, Kees Cook wrote:
>> I'm not opposed to a sysctl for this. Regardless, I think we need to
>> embrace this idea now, though, since we'll soon end up with
>> architectures that enforce executable-only memory, in which case
>> ptrace will again fail. Almost better to get started here and then not
>> have more surprises later.
>
> Also that makes me realize that by far the largest use case of ptrace
> is strace and that strace needs very little capabilities. I guess that
> most users would be fine with having only pointers and not contents
> for addresses or read/write of data, as they have on some other OSes,
> when the process is not readable. But in my opinion when a process
> is executable we should be able to trace its execution (even without
> memory read access).

Given all of this I will respin this series with a replacement patch
that adds a permission check ion the path where ptrace calls
access_process_vm.

I avoided it because the patch is a bit larger and with full ptrace control
is much better at leaking information.  Even if you can't read the
data.  But ptrace works even if it won't give you the memory based
arguments to system calls anymore.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
