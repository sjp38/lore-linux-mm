Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CB1086B002D
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 21:00:38 -0400 (EDT)
Received: by ywa17 with SMTP id 17so3069855ywa.14
        for <linux-mm@kvack.org>; Sun, 23 Oct 2011 18:00:36 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-3-git-send-email-m.szyprowski@samsung.com>
 <20111018122109.GB6660@csn.ul.ie> <op.v3j5ent03l0zgt@mpn-glaptop>
 <20111021100624.GB4029@csn.ul.ie>
Date: Sun, 23 Oct 2011 18:00:30 -0700
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v3tzq4q53l0zgt@mpn-glaptop>
In-Reply-To: <20111021100624.GB4029@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse
 Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri, 21 Oct 2011 03:06:24 -0700, Mel Gorman <mel@csn.ul.ie> wrote:

> On Tue, Oct 18, 2011 at 10:26:37AM -0700, Michal Nazarewicz wrote:
>> On Tue, 18 Oct 2011 05:21:09 -0700, Mel Gorman <mel@csn.ul.ie> wrote:=

>>
>> >At this point, I'm going to apologise for not reviewing this a long =
long
>> >time ago.
>> >
>> >On Thu, Oct 06, 2011 at 03:54:42PM +0200, Marek Szyprowski wrote:
>> >>From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >>
>> >>This commit introduces alloc_contig_freed_pages() function
>> >>which allocates (ie. removes from buddy system) free pages
>> >>in range. Caller has to guarantee that all pages in range
>> >>are in buddy system.
>> >>
>> >
>> >Straight away, I'm wondering why you didn't use
>> >
>> >mm/compaction.c#isolate_freepages()
>> >
>> >It knows how to isolate pages within ranges. All its control informa=
tion
>> >is passed via struct compact_control() which I recognise may be awkw=
ard
>> >for CMA but compaction.c know how to manage all the isolated pages a=
nd
>> >pass them to migrate.c appropriately.
>>
>> It is something to consider.  At first glance, I see that isolate_fre=
epages
>> seem to operate on pageblocks which is not desired for CMA.
>>
>
> isolate_freepages_block operates on a range of pages that happens to b=
e
> hard-coded to be a pageblock because that was the requirements. It cal=
culates
> end_pfn and it is possible to make that a function parameter.

Yes, this seems doable.  I'll try and rewrite the patches to use it.

The biggest difference is in how CMA and compaction treat pages which ar=
e not
free.  CMA treat it as an error and compaction just skips those.  This i=
s
solvable by an argument though.

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
