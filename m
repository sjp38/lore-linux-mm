Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id CD00F6B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 03:34:21 -0400 (EDT)
From: "Luca Porzio (lporzio)" <lporzio@micron.com>
Subject: RE: swap on eMMC and other flash
Date: Fri, 27 Apr 2012 07:34:09 +0000
Message-ID: <26E7A31274623843B0E8CF86148BFE326FB66E94@NTXAVZMBX04.azit.micron.com>
References: <201203301744.16762.arnd@arndb.de>
	<201204100832.52093.arnd@arndb.de>	<20120411095418.GA2228@barrios>
	<201204111557.14153.arnd@arndb.de>
 <CAKL-ytsXbe4=u94PjqvhZo=ZLiChQ0FmZC84GNrFHa0N1mDjFw@mail.gmail.com>
In-Reply-To: <CAKL-ytsXbe4=u94PjqvhZo=ZLiChQ0FmZC84GNrFHa0N1mDjFw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephan Uphoff <ups@google.com>, Arnd Bergmann <arnd@arndb.de>
Cc: Minchan Kim <minchan@kernel.org>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "android-kernel@googlegroups.com" <android-kernel@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alex Lemberg <alex.lemberg@sandisk.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>

Stephan,

Good ideas. Some comments of mine below.

> -----Original Message-----
> From: linux-mmc-owner@vger.kernel.org [mailto:linux-mmc-owner@vger.kernel=
.org]
> On Behalf Of Stephan Uphoff
> Sent: Tuesday, April 17, 2012 3:22 AM
> To: Arnd Bergmann
> Cc: Minchan Kim; linaro-kernel@lists.linaro.org; android-
> kernel@googlegroups.com; linux-mm@kvack.org; Luca Porzio (lporzio); Alex
> Lemberg; linux-kernel@vger.kernel.org; Saugata Das; Venkatraman S; Yejin =
Moon;
> Hyojin Jeong; linux-mmc@vger.kernel.org
> Subject: Re: swap on eMMC and other flash
>=20
> I really like where this is going and would like to use the
> opportunity to plant a few ideas.
>=20
> In contrast to rotational disks read/write operation overhead and
> costs are not symmetric.
> While random reads are much faster on flash - the number of write
> operations is limited by wearout and garbage collection overhead.
> To further improve swapping on eMMC or similar flash media I believe
> that the following issues need to be addressed:
>=20
> 1) Limit average write bandwidth to eMMC to a configurable level to
> guarantee a minimum device lifetime
> 2) Aim for a low write amplification factor to maximize useable write
> bandwidth
> 3) Strongly favor read over write operations
>=20
> Lowering write amplification (2) has been discussed in this email
> thread - and the only observation I would like to add is that
> over-provisioning the internal swap space compared to the exported
> swap space significantly can guarantee a lower write amplification
> factor with the indirection and GC techniques discussed.
>=20
> I believe the swap functionality is currently optimized for storage
> media where read and write costs are nearly identical.
> As this is not the case on flash I propose splitting the anonymous
> inactive queue (at least conceptually) - keeping clean anonymous pages
> with swap slots on a separate queue as the cost of swapping them
> out/in is only an inexpensive read operation. A variable similar to
> swapiness (or a more dynamic algorithmn) could determine the
> preference for swapping out clean pages or dirty pages. ( A similar
> argument could be made for splitting up the file inactive queue )
>=20

I totally agree. Read are inexpensive on flash based devices and as such a =
good swap algorithm (as well as a flash oriented FS) should take this into =
account.

> The problem of limiting the average write bandwidth reminds me of
> enforcing cpu utilization limits on interactive workloads.
> Just as with cpu workloads - using the resources to the limit produces
> poor interactivity.

I don't quite get your definition of interactive workload and I am not sure=
 here which is the technique for limiting resource utilization you have in =
mind.
CGroups, for example, have proven not to be much reliable through time.=20
Also in my experience it has always been very difficult to correlate resour=
ces utilization stats with user interactivity.
The only technique which has been proven reliable through time is to do som=
ething while the system is idle, which is what, to my understanding, is alr=
eady done.

> When interactivity suffers too much I believe the only sane response
> for an interactive device is to limit usage of the swap device and
> transition into a low memory situation - and if needed - either
> allowing userspace to reduce memory usage or invoking the OOM killer.
> As a result low memory situations could not only be encountered on new
> memory allocations but also on workload changes that increase the
> number of dirty pages.
>=20

I agree with your comments about the OOM killer (what is the point of swapp=
ing out a page if that process is going to be killed soon? That is only inc=
reasing the WAF factor on MMCs). In fact one proposal here could be to some=
what mix OOM index with page age.
I would suggest to first optimize swap traffic for an MMC device and then s=
tart thinking about this.

> A wild idea to avoid some writes altogether is to see if
> de-duplication techniques can be used to (partially?) match pages
> previously written so swap.

If you have such a situation, I think this is where KSM may help. It is my =
personal belief that with a bit of work, the KSM algorithm can be extended =
to swapped out pages too with little effort (at the expense of few increase=
 of read traffic, which is ok for flash based storage devices).=20

> In case of unencrypted swap  (or encrypted swap with a static key)
> swap pages on eMMC could even be re-used across multiple reboots.
> A simple version would just compare dirty pages with data in their
> swap slots as I suspect (but really don't know) that some user space
> algorithms (garbage collection?) dirty a page just temporarily -
> eventually reverting it to the previous content.
>=20

This goes in contrast with discarding or trimming a page and as such the ad=
vantages of this technique needs to be proven vs the performance gain of us=
ing the discard command.

> Stephan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-mmc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Cheers,
    Luca

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
