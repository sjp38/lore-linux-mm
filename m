Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 618EC6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 20:25:56 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so1620929bkc.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 17:25:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com>
References: <20120607212114.E4F5AA02F8@akpm.mtv.corp.google.com> <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 7 Jun 2012 17:25:34 -0700
Message-ID: <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com>
Subject: Re: [patch 12/12] mm: correctly synchronize rss-counters at exit/exec
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: khlebnikov@openvz.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, markus@trippelsdorf.de, oleg@redhat.com, stable@vger.kernel.org

Ugh, looking more at the patch, I'm getting more and more convinces
that it is pure and utter garbage.

It does "sync_mm_rss(mm);" in mmput(), _after_ it has done the
possibly final mmdrop(). WTF?

This is crap, guys. Seriously. Stop playing russian rulette with this
code. I think we need to revert *all* of the crazy rss games, unless
Konstantin can show us some truly obviously correct fix.

Sadly, I merged and pushed out the crap before I had rebooted and
noticed this problem, so now it's in the wild. Can somebody please
take a look at this asap?

             Linus

On Thu, Jun 7, 2012 at 5:17 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> This patch actually seems to have made the
>
> =A0BUG: Bad rss-counter state ..
>
> problem *much* worse. It triggers all the time for me now - I've got
> 408 of those messages on my macbook air within a minute of booting it.
>
> Not good. Especially not good when it's marked for stable too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
