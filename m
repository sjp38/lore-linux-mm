Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id AE9D66B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 17:19:32 -0500 (EST)
Received: by werl4 with SMTP id l4so2521131wer.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 14:19:31 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCH 04/11] mm: page_alloc: introduce
 alloc_contig_range()
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-5-git-send-email-m.szyprowski@samsung.com>
 <CA+K6fF6A1kPUW-2Mw5+W_QaTuLfU0_m0aMYRLOg98mFKwZOhtQ@mail.gmail.com>
Date: Tue, 17 Jan 2012 23:19:28 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v781mqwl3l0zgt@mpn-glaptop>
In-Reply-To: <CA+K6fF6A1kPUW-2Mw5+W_QaTuLfU0_m0aMYRLOg98mFKwZOhtQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, sandeep patil <psandeep.s@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave
 Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, 17 Jan 2012 22:54:28 +0100, sandeep patil <psandeep.s@gmail.com>=
 wrote:

> Marek,
>
> I am running a CMA test where I keep allocating from a CMA region as l=
ong
> as the allocation fails due to lack of space.
>
> However, I am seeing failures much before I expect them to happen.
> When the allocation fails, I see a warning coming from __alloc_contig_=
range(),
> because test_pages_isolated() returned "true".

Yeah, we are wondering ourselves about that.  Could you try cherry-picki=
ng
commit ad10eb079c97e27b4d27bc755c605226ce1625de (update migrate type on =
pcp
when isolating) from git://github.com/mina86/linux-2.6.git?  It probably=
 won't
apply cleanly but resolving the conflicts should not be hard (alternativ=
ely
you can try branch cma from the same repo but it is a work in progress a=
t the
moment).

> I tried to find out why this happened and added in a debug print insid=
e
> __test_page_isolated_in_pageblock(). Here's the resulting log ..

[...]

> From the log it looks like the warning showed up because page->private=

> is set to MIGRATE_CMA instead of MIGRATE_ISOLATED.

My understanding of that situation is that the page is on pcp list in wh=
ich
cases it's page_private is not updated.  Draining and the first patch in=

the series (and also the commit I've pointed to above) are designed to f=
ix
that but I'm unsure why they don't work all the time.

> I've also had a test case where it failed because (page_count() !=3D 0=
)



> Have you or anyone else seen this during the CMA testing?
>
> Also, could this be because we are finding a page within (start, end)
> that actually belongs to a higher order Buddy block ?

Higher order free buddy blocks are skipped in the =E2=80=9Cif (PageBuddy=
(page))=E2=80=9D
path of __test_page_isolated_in_pageblock().  Then again, now that I thi=
nk
of it, something fishy may be happening on the edges.  Moving the check
outside of __alloc_contig_migrate_range() after outer_start is calculate=
d
in alloc_contig_range() could help.  I'll take a look at it.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
