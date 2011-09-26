Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9156E9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 10:55:11 -0400 (EDT)
Received: by wyf22 with SMTP id 22so6966784wyf.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 07:55:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110926142540.GE14333@redhat.com>
References: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
	<20110926112944.GC14333@redhat.com>
	<CAFPAmTQPiHU8AKnQvzMM5KiQr1GnUY+Yf8PwVC6++QK8u149Ew@mail.gmail.com>
	<CAFPAmTQbHhj8wodFEutpstXdQ6Kc2_qRV6Pe69ngHwz1erF29Q@mail.gmail.com>
	<20110926142540.GE14333@redhat.com>
Date: Mon, 26 Sep 2011 20:25:06 +0530
Message-ID: <CAFPAmTTHHk7PWeYRfTHe+g0UwDC4JGYWc8M7_RZ9_poVQGJg6w@mail.gmail.com>
Subject: Re: [patch] mm: remove sysctl to manually rescue unevictable pages
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Sep 26, 2011 at 7:55 PM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> On Mon, Sep 26, 2011 at 05:59:39PM +0530, kautuk.c @samsung.com wrote:
>> On Mon, Sep 26, 2011 at 5:40 PM, kautuk.c @samsung.com
>> <consul.kautuk@gmail.com> wrote:
>> > On Mon, Sep 26, 2011 at 4:59 PM, Johannes Weiner <jweiner@redhat.com> =
wrote:
>> >> On Sun, Sep 25, 2011 at 04:29:40PM +0530, Kautuk Consul wrote:
>> >>> write_scan_unavictable_node checks the value req returned by
>> >>> strict_strtoul and returns 1 if req is 0.
>> >>>
>> >>> However, when strict_strtoul returns 0, it means successful conversi=
on
>> >>> of buf to unsigned long.
>> >>>
>> >>> Due to this, the function was not proceeding to scan the zones for
>> >>> unevictable pages even though we write a valid value to the
>> >>> scan_unevictable_pages sys file.
>> >>
>> >> Given that there is not a real reason for this knob (anymore) and tha=
t
>> >> it apparently never really worked since the day it was introduced, ho=
w
>> >> about we just drop all that code instead?
>> >>
>> >> =A0 =A0 =A0 =A0Hannes
>> >>
>> >> ---
>> >> From: Johannes Weiner <jweiner@redhat.com>
>> >> Subject: mm: remove sysctl to manually rescue unevictable pages
>> >>
>> >> At one point, anonymous pages were supposed to go on the unevictable
>> >> list when no swap space was configured, and the idea was to manually
>> >> rescue those pages after adding swap and making them evictable again.
>> >> But nowadays, swap-backed pages on the anon LRU list are not scanned
>> >> without available swap space anyway, so there is no point in moving
>> >> them to a separate list anymore.
>> >
>> > Is this code only for anonymous pages ?
>> > It seems to look at all pages in the zone both file as well as anon.
>> >
>> >>
>> >> The manual rescue could also be used in case pages were stranded on
>> >> the unevictable list due to race conditions. =A0But the code has been
>> >> around for a while now and newly discovered bugs should be properly
>> >> reported and dealt with instead of relying on such a manual fixup.
>> >
>> > What you say seems to be all right for anon pages, but what about file
>> > pages ?
>> > I'm not sure about how this could happen, but what if some file-system=
 caused
>> > a file cache page to be set to evictable or reclaimable without
>> > actually removing
>> > that page from the unevictable list ?
>>
>> What I would like to also add is that while the transition of an anon
>> page from and
>> to the unevictable lists is straight-forward, should we make the same as=
sumption
>> about file cache pages ?
>
> We should make no assumptions if our code base is open source :-)
>
>> I am not sure about this, but could a file-system cause this kind of a p=
roblem
>> independent of the mlocking behaviour of a user-mode app ?
>
> Currently, I only see shmem and ramfs meddling with unevictability
> outside of mlock and they both look correct to me.
>
> I'd say that if a filesystem required this knob and user-intervention
> for the VM to behave correctly, it needs fixing.

Yes I agree. Otherwise that kind of defeats the overall purpose of
open-source. :)

Thanks for review and the info.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
