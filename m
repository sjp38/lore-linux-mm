Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2456B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 07:59:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so1466706wmw.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:59:01 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 19si15153463wmq.119.2016.04.28.04.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 04:59:00 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e201so22664123wme.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:59:00 -0700 (PDT)
Date: Thu, 28 Apr 2016 13:58:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Confusing olddefault prompt for Z3FOLD
Message-ID: <20160428115858.GE31489@dhcp22.suse.cz>
References: <9459.1461686910@turing-police.cc.vt.edu>
 <20160427123139.GA2230@dhcp22.suse.cz>
 <CAMJBoFPWNx6UTqyw1XF46fZYNi=nBjHXNdWz+SDokqG3xEkjAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFPWNx6UTqyw1XF46fZYNi=nBjHXNdWz+SDokqG3xEkjAA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu 28-04-16 13:35:45, Vitaly Wool wrote:
> On Wed, Apr 27, 2016 at 2:31 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 26-04-16 12:08:30, Valdis Kletnieks wrote:
> >> Saw this duplicate prompt text in today's linux-next in a 'make oldconfig':
> >>
> >> Low density storage for compressed pages (ZBUD) [Y/n/m/?] y
> >> Low density storage for compressed pages (Z3FOLD) [N/m/y/?] (NEW) ?
> >>
> >> I had to read the help texts for both before I clued in that one used
> >> two compressed pages, and the other used 3.
> >>
> >> And 'make oldconfig' doesn't have a "Wait, what?" option to go back
> >> to a previous prompt....
> >>
> >> (Change Z3FOLD prompt to "New low density" or something? )
> >
> > Or even better can we only a single one rather than 2 algorithms doing
> > the similar thing? I wasn't following this closely but what is the
> > difference to have them both?
> 
> The v3 version of z3fold doesn't claim itself to be a low density storage :)
> The reasons to have them both are listed in [1] and mentioned in [2].
> 
Thanks for the pointer!

> [1] https://lkml.org/lkml/2016/4/25/526

> * zbud is 30% less object code

This sounds like a lot but in fact:
   text    data     bss     dec     hex filename
   2063     104       8    2175     87f mm/zbud.o
   3467     104       8    3579     dfb mm/z3fold.o

Does this difference actually matter for somebody to not use z3fold if
the overal savings in the compressed memory are better? I also suspect
that even small configs might not save too much because of the internal
fragmentation.

> * some system configurations might break if we removed zbud

Why would they break? Are the two incompatible? Or to be more specific
what should be the criteria to chose one over the other?

> * zbud exports its own API while z3fold is designed to work via zpool

$ git grep EXPORT mm/zbud.c include/linux/zbud.h
$

So the API can be used only from the kernel, right? I haven't checked
users but why does the API actually matters.

Or is there any other API I have missed.

> * limiting the amount of zpool users doesn't make much sense to me,
>   after all :)

I am not sure I understand this part. Could you be more specific?

Just to clarify I am not opposing an idea of a new page compressing
algorithm. I just think that the config space in this area is way to
large and confusing. One has the scratch his head to find out what to
enable and for what reasons. The config help text didn't tell me which
is suitable for which kind of workload. All I can tell from it is that I
want 3 pages compressed rather than 2 so why bother having both of them?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
