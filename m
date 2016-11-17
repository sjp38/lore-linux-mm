Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 273256B037A
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:47:33 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g187so4691649itc.2
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:47:33 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id 141si211208itu.27.2016.11.17.15.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 15:47:28 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com> <87oa1eavfx.fsf_-_@xmission.com>
	<CALCETrUSnPfzpabQMNuyOu09j9QDzRDeoQVF_U51=ow3bP5pkw@mail.gmail.com>
Date: Thu, 17 Nov 2016 17:44:46 -0600
In-Reply-To: <CALCETrUSnPfzpabQMNuyOu09j9QDzRDeoQVF_U51=ow3bP5pkw@mail.gmail.com>
	(Andy Lutomirski's message of "Thu, 17 Nov 2016 15:27:09 -0800")
Message-ID: <87twb5y8lt.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH 1/3] ptrace: Capture the ptracer's creds not PT_PTRACE_CAP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@chromium.org>

Andy Lutomirski <luto@amacapital.net> writes:

> On Thu, Nov 17, 2016 at 9:05 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> When the flag PT_PTRACE_CAP was added the PTRACE_TRACEME path was
>> overlooked.  This can result in incorrect behavior when an application
>> like strace traces an exec of a setuid executable.
>>
>> Further PT_PTRACE_CAP does not have enough information for making good
>> security decisions as it does not report which user namespace the
>> capability is in.  This has already allowed one mistake through
>> insufficient granulariy.
>>
>> I found this issue when I was testing another corner case of exec and
>> discovered that I could not get strace to set PT_PTRACE_CAP even when
>> running strace as root with a full set of caps.
>>
>> This change fixes the above issue with strace allowing stracing as
>> root a setuid executable without disabling setuid.  More fundamentaly
>> this change allows what is allowable at all times, by using the correct
>> information in it's decision.
>>
>> Cc: stable@vger.kernel.org
>> Fixes: 4214e42f96d4 ("v2.4.9.11 -> v2.4.9.12")
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  fs/exec.c                  |  2 +-
>>  include/linux/capability.h |  1 +
>>  include/linux/ptrace.h     |  1 -
>>  include/linux/sched.h      |  1 +
>>  kernel/capability.c        | 20 ++++++++++++++++++++
>>  kernel/ptrace.c            | 12 +++++++-----
>>  6 files changed, 30 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/exec.c b/fs/exec.c
>> index 6fcfb3f7b137..fdec760bfac3 100644
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -1401,7 +1401,7 @@ static void check_unsafe_exec(struct linux_binprm *bprm)
>>         unsigned n_fs;
>>
>>         if (p->ptrace) {
>> -               if (p->ptrace & PT_PTRACE_CAP)
>> +               if (ptracer_capable(p, current_user_ns()))
>
> IIRC PT_PTRACE_CAP was added to prevent TOCTOU races.  What prevents
> that type of race now?  For that matter, what guarantees that we've
> already switched to new creds here and will continue to do so in the
> future?

Because instead of capturing a single bit we now capture tracers
entire credentials in tsk->ptracer_cred.   As such tsk->ptracer_cred
never changes except when ptracing begins or ends, and we remain
safe for TOCTOU races.

We do hold cred_guard_mutex here so that guarantees we get a new
ptracer.  So the worst that can happen here is our tracer detaches
and ptracer_capable will uncondintionally return true.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
