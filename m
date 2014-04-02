Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 483DD6B009A
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 20:53:54 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id j7so10188730qaq.8
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 17:53:53 -0700 (PDT)
Received: from smtp.bbn.com (smtp.bbn.com. [128.33.0.80])
        by mx.google.com with ESMTPS id gq5si135994qab.72.2014.04.01.17.53.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 17:53:52 -0700 (PDT)
Message-ID: <533B5F9C.9000003@bbn.com>
Date: Tue, 01 Apr 2014 20:53:48 -0400
From: Richard Hansen <rhansen@bbn.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
References: <533B04A9.6090405@bbn.com> <533B1439.3010403@gmail.com>
In-Reply-To: <533B1439.3010403@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-api@vger.kernel.org, Greg Troxel <gdt@ir.bbn.com>

On 2014-04-01 15:32, Michael Kerrisk (man-pages) wrote:
> Richard,
> 
> On 04/01/2014 08:25 PM, Richard Hansen wrote:
>> For the flags parameter, POSIX says "Either MS_ASYNC or MS_SYNC shall
>> be specified, but not both." [1]  There was already a test for the
>> "both" condition.  Add a test to ensure that the caller specified one
>> of the flags; fail with EINVAL if neither are specified.
>>
>> Without this change, specifying neither is the same as specifying
>> flags=MS_ASYNC because nothing in msync() is conditioned on the
>> MS_ASYNC flag.  This has not always been true, 
> 
> I am curious (since such things should be documented)--when was
> it not true?

Before commit 204ec84 [1] (in v2.6.19), specifying MS_ASYNC could
potentially follow a different code path than specifying neither
MS_ASYNC nor MS_SYNC.  I'm not familiar enough with the internals to
know what the behavioral implications were at the time.

[1]
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=204ec841fbea3e5138168edbc3a76d46747cc987

> 
>> and there's no good
>> reason to believe that this behavior would have persisted
>> indefinitely.
>>
>> The msync(2) man page (as currently written in man-pages.git) is
>> silent on the behavior if both flags are unset, so this change should
>> not break an application written by somone who carefully reads the
>> Linux man pages or the POSIX spec.
> 
> Sadly, people do not always carefully read man pages, so there
> remains the chance that a change like this will break applications.

True.  Mitigating factors:  (1) It'll only break applications that only
care about Linux, and (2) any app that does flags=0 is arguably buggy
anyway given the unspecified behavior.

> Aside from standards conformance,

Technically this change isn't required for standards conformance.  The
POSIX standard is OK with implementation extensions, so this issue could
be resolved by simply documenting that if neither MS_ASYNC nor MS_SYNC
are set then MS_ASYNC is implied.  This would preclude us from using
flags=0 for a different purpose in the future, so I'm a bit reluctant to
go this route.

(If we do go this route I'd like to see msync() modified to explicitly
set the MS_ASYNC flag if neither are set to be defensive and to
communicate intention to anyone reading the code.)

> what do you see as the benefit of the change?

  * Clarify intentions.  Looking at the code and the code history, the
    fact that flags=0 behaves like flags=MS_ASYNC appears to be a
    coincidence, not the result of an intentional choice.

  * Eliminate unclear semantics.  (What does it mean for msync() to be
    neither synchronous nor asynchronous?)

  * Force app portability:  Other operating systems (e.g., NetBSD)
    enforce POSIX, so an app developer using Linux might not notice the
    non-conformance.  This is really the app developer's problem, not
    the kernel's, but the alternatives to this patch are to stay vague
    or to commit to defaulting to MS_ASYNC, neither of which I like as
    much.

    Here is a link to a discussion on the bup mailing list about
    msync() portability.  This is the conversation that motivated this
    patch.

      http://article.gmane.org/gmane.comp.sysutils.backup.bup/3005

Note that in addition to this patch I'd like to update the msync(2) man
page to say that one of the two flags must be specified, but this commit
should go in first.

Thanks,
Richard


> 
> Thanks,
> 
> Michael
> 
> 
>> [1] http://pubs.opengroup.org/onlinepubs/9699919799/functions/msync.html
>>
>> Signed-off-by: Richard Hansen <rhansen@bbn.com>
>> Reported-by: Greg Troxel <gdt@ir.bbn.com>
>> Reviewed-by: Greg Troxel <gdt@ir.bbn.com>
>> ---
>>
>> This is a resend of:
>> http://article.gmane.org/gmane.linux.kernel/1554416
>> I didn't get any feedback from that submission, so I'm resending it
>> without changes.
>>
>>  mm/msync.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/msync.c b/mm/msync.c
>> index 632df45..472ad3e 100644
>> --- a/mm/msync.c
>> +++ b/mm/msync.c
>> @@ -42,6 +42,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t,
>> len, int, flags)
>>  		goto out;
>>  	if ((flags & MS_ASYNC) && (flags & MS_SYNC))
>>  		goto out;
>> +	if (!(flags & (MS_ASYNC | MS_SYNC)))
>> +		goto out;
>>  	error = -ENOMEM;
>>  	len = (len + ~PAGE_MASK) & PAGE_MASK;
>>  	end = start + len;
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
