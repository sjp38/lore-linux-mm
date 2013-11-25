Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id BB5ED6B00EA
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:31:12 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so6225756pde.21
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 12:31:12 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ei3si14205235pbc.320.2013.11.25.12.31.10
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 12:31:11 -0800 (PST)
Date: Mon, 25 Nov 2013 12:31:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
Message-Id: <20131125123108.79c80eb59c2b1bc41c879d9e@linux-foundation.org>
In-Reply-To: <CAHGf_=ooNHx=2HeUDGxrZFma-6YRvL42ViDMkSOqLOffk8MVsw@mail.gmail.com>
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>
	<20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>
	<CAHGf_=ooNHx=2HeUDGxrZFma-6YRvL42ViDMkSOqLOffk8MVsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, 23 Nov 2013 15:49:08 -0500 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> >> --- a/mm/mempolicy.c
> >> +++ b/mm/mempolicy.c
> >> @@ -2950,7 +2950,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
> >>               return;
> >>       }
> >>
> >> -     p += snprintf(p, maxlen, policy_modes[mode]);
> >> +     p += snprintf(p, maxlen, "%s", policy_modes[mode]);
> >>
> >>       if (flags & MPOL_MODE_FLAGS) {
> >>               p += snprintf(p, buffer + maxlen - p, "=");
> >
> > mutter.  There are no '%'s in policy_modes[].  Maybe we should only do
> > this #ifdef CONFIG_KEES.
> >
> > mpol_to_str() would be simpler (and slower) if it was switched to use
> > strncat().
> 
> IMHO, you should queue this patch. mpol_to_str() is not fast path at all and
> I don't want worry about false positive warning.

Yup, it's in mainline.

> > It worries me that the CONFIG_NUMA=n version of mpol_to_str() doesn't
> > stick a '\0' into *buffer.  Hopefully it never gets called...
> 
> Don't worry. It never happens. Currently, all of caller depend on CONFIG_NUMA.
> However it would be nice if CONFIG_NUMA=n version of mpol_to_str() is
> implemented
> more carefully. I don't know who's mistake.

Put a BUG() in there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
