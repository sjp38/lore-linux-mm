Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2A3A16B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 19:47:20 -0500 (EST)
Received: by bkbzx1 with SMTP id zx1so1543892bkb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 16:47:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v781mqwl3l0zgt@mpn-glaptop>
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-5-git-send-email-m.szyprowski@samsung.com>
 <CA+K6fF6A1kPUW-2Mw5+W_QaTuLfU0_m0aMYRLOg98mFKwZOhtQ@mail.gmail.com> <op.v781mqwl3l0zgt@mpn-glaptop>
From: sandeep patil <psandeep.s@gmail.com>
Date: Tue, 17 Jan 2012 16:46:37 -0800
Message-ID: <CA+K6fF64hjVBjx6NPspQSud2hkJQWzeXkceLAChPrO-k7eCF+g@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 04/11] mm: page_alloc: introduce alloc_contig_range()
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> Yeah, we are wondering ourselves about that. =A0Could you try cherry-pick=
ing
> commit ad10eb079c97e27b4d27bc755c605226ce1625de (update migrate type on p=
cp
> when isolating) from git://github.com/mina86/linux-2.6.git? =A0It probabl=
y
> won't
> apply cleanly but resolving the conflicts should not be hard (alternative=
ly
> you can try branch cma from the same repo but it is a work in progress at
> the
> moment).
>

I'll try this patch and report back ,,


>> is set to MIGRATE_CMA instead of MIGRATE_ISOLATED.
>
>
> My understanding of that situation is that the page is on pcp list in whi=
ch
> cases it's page_private is not updated. =A0Draining and the first patch i=
n
> the series (and also the commit I've pointed to above) are designed to fi=
x
> that but I'm unsure why they don't work all the time.
>
>

Will verify this if the page is found on the pcp list as well .

>> I've also had a test case where it failed because (page_count() !=3D 0)

With this, when it failed the page_count()
returned a value of 2. I am not sure why, but I will try and see If I can
reproduce this.

>
>
>> Have you or anyone else seen this during the CMA testing?
>>
>> Also, could this be because we are finding a page within (start, end)
>> that actually belongs to a higher order Buddy block ?
>
>
> Higher order free buddy blocks are skipped in the =93if (PageBuddy(page))=
=94
> path of __test_page_isolated_in_pageblock(). =A0Then again, now that I th=
ink
> of it, something fishy may be happening on the edges. =A0Moving the check
> outside of __alloc_contig_migrate_range() after outer_start is calculated
> in alloc_contig_range() could help. =A0I'll take a look at it.

I was going to suggest that, moving the check until after outer_start
is calculated
will definitely help IMO. I am sure I've seen a case where

  page_count(page) =3D page->private =3D 0 and PageBuddy(page) was false.

I will try and reproduce this as well.

Thanks,
Sandeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
