Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id CEFCA6B00FB
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 15:51:51 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so677949pbc.9
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:51:51 -0700 (PDT)
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
        by mx.google.com with ESMTPS id eg2si1842073pac.182.2014.04.02.12.51.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 12:51:50 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so679000pad.1
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:51:50 -0700 (PDT)
Message-ID: <533C6A51.6090305@linaro.org>
Date: Wed, 02 Apr 2014 12:51:45 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B8C2D.9010108@linaro.org> <20140402183113.GL1500@redhat.com>
In-Reply-To: <20140402183113.GL1500@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/02/2014 11:31 AM, Andrea Arcangeli wrote:
> On Tue, Apr 01, 2014 at 09:03:57PM -0700, John Stultz wrote:
>> Now... once you've chosen SIGBUS semantics, there will be folks who will
>> try to exploit the fact that we get SIGBUS on purged page access (at
>> least on the user-space side) and will try to access pages that are
>> volatile until they are purged and try to then handle the SIGBUS to fix
>> things up. Those folks exploiting that will have to be particularly
>> careful not to pass volatile data to the kernel, and if they do they'll
>> have to be smart enough to handle the EFAULT, etc. That's really all
>> their problem, because they're being clever. :)
> I'm actually working on feature that would solve the problem for the
> syscalls accessing missing volatile pages. So you'd never see a
> -EFAULT because all syscalls won't return even if they encounters a
> missing page in the volatile range dropped by the VM pressure.
>
> It's called userfaultfd. You call sys_userfaultfd(flags) and it
> connects the current mm to a pseudo filedescriptor. The filedescriptor
> works similarly to eventfd but with a different protocol.
So yea! I actually think (its been awhile now) I mentioned your work to
Taras (or maybe he mentioned it to me?), but it did seem like the
userfaltfd would be a better solution for the style of fault handling
they were thinking about. (Especially as actually handling SIGBUS and
doing something sane in a large threaded application seems very difficult).

That said, explaining volatile ranges as a concept has been difficult
enough without mixing in other new concepts :), so I'm hesitant to tie
the functionality together in until its clear the userfaultfd approach
is likely to land. But maybe I need to take a closer look at it.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
