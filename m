Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3776B037C
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:57:56 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so5017688itb.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 15:57:56 -0800 (PST)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id k40si3935092iod.92.2016.11.17.15.57.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 15:57:55 -0800 (PST)
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
Date: Thu, 17 Nov 2016 17:55:16 -0600
In-Reply-To: <CALCETrUvKpRCXRE+K512E_q9-o8Gzgb+3XsAzSo+ZFdgqeX-eQ@mail.gmail.com>
	(Andy Lutomirski's message of "Thu, 17 Nov 2016 15:29:43 -0800")
Message-ID: <87mvgxwtjv.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an unreadable file
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@chromium.org>

Andy Lutomirski <luto@amacapital.net> writes:

> On Thu, Nov 17, 2016 at 9:08 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> It is the reasonable expectation that if an executable file is not
>> readable there will be no way for a user without special privileges to
>> read the file.  This is enforced in ptrace_attach but if we are
>> already attached there is no enforcement if a readonly executable
>> is exec'd.
>>
>> Therefore do the simple thing and if there is a non-dumpable
>> executable that we are tracing without privilege fail to exec it.
>>
>> Fixes: v1.0
>> Cc: stable@vger.kernel.org
>> Reported-by: Andy Lutomirski <luto@amacapital.net>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  fs/exec.c | 8 +++++++-
>>  1 file changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/exec.c b/fs/exec.c
>> index fdec760bfac3..de107f74e055 100644
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -1230,6 +1230,11 @@ int flush_old_exec(struct linux_binprm * bprm)
>>  {
>>         int retval;
>>
>> +       /* Fail if the tracer can't read the executable */
>> +       if ((bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP) &&
>> +           !ptracer_capable(current, bprm->mm->user_ns))
>> +               return -EPERM;
>> +
>
> At the very least, I think that BINPRM_FLAGS_ENFORCE_NONDUMP needs to
> check capable_wrt_inode_uidgid too.  Otherwise we risk breaking:
>
> $ gcc whatever.c
> $ chmod 400 a.out
> $ strace a.out

It is an invariant that if you have caps in mm->user_ns you will
also be capable_write_inode_uidgid of all files that a process exec's.

My third patch winds up changing mm->user_ns to maintain this invariant.

It is also true that Willy convinced me while this check is trivial it
will break historic uses so I have replaced this patch with:
"ptrace: Don't allow accessing an undumpable mm.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
