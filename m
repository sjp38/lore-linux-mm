Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C26D600762
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 15:26:04 -0500 (EST)
Received: by gxk24 with SMTP id 24so928733gxk.6
        for <linux-mm@kvack.org>; Thu, 03 Dec 2009 12:26:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0912022210220.30023@sebohet.brgvxre.pu>
References: <20091113142608.33B9.A69D9226@jp.fujitsu.com>
	 <20091113135443.GF29804@csn.ul.ie>
	 <20091114023138.3DA5.A69D9226@jp.fujitsu.com>
	 <20091113181557.GM29804@csn.ul.ie>
	 <2f11576a0911131033w4a9e6042k3349f0be290a167e@mail.gmail.com>
	 <20091113200357.GO29804@csn.ul.ie>
	 <alpine.DEB.2.00.0911261542500.21450@sebohet.brgvxre.pu>
	 <alpine.DEB.2.00.0911290834470.20857@sebohet.brgvxre.pu>
	 <20091202113241.GC1457@csn.ul.ie>
	 <alpine.DEB.2.00.0912022210220.30023@sebohet.brgvxre.pu>
Date: Thu, 3 Dec 2009 21:26:00 +0100
Message-ID: <4e5e476b0912031226i5b0e6cf9hdfd5519182ccdefa@mail.gmail.com>
Subject: Re: still getting allocation failures (was Re: [PATCH] vmscan: Stop
	kswapd waiting on congestion when the min watermark is not being met V2)
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tobias Oetiker <tobi@oetiker.ch>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Tobias,
does the patch in http://lkml.org/lkml/2009/11/30/301 help with your
high order allocation problems?
It seems that you have lot of memory, but high order pages do not show up.
The patch should make them more likely to appear.
On my machine (that has much less ram than yours), with the patch, I
always have order-10 pages available.

Corrado

On Wed, Dec 2, 2009 at 10:30 PM, Tobias Oetiker <tobi@oetiker.ch> wrote:
> Hi Mel,
>
> Today Mel Gorman wrote:
>
>> On Sun, Nov 29, 2009 at 08:42:09AM +0100, Tobi Oetiker wrote:
>> > Hi Mel,
>> >
>> > Thursday Tobias Oetiker wrote:
>> > > Hi Mel,
>> > >
>> > > Nov 13 Mel Gorman wrote:
>> > >
>> > > > The last version has a stupid bug in it. Sorry.
>> > > >
>> > > > Changelog since V1
>> > > > =C2=A0 o Fix incorrect negation
>> > > > =C2=A0 o Rename kswapd_no_congestion_wait to kswapd_skip_congestio=
n_wait as
>> > > > =C2=A0 =C2=A0 suggested by Rik
>> > > >
>> > > > If reclaim fails to make sufficient progress, the priority is rais=
ed.
>> > > > Once the priority is higher, kswapd starts waiting on congestion. =
=C2=A0However,
>> > > > if the zone is below the min watermark then kswapd needs to contin=
ue working
>> > > > without delay as there is a danger of an increased rate of GFP_ATO=
MIC
>> > > > allocation failure.
>> > > >
>> > > > This patch changes the conditions under which kswapd waits on
>> > > > congestion by only going to sleep if the min watermarks are being =
met.
>> > >
>> > > I finally got around to test this together with the whole series on
>> > > 2.6.31.6. after running it for a day I have not yet seen a single
>> > > order:5 allocation problem ... (while I had several an hour before)
>> >
>> > > for the record, my kernel is now running with the following
>> > > patches:
>> > >
>> > > patch1:Date: Thu, 12 Nov 2009 19:30:31 +0000
>> > > patch1:Subject: [PATCH 1/5] page allocator: Always wake kswapd when =
restarting an allocation attempt after direct reclaim failed
>> > >
>> > > patch2:Date: Thu, 12 Nov 2009 19:30:32 +0000
>> > > patch2:Subject: [PATCH 2/5] page allocator: Do not allow interrupts =
to use ALLOC_HARDER
>> > >
>> > > patch3:Date: Thu, 12 Nov 2009 19:30:33 +0000
>> > > patch3:Subject: [PATCH 3/5] page allocator: Wait on both sync and as=
ync congestion after direct reclaim
>> > >
>> > > patch4:Date: Thu, 12 Nov 2009 19:30:34 +0000
>> > > patch4:Subject: [PATCH 4/5] vmscan: Have kswapd sleep for a short in=
terval and double check it should be asleep
>> > >
>> > > patch5:Date: Fri, 13 Nov 2009 20:03:57 +0000
>> > > patch5:Subject: [PATCH] vmscan: Stop kswapd waiting on congestion wh=
en the min watermark is not being met V2
>> > >
>> > > patch6:Date: Tue, 17 Nov 2009 10:34:21 +0000
>> > > patch6:Subject: [PATCH] vmscan: Have kswapd sleep for a short interv=
al and double check it should be asleep fix 1
>> > >
>> > I have now been running the new kernel for a few days and I am
>> > sorry to report that about a day after booting the allocation
>> > failures started showing again. More order:4 instead of order:5 ...
>> >
>>
>> Why has the order changed?
>
> ? no idea ... the order has changed after applying the patches
> cited above.
>
>> Also, what allocator were you using in 2.6.30 and 2.6.31.6, SLAB or
>> SLUB? Did you happen to change them when upgrading the kernel?
>
> I have been and still am using SLUB =C2=A0...
>
> cheers
> tobi
>
>
> --
> Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
> http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>



--=20
__________________________________________________________________________

dott. Corrado Zoccolo                          mailto:czoccolo@gmail.com
PhD - Department of Computer Science - University of Pisa, Italy
--------------------------------------------------------------------------
The self-confidence of a warrior is not the self-confidence of the average
man. The average man seeks certainty in the eyes of the onlooker and calls
that self-confidence. The warrior seeks impeccability in his own eyes and
calls that humbleness.
                               Tales of Power - C. Castaneda

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
