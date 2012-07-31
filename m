Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 0EF4A6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 23:34:57 -0400 (EDT)
Received: by obhx4 with SMTP id x4so12402326obh.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 20:34:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207301425410.28838@router.home>
References: <1343411703-2720-1-git-send-email-js1304@gmail.com>
	<1343411703-2720-4-git-send-email-js1304@gmail.com>
	<alpine.DEB.2.00.1207271550190.25434@router.home>
	<CAAmzW4MdiJOaZW_b+fz1uYyj0asTCveN=24st4xKymKEvkzdgQ@mail.gmail.com>
	<alpine.DEB.2.00.1207301425410.28838@router.home>
Date: Tue, 31 Jul 2012 12:34:57 +0900
Message-ID: <CAAmzW4P6rqywK89q71DXzumREsJNGq0O4RrfdiHP2thrRSy9Gg@mail.gmail.com>
Subject: Re: [RESEND PATCH 4/4 v3] mm: fix possible incorrect return value of
 move_pages() syscall
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Brice Goglin <brice@myri.com>, Minchan Kim <minchan@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>

2012/7/31 Christoph Lameter <cl@linux.com>:
> On Sat, 28 Jul 2012, JoonSoo Kim wrote:
>
>> 2012/7/28 Christoph Lameter <cl@linux.com>:
>> > On Sat, 28 Jul 2012, Joonsoo Kim wrote:
>> >
>> >> move_pages() syscall may return success in case that
>> >> do_move_page_to_node_array return positive value which means migration failed.
>> >
>> > Nope. It only means that the migration for some pages has failed. This may
>> > still be considered successful for the app if it moves 10000 pages and one
>> > failed.
>> >
>> > This patch would break the move_pages() syscall because an error code
>> > return from do_move_pages_to_node_array() will cause the status byte for
>> > each page move to not be updated anymore. Application will not be able to
>> > tell anymore which pages were successfully moved and which are not.
>>
>> In case of returning non-zero, valid status is not required according
>> to man page.
>
> Cannot find a statement like that in the man page. The return code
> description is incorrect. It should that that is returns the number of
> pages not moved otherwise an error code (Michael please fix the manpage).

In man page, there is following statement.
"status is an array of integers that return the status of each page.  The array
only contains valid values if move_pages() did not return an error."

And current implementation of move_pages() syscall doesn't return the number
of pages not moved, just return 0 when it encounter some failed pages.
So, if u want to fix the man page, u should fix do_pages_move() first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
