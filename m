Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F35866B0386
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 19:38:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so227479530pgc.2
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:38:37 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id 127si5286474pgg.233.2016.11.17.16.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 16:38:37 -0800 (PST)
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
	<87twb6avk8.fsf_-_@xmission.com> <87inrmavax.fsf_-_@xmission.com>
	<CALCETrUvKpRCXRE+K512E_q9-o8Gzgb+3XsAzSo+ZFdgqeX-eQ@mail.gmail.com>
	<87mvgxwtjv.fsf@xmission.com>
	<CALCETrX=61Sk9qim+Psjn83gohuizEsrpUC9gF-vwQTtR4GuJw@mail.gmail.com>
Date: Thu, 17 Nov 2016 18:35:57 -0600
In-Reply-To: <CALCETrX=61Sk9qim+Psjn83gohuizEsrpUC9gF-vwQTtR4GuJw@mail.gmail.com>
	(Andy Lutomirski's message of "Thu, 17 Nov 2016 16:10:47 -0800")
Message-ID: <87shqpvd3m.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an unreadable file
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@chromium.org>

Andy Lutomirski <luto@amacapital.net> writes:

> On Thu, Nov 17, 2016 at 3:55 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Andy Lutomirski <luto@amacapital.net> writes:
>>
>>> On Thu, Nov 17, 2016 at 9:08 AM, Eric W. Biederman
>>> <ebiederm@xmission.com> wrote:
>>>>
>>>> It is the reasonable expectation that if an executable file is not
>>>> readable there will be no way for a user without special privileges to
>>>> read the file.  This is enforced in ptrace_attach but if we are
>>>> already attached there is no enforcement if a readonly executable
>>>> is exec'd.
>>>>
>>>> Therefore do the simple thing and if there is a non-dumpable
>>>> executable that we are tracing without privilege fail to exec it.
>>>>
>>>> Fixes: v1.0
>>>> Cc: stable@vger.kernel.org
>>>> Reported-by: Andy Lutomirski <luto@amacapital.net>
>>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>>> ---
>>>>  fs/exec.c | 8 +++++++-
>>>>  1 file changed, 7 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/fs/exec.c b/fs/exec.c
>>>> index fdec760bfac3..de107f74e055 100644
>>>> --- a/fs/exec.c
>>>> +++ b/fs/exec.c
>>>> @@ -1230,6 +1230,11 @@ int flush_old_exec(struct linux_binprm * bprm)
>>>>  {
>>>>         int retval;
>>>>
>>>> +       /* Fail if the tracer can't read the executable */
>>>> +       if ((bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP) &&
>>>> +           !ptracer_capable(current, bprm->mm->user_ns))
>>>> +               return -EPERM;
>>>> +
>>>
>>> At the very least, I think that BINPRM_FLAGS_ENFORCE_NONDUMP needs to
>>> check capable_wrt_inode_uidgid too.  Otherwise we risk breaking:
>>>
>>> $ gcc whatever.c
>>> $ chmod 400 a.out
>>> $ strace a.out
>>
>> It is an invariant that if you have caps in mm->user_ns you will
>> also be capable_write_inode_uidgid of all files that a process exec's.
>
> I meant to check whether you *are* the owner, too.

I don't follow.  BINPRM_FLAGS_ENFORCE_NONDUMP is only set if
the caller of exec does not have inode_permission(inode, MAY_READ).

Which in your example would have guaranteed that
BINPRM_FLAGS_ENFORCE_NONDUMP would have be unset.

The ptracer_capable thing is only asking in this instance if we can
ignore the nondumpable status because we have CAP_SYS_PTRACE over
a user namespace that includes all of the files that would_dump
was called on (mm->user_ns).

ptrace_access_vm in the replacement patch has essentially the same
permission check.  It is just at PTRACE_PEEKTEXT, PTRACE_PEEKDATA,
PTRACE_POKETEXT, or PTRACE_POKEDATA time.

So I am curious if you are seeing something that is worth fixing.

>> My third patch winds up changing mm->user_ns to maintain this invariant.
>>
>> It is also true that Willy convinced me while this check is trivial it
>> will break historic uses so I have replaced this patch with:
>> "ptrace: Don't allow accessing an undumpable mm.
>
> I think that's better.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
