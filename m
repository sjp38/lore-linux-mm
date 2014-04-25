Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id F335B6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 23:03:13 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id id10so4113642vcb.12
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 20:03:13 -0700 (PDT)
Received: from mail-ve0-x22c.google.com (mail-ve0-x22c.google.com [2607:f8b0:400c:c01::22c])
        by mx.google.com with ESMTPS id xv9si1416584vcb.80.2014.04.24.20.03.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 20:03:13 -0700 (PDT)
Received: by mail-ve0-f172.google.com with SMTP id jx11so3996299veb.17
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 20:03:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5359CD7C.5020604@zytor.com>
References: <53558507.9050703@zytor.com>
	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
	<53559F48.8040808@intel.com>
	<CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
	<20140422075459.GD11182@twins.programming.kicks-ass.net>
	<CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
	<alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
	<20140423184145.GH17824@quack.suse.cz>
	<CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
	<20140424065133.GX26782@laptop.programming.kicks-ass.net>
	<alpine.LSU.2.11.1404241110160.2443@eggly.anvils>
	<CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
	<alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
	<CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
	<1398389846.8437.6.camel@pasglop>
	<1398393700.8437.22.camel@pasglop>
	<CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
	<5359CD7C.5020604@zytor.com>
Date: Thu, 24 Apr 2014 20:03:12 -0700
Message-ID: <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
Subject: Re: Dirty/Access bits vs. page content
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Thu, Apr 24, 2014 at 7:50 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>
> The cases where they occur the mappings tend to be highly stable, i.e.
> map once *specifically* to be able to do a whole bunch of things without
> system calls, and then unmap when done.

Yes. But even that tends to be unusual. mmap() really is bad at
writing, since you inevitably get read-modify-write patterns etc. So
it's only useful for fixing up things after-the-fact, which in itself
is a horrible pattern.

Don't get me wrong - it exists, but it's really quite rare because it
has so many problems. Even people who do "fixup" kind of stuff tend to
map things privately, change things, and then write out the end
result. That way you can get atomicity by then doing a single
"rename()" at the end, for example.

The traditional case for it used to be the nntp index, and these days
I know some imap indexer (dovecot?) uses it. Every other example of it
I have ever seen has been a VM stress tester..

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
