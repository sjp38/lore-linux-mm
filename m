Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C56546B046C
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 13:58:57 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so147763567pfk.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 10:58:57 -0800 (PST)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id f17si9378284pgi.11.2016.11.18.10.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 10:58:56 -0800 (PST)
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
	<CAGXu5jKbVkCGVSoxNQ=pTCBX1Boe3rPR1P56P-kR9AHWYHBs2w@mail.gmail.com>
Date: Fri, 18 Nov 2016 12:56:15 -0600
In-Reply-To: <CAGXu5jKbVkCGVSoxNQ=pTCBX1Boe3rPR1P56P-kR9AHWYHBs2w@mail.gmail.com>
	(Kees Cook's message of "Thu, 17 Nov 2016 15:14:22 -0800")
Message-ID: <87y40gpqgg.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH 1/3] ptrace: Capture the ptracer's creds not PT_PTRACE_CAP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>

Kees Cook <keescook@chromium.org> writes:

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
>> [...]
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index 348f51b0ec92..8fe58255d219 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1656,6 +1656,7 @@ struct task_struct {
>>         struct list_head cpu_timers[3];
>>
>>  /* process credentials */
>> +       const struct cred __rcu *ptracer_cred; /* Tracer's dredentials at attach */
>
> Typo: credentials.

Thank you, fixed.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
