Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id C39066B013D
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 19:45:06 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id r5so1062251qcx.32
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 16:45:06 -0700 (PDT)
Received: from smtp.bbn.com (smtp.bbn.com. [128.33.1.81])
        by mx.google.com with ESMTPS id j30si1471531qge.58.2014.04.02.16.45.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 16:45:06 -0700 (PDT)
Message-ID: <533CA0F6.2070100@bbn.com>
Date: Wed, 02 Apr 2014 19:44:54 -0400
From: Richard Hansen <rhansen@bbn.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
References: <533B04A9.6090405@bbn.com>	 <20140402111032.GA27551@infradead.org> <1396439119.2726.29.camel@menhir>
In-Reply-To: <1396439119.2726.29.camel@menhir>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>, Christoph Hellwig <hch@infradead.org>, mtk.manpages@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Greg Troxel <gdt@ir.bbn.com>

On 2014-04-02 07:45, Steven Whitehouse wrote:
> Hi,
> 
> On Wed, 2014-04-02 at 04:10 -0700, Christoph Hellwig wrote:
>> On Tue, Apr 01, 2014 at 02:25:45PM -0400, Richard Hansen wrote:
>>> For the flags parameter, POSIX says "Either MS_ASYNC or MS_SYNC shall
>>> be specified, but not both." [1]  There was already a test for the
>>> "both" condition.  Add a test to ensure that the caller specified one
>>> of the flags; fail with EINVAL if neither are specified.
>>
>> This breaks various (sloppy) existing userspace 

Agreed, but this shouldn't be a strong consideration.  The kernel should
let userspace apps worry about their own bugs, not provide crutches.

>> for no gain.

I disagree.  Here is what we gain from this patch (expanded from my
previous email):

  * Clearer intentions.  Looking at the existing code and the code
    history, the fact that flags=0 behaves like flags=MS_ASYNC appears
    to be a coincidence, not the result of an intentional choice.

  * Clearer semantics.  What does it mean for msync() to be neither
    synchronous nor asynchronous?

  * Met expectations.  An average reader of the POSIX spec or the
    Linux man page would expect msync() to fail if neither flag is
    specified.

  * Defense against potential future security vulnerabilities.  By
    explicitly requiring one of the flags, a future change to msync()
    is less likely to expose an unintended code path to userspace.

  * flags=0 is reserved.  By making it illegal to omit both flags
    we have the option of making it legal in the future for some
    expanded purpose.  (Unlikely, but still.)

  * Forced app portability.  Other operating systems (e.g., NetBSD)
    enforce POSIX, so an app developer using Linux might not notice the
    non-conformance.  This is really the app developer's problem, not
    the kernel's, but it's worth considering given msync()'s behavior
    is currently unspecified.

    Here is a link to a discussion on the bup mailing list about
    msync() portability.  This is the conversation that motivated this
    patch.

      http://article.gmane.org/gmane.comp.sysutils.backup.bup/3005

Alternatives:

  * Do nothing.  Leave the behavior of flags=0 unspecified and let
    sloppy userspace continue to be sloppy.  Easiest, but the intended
    behavior remains unclear and it risks unintended behavior changes
    the next time msync() is overhauled.

  * Leave msync()'s current behavior alone, but document that MS_ASYNC
    is the default if neither is specified.  This is backward-
    compatible with sloppy userspace, but encourages non-portable uses
    of msync() and would preclude using flags=0 for some other future
    purpose.

  * Change the default to MS_SYNC and document this.  This is perhaps
    the most conservative option, but it alters the behavior of existing
    sloppy userspace and also has the disadvantages of the previous
    alternative.

Overall, I believe the advantages of this patch outweigh the
disadvantages, given the alternatives.

Perhaps I should include the above bullets in the commit message.

>>
>> NAK.
>>
> Agreed. It might be better to have something like:
> 
> if (flags == 0)
> 	flags = MS_SYNC;
> 
> That way applications which don't set the flags (and possibly also don't
> check the return value, so will not notice an error return) will get the
> sync they desire. Not that either of those things is desirable, but at
> least we can make the best of the situation. Probably better to be slow
> than to potentially lose someone's data in this case,

This is a conservative alternative, but I'd rather not condone flags=0.
 Other than compatibility with broken apps, there is little value in
supporting flags=0.  Portable apps will have to specify one of the flags
anyway, and the behavior of flags=0 is already accessible via other means.

Thanks,
Richard


> 
> Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
