Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id E23556B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 03:13:08 -0400 (EDT)
Received: by mail-bk0-f45.google.com with SMTP id na10so255547bkb.32
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 00:13:08 -0700 (PDT)
Received: from mail-bk0-x22f.google.com (mail-bk0-x22f.google.com [2a00:1450:4008:c01::22f])
        by mx.google.com with ESMTPS id py8si3077083bkb.26.2014.04.04.00.13.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Apr 2014 00:13:07 -0700 (PDT)
Received: by mail-bk0-f47.google.com with SMTP id w10so246297bkz.6
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 00:13:07 -0700 (PDT)
Message-ID: <533E5B7A.7030309@gmail.com>
Date: Fri, 04 Apr 2014 09:12:58 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Reply-To: mtk.manpages@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC [resend]
References: <533B04A9.6090405@bbn.com> <20140402111032.GA27551@infradead.org> <1396439119.2726.29.camel@menhir> <533CA0F6.2070100@bbn.com>
In-Reply-To: <533CA0F6.2070100@bbn.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Hansen <rhansen@bbn.com>
Cc: mtk.manpages@gmail.com, Steven Whitehouse <swhiteho@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Troxel <gdt@ir.bbn.com>, Peter Zijlstra <peterz@infradead.org>, bug-readline@gnu.org

[Resending this message from yesterday, since, as Richard Hansen
pointed out, I failed to CC bug-readline@] 

[CC += Peter Zijlstra]
[CC += bug-readline@gnu.org -- maintainers, it _may_ be desirable to
fix your msync() call]

Richard,

On Thu, Apr 3, 2014 at 1:44 AM, Richard Hansen <rhansen@bbn.com> wrote:
> On 2014-04-02 07:45, Steven Whitehouse wrote:
>> Hi,
>>
>> On Wed, 2014-04-02 at 04:10 -0700, Christoph Hellwig wrote:
>>> On Tue, Apr 01, 2014 at 02:25:45PM -0400, Richard Hansen wrote:
>>>> For the flags parameter, POSIX says "Either MS_ASYNC or MS_SYNC shall
>>>> be specified, but not both." [1]  There was already a test for the
>>>> "both" condition.  Add a test to ensure that the caller specified one
>>>> of the flags; fail with EINVAL if neither are specified.
>>>
>>> This breaks various (sloppy) existing userspace
>
> Agreed, but this shouldn't be a strong consideration.  The kernel should
> let userspace apps worry about their own bugs, not provide crutches.
>
>>> for no gain.
>
> I disagree.  Here is what we gain from this patch (expanded from my
> previous email):
>
>   * Clearer intentions.  Looking at the existing code and the code
>     history, the fact that flags=0 behaves like flags=MS_ASYNC appears
>     to be a coincidence, not the result of an intentional choice.

Maybe. You earlier asserted that the semantics when flags==0 may have
been different, prior to Peter Zijstra's patch,
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=204ec841fbea3e5138168edbc3a76d46747cc987
.
It's not clear to me that that is the case. But, it would be wise to
CC the developer, in case he has an insight.

>   * Clearer semantics.  What does it mean for msync() to be neither
>     synchronous nor asynchronous?
>
>   * Met expectations.  An average reader of the POSIX spec or the
>     Linux man page would expect msync() to fail if neither flag is
>     specified.
>
>   * Defense against potential future security vulnerabilities.  By
>     explicitly requiring one of the flags, a future change to msync()
>     is less likely to expose an unintended code path to userspace.
>
>   * flags=0 is reserved.  By making it illegal to omit both flags
>     we have the option of making it legal in the future for some
>     expanded purpose.  (Unlikely, but still.)
>
>   * Forced app portability.  Other operating systems (e.g., NetBSD)
>     enforce POSIX, so an app developer using Linux might not notice the
>     non-conformance.  This is really the app developer's problem, not
>     the kernel's, but it's worth considering given msync()'s behavior
>     is currently unspecified.

There is no doubt that the situation on Linux is an unfortunate mess
from history (and is far from the only one, see
https://lwn.net/Articles/588444/).

And I think everyone would agree that all of the above would be nice
to have, if there was no cost to having them. But, there is a major
cost: the pain of breaking those sloppy user-space applications. And
in fact some casual grepping suggests that many applications would
break, since, for example, libreadline contains (in histfile.c) an
msync() call that omits both MS_SYNC and MS_ASYNC (I have not looked
into the details of what that piece of code does).

But, even if you could find and fix every application that misuses
msync(), new kernels with your proposed changes would still break old
binaries. Linus has made it clear on numerous occasions that kernel
changes must not break user space. So, the change you suggest is never
going to fly (and Christoph's NAK at least saves Linus yelling at you
;-).)

>     Here is a link to a discussion on the bup mailing list about
>     msync() portability.  This is the conversation that motivated this
>     patch.
>
>       http://article.gmane.org/gmane.comp.sysutils.backup.bup/3005
>
> Alternatives:
>
>   * Do nothing.  Leave the behavior of flags=0 unspecified and let
>     sloppy userspace continue to be sloppy.  Easiest, but the intended
>     behavior remains unclear and it risks unintended behavior changes
>     the next time msync() is overhauled.
>
>   * Leave msync()'s current behavior alone, but document that MS_ASYNC
>     is the default if neither is specified.  This is backward-
>     compatible with sloppy userspace, but encourages non-portable uses
>     of msync() and would preclude using flags=0 for some other future
>     purpose.
>
>   * Change the default to MS_SYNC and document this.  This is perhaps
>     the most conservative option, but it alters the behavior of existing
>     sloppy userspace and also has the disadvantages of the previous
>     alternative.
>
> Overall, I believe the advantages of this patch outweigh the
> disadvantages, given the alternatives.

I think the only reasonable solution is to better document existing
behavior and what the programmer should do. With that in mind, I've
drafted the following text for the msync(2) man page:

    NOTES
       According to POSIX, exactly one of MS_SYNC and MS_ASYNC  must  be
       specified  in  flags.   However,  Linux permits a call to msync()
       that specifies neither of these flags, with  semantics  that  are
       (currently)  equivalent  to  specifying  MS_ASYNC.   (Since Linux
       2.6.19, MS_ASYNC is in fact a no-op, since  the  kernel  properly
       tracks  dirty  pages  and  flushes them to storage as necessary.)
       Notwithstanding the Linux behavior, portable, future-proof applia??
       cations  should  ensure  that they specify exactly one of MS_SYNC
       and MS_ASYNC in flags.

Comments on this draft welcome.

Cheers,

Michael


> Perhaps I should include the above bullets in the commit message.
>
>>>
>>> NAK.
>>>
>> Agreed. It might be better to have something like:
>>
>> if (flags == 0)
>>       flags = MS_SYNC;
>>
>> That way applications which don't set the flags (and possibly also don't
>> check the return value, so will not notice an error return) will get the
>> sync they desire. Not that either of those things is desirable, but at
>> least we can make the best of the situation. Probably better to be slow
>> than to potentially lose someone's data in this case,
>
> This is a conservative alternative, but I'd rather not condone flags=0.
>  Other than compatibility with broken apps, there is little value in
> supporting flags=0.  Portable apps will have to specify one of the flags
> anyway, and the behavior of flags=0 is already accessible via other means.
>
> Thanks,
> Richard
>
>
>>
>> Steve.

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
