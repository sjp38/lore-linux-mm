Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id D46216B004D
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 10:47:38 -0500 (EST)
Date: Wed, 7 Mar 2012 16:47:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] ksm: clean up page_trans_compound_anon_split
Message-ID: <20120307154732.GU13462@redhat.com>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
 <alpine.LSU.2.00.1203061515470.1292@eggly.anvils>
 <20120307001148.GO13462@redhat.com>
 <20120307002616.GP13462@redhat.com>
 <CAA_GA1d1MSQVcW=pabjVj0+oOyC1OzJmyqry-bNvZ=rDeTp--w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1d1MSQVcW=pabjVj0+oOyC1OzJmyqry-bNvZ=rDeTp--w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org

Hi Bob,

On Wed, Mar 07, 2012 at 06:39:12PM +0800, Bob Liu wrote:
> Hi Andrea,
> 
> I think this patch may still break the origin meaning.
> 
> In case PageTransCompound(page) but !PageAnon(head) after this cleanup,
> page_trans_compound_anon_split(page) will return 1 instead of 0 which
> will cause following
> PageAnon check to a compounded page.

It won't check PageAnon if you return 1 in that case. Returning 1 will
bail out immediately so it's always safe (simply it would become
dangerous to call the page_trans_compound_anon_split on a page that
wasn't PageTransCompound after the cleanup). The only downside is not
a runtime one but a theoretical one: it makes the function less
generic as it errors out even for regular pages now so it must only be
called on compound pages after the cleanup (but it was already called
only for compound pages so I couldn't argue against the cleanup, but
hey I also feel like the original version was more generic).

> 
> So please just ignore this cleanup. Sorry for my noise.

No problem, ok to drop it if you also like the current semantics more.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
