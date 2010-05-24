Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 209206B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 05:57:37 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o4O9vWl6011258
	for <linux-mm@kvack.org>; Mon, 24 May 2010 02:57:32 -0700
Received: from vws3 (vws3.prod.google.com [10.241.21.131])
	by kpbe16.cbf.corp.google.com with ESMTP id o4O9vVWR022504
	for <linux-mm@kvack.org>; Mon, 24 May 2010 02:57:31 -0700
Received: by vws3 with SMTP id 3so286001vws.0
        for <linux-mm@kvack.org>; Mon, 24 May 2010 02:57:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
	<alpine.LSU.2.00.1005211344440.7369@sister.anvils>
	<AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
Date: Mon, 24 May 2010 02:57:30 -0700
Message-ID: <AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
Subject: Re: TMPFS over NFSv4
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, May 24, 2010 at 2:26 AM, Tharindu Rukshan Bamunuarachchi
<btharindu@gmail.com> wrote:
> thankx a lot Hugh ... I will try this out ... (bit harder patch
> already patched SLES kernel :-p ) ....

If patch conflicts are a problem, you really only need to put in the
two-liner patch to mm/mmap.c: Alan was seeking perfection in
the rest of the patch, but you can get away without it.

>
> BTW, what does Alan means by "strict overcommit" ?

Ah, that phrase, yes, it's a nonsense, but many of us do say it by mistake.
Alan meant to say "strict no-overcommit".

>
> e.g.
> i did not see this issues with "0 > /proc/sys/vm/overcommit_accounting"

I assume "overcommit_accounting" is either a typo for "overcommit_memory",
or SLES gives "overcommit_memory" a slightly different name.

0 means overcommit memory (let people allocate more private writable user
memory than there is actually ram+swap to back), but throw in a check against
really wild allocation requests.  1 omits even that check.

> But this happened several times with "2 > /proc/sys/vm/overcommit_accounting"

2 means account for all private writable memory and fail any allocation which
would take the system over the edge - the edge being defined roughly by
overcommit_ratio * (ram+swap)  (I expect there's a divisor needed in there!)
i.e. 2 means strict no-overcommit.

So what you see fits with what Alan was fixing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
