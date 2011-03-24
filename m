Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 797BA8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 13:35:35 -0400 (EDT)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p2OHZ6uw004636
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 10:35:06 -0700
Received: by iyf13 with SMTP id 13so263747iyf.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 10:35:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324171319.GA20182@redhat.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com> <20110322194721.B05E.A69D9226@jp.fujitsu.com>
 <20110322200945.B06D.A69D9226@jp.fujitsu.com> <20110324171319.GA20182@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Mar 2011 10:34:46 -0700
Message-ID: <AANLkTinsabm-AHTdc2X550jkAqb=TrBLfrk5CV-WEjGx@mail.gmail.com>
Subject: Re: [PATCH 5/5] x86,mm: make pagefault killable
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Mar 24, 2011 at 10:13 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>
> I am wondering, can't we set FAULT_FLAG_KILLABLE unconditionally
> but check PF_USER when we get VM_FAULT_RETRY? I mean,
>
> =A0 =A0 =A0 =A0if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(curre=
nt)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(error_code & PF_USER))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0no_context(...);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0}

I agree, we should do this.

> Probably not... but I can't find any example of in-kernel fault which
> can be broken by -EFAULT if current was killed.

There's no way that can validly break anything, since any such
codepath has to be able to handle -EFAULT for other reasons anyway.

The only issue is whether we're ok with a regular write() system call
(for example) not being atomic in the presence of a fatal signal. So
it does change semantics, but I think it changes it in a good way
(technically POSIX requires atomicity, but on the other hand,
technically POSIX also doesn't talk about the process being killed,
and writes would still be atomic for the case where they actually
return. Not to mention NFS etc where writes have never been atomic
anyway, so a program that relies on strict "all or nothing" write
behavior is fundamentally broken to begin with).

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
