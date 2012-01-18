Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id E6DEB6B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 20:45:01 -0500 (EST)
Received: by werl4 with SMTP id l4so2647629wer.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 17:45:00 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCH 04/11] mm: page_alloc: introduce
 alloc_contig_range()
References: <1325162352-24709-1-git-send-email-m.szyprowski@samsung.com>
 <1325162352-24709-5-git-send-email-m.szyprowski@samsung.com>
 <CA+K6fF6A1kPUW-2Mw5+W_QaTuLfU0_m0aMYRLOg98mFKwZOhtQ@mail.gmail.com>
 <op.v781mqwl3l0zgt@mpn-glaptop>
 <CA+K6fF64hjVBjx6NPspQSud2hkJQWzeXkceLAChPrO-k7eCF+g@mail.gmail.com>
Date: Wed, 18 Jan 2012 02:44:57 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v79a47ve3l0zgt@mpn-glaptop>
In-Reply-To: <CA+K6fF64hjVBjx6NPspQSud2hkJQWzeXkceLAChPrO-k7eCF+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sandeep patil <psandeep.s@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave
 Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

>> My understanding of that situation is that the page is on pcp list in=
 which
>> cases it's page_private is not updated.  Draining and the first patch=
 in
>> the series (and also the commit I've pointed to above) are designed t=
o fix
>> that but I'm unsure why they don't work all the time.

On Wed, 18 Jan 2012 01:46:37 +0100, sandeep patil <psandeep.s@gmail.com>=
 wrote:
> Will verify this if the page is found on the pcp list as well .

I was wondering in general if =E2=80=9C!PageBuddy(page) && !page_count(p=
age)=E2=80=9D means
page is on PCP.  From what I've seen in page_isolate.c it seems to be th=
e case.

>>> I've also had a test case where it failed because (page_count() !=3D=
 0)

> With this, when it failed the page_count() returned a value of 2.  I a=
m not
> sure why, but I will try and see If I can reproduce this.

If I'm not mistaken, page_count() !=3D 0 means the page is allocated.  I=
 can see
the following scenarios which can lead to page being allocated in when
test_pages_isolated() is called:

1. The page failed to migrate.  In this case however, the code would abo=
rt earlier.

2. The page was migrated but then allocated.  This is not possible since=

    migrated pages are freed which puts the page on MIGRATE_ISOLATE free=
list which
    guarantees that the page will not be migrated.

3. The page was removed from PCP list but with migratetype =3D=3D MIGRAT=
E_CMA.  This
    is something the first patch in the series as well as the commit I'v=
e mentioned tries
    to address so hopefully it won't be an issue any more.

4. The page was allocated from PCP list.  This may happen because draini=
ng of PCP
    list happens after IRQs are enabled in set_migratetype_isolate().  I=
 don't have
    a solution for that just yet.  One is to alter update_pcp_isolate_bl=
ock() to
    remove page from the PCP list.  I haven't looked at specifics of how=
 to implement
    this just yet.

>> Moving the check outside of __alloc_contig_migrate_range() after oute=
r_start
>> is calculated in alloc_contig_range() could help.
>
> I was going to suggest that, moving the check until after outer_start
> is calculated will definitely help IMO. I am sure I've seen a case whe=
re
>
>   page_count(page) =3D page->private =3D 0 and PageBuddy(page) was fal=
se.

Yep, I've pushed new content to my branch (git://github.com/mina86/linux=
-2.6.git cma)
and will try to get Marek to test it some time soon (I'm currently swamp=
ed with
non-Linux related work myself).

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
