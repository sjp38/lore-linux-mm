Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1B4738D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 08:42:42 -0400 (EDT)
Date: Mon, 21 Mar 2011 13:42:03 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: sysfs interface to transparent hugepages
Message-ID: <20110321124203.GB5719@random.random>
References: <1300676431.26693.317.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1300676431.26693.317.camel@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Mon, Mar 21, 2011 at 03:00:31AM +0000, Ben Hutchings wrote:
> This kind of cute format:
> 
>        if (test_bit(enabled, &transparent_hugepage_flags)) {
>                VM_BUG_ON(test_bit(req_madv, &transparent_hugepage_flags));
>                return sprintf(buf, "[always] madvise never\n");
>        } else if (test_bit(req_madv, &transparent_hugepage_flags))
>                return sprintf(buf, "always [madvise] never\n");
>        else
>                return sprintf(buf, "always madvise [never]\n");
> 
> is probably nice for a kernel developer or experimental user poking
> around in sysfs.  But sysfs is mostly meant for programs to read and
> write, and this format is unnecessarily complex for a program to parse.
> 
> Please use separate attributes for the current value and available
> values, like cpufreq does.  I know there are other examples of the above
> format, but not everything already in sysfs is a *good* example!

Well I liked the io scheduler format the most as you may have guessed:

noop deadline [cfq] 

so I used exactly that format... I didn't invent it. I found that the
most intuitive and simpler so you deal with a single file, it's faster
and more intuitive to use when you're on the shell and you twiddle
with the values. You simply cannot get it wrong.

> This, on the other hand, is totally ridiculous:
> 
>        if (test_bit(flag, &transparent_hugepage_flags))
>                return sprintf(buf, "[yes] no\n");
>        else
>                return sprintf(buf, "yes [no]\n");
> 
> Why show the possible values of a boolean?  I can't even find any
> examples of 'yes' and 'no' rather than '1' and '0'.

As said I like that format and I've been consistent in using it. If
you write a parser for that format in userland it's probably easier to
be consistent. Anyway this got into 2.6.38 only. For other kernels
that shipped THP before 2.6.38 there is no
/sys/kernel/mm/transparent_hugepage directory at all (it's renamed
exactly to avoid any risk of sysfs ABI clashes). I doubt anybody wrote
any parser for /sys/kernel/mm/transparent_hugepage so if this is a big
deal I suggest you send patches to whatever you prefer. Or if you tell
me exactly how you want it, I can try to implement it and if others
agree I don't see a problem in altering it. But others may
disagree. Clearly best would have been if you requested a change
during 2.6.38-rc, everyone was aware of the format as everyone has
been twiddling with these sysfs controls. Comments welcome.

> And really, why add boolean flags for a tristate at all?

I don't get the question sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
