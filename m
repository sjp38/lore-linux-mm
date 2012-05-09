Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5A02B6B00FF
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:08:20 -0400 (EDT)
Message-ID: <4FAA7A51.6050504@inria.fr>
Date: Wed, 09 May 2012 16:08:17 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: mm: move_pages syscall can't return ENOENT when pages are not
 present
References: <85e08d38-234a-4bc6-8c4f-6c92b50dc9b1@zmail13.collab.prod.int.phx2.redhat.com>
In-Reply-To: <85e08d38-234a-4bc6-8c4f-6c92b50dc9b1@zmail13.collab.prod.int.phx2.redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Le 09/05/2012 10:58, Zhouping Liu a A(C)crit :
> hi, all
>
> Recently, I found an error in move_pages syscall:
>
> depending on move_pages(2), when page is not present,
> it should fail with ENOENT, in fact, it's ok without
> any errno.
>
> the following reproducer can easily reproduce
> the issue, suggest you get more details by strace.
> inside reproducer, I try to move a non-exist page from
> node 1 to node 0.
>

If I understand correctly, 3 pages should migrate properly but the last
one cannot migrate because it's not present. In this case, move_pages
returns success. -ENOENT is set in the status array, not in the return
value/errno.

In the past, if *all* pages failed to migrate, move_pages would return
ENOENT instead of success, but the behavior was inconsistent so I
changed that in commit e78bbfa8262424417a29349a8064a535053912b9 as
Wanlong Gao said. But that should not matter here since 3 pages out of 4
are successfully migrated from what I understand.

The manpage should be updated (remove ENOENT from the ERRORS section,
but keep it in the "Page states in the status array" section).

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
