Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 79B646B004D
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 18:08:25 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1739445lag.14
        for <linux-mm@kvack.org>; Fri, 30 Mar 2012 15:08:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201203301850.22784.arnd@arndb.de>
References: <201203301744.16762.arnd@arndb.de>
	<201203301850.22784.arnd@arndb.de>
Date: Fri, 30 Mar 2012 17:08:23 -0500
Message-ID: <CAJN=5gDBQJc_KXUadqtzmxPqPF71PDcToGo_T-agNey9eN2MQA@mail.gmail.com>
Subject: Re: swap on eMMC and other flash
From: Zach Pfeffer <zach.pfeffer@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, linux-mm@kvack.org, Alex Lemberg <alex.lemberg@sandisk.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-kernel@vger.kernel.org, Hyojin Jeong <syr.jeong@samsung.com>, "Luca Porzio (lporzio)" <lporzio@micron.com>, kernel-team@android.com, Yejin Moon <yejin.moon@samsung.com>

On 30 March 2012 13:50, Arnd Bergmann <arnd@arndb.de> wrote:
> (sorry for the duplicated email, this corrects the address of the android
> kernel team, please reply here)
>
> On Friday 30 March 2012, Arnd Bergmann wrote:
>
> =A0We've had a discussion in the Linaro storage team (Saugata, Venkat and=
 me,
> =A0with Luca joining in on the discussion) about swapping to flash based =
media
> =A0such as eMMC. This is a summary of what we found and what we think sho=
uld
> =A0be done. If people agree that this is a good idea, we can start workin=
g
> =A0on it.
>
> =A0The basic problem is that Linux without swap is sort of crippled and s=
ome
> =A0things either don't work at all (hibernate) or not as efficient as the=
y
> =A0should (e.g. tmpfs). At the same time, the swap code seems to be rathe=
r
> =A0inappropriate for the algorithms used in most flash media today, causi=
ng
> =A0system performance to suffer drastically, and wearing out the flash ha=
rdware
> =A0much faster than necessary. In order to change that, we would be
> =A0implementing the following changes:
>
> =A01) Try to swap out multiple pages at once, in a single write request. =
My
> =A0reading of the current code is that we always send pages one by one to
> =A0the swap device, while most flash devices have an optimum write size o=
f
> =A032 or 64 kb and some require an alignment of more than a page. Ideally
> =A0we would try to write an aligned 64 kb block all the time. Writing ali=
gned
> =A064 kb chunks often gives us ten times the throughput of linear 4kb wri=
tes,
> =A0and going beyond 64 kb usually does not give any better performance.

Last I read Transparent Huge Pages are still paged in and out a page
at a time, is this or was this ever the case? If it is the case should
the paging system be extended to support THP which would take care of
the big block issues with flash media?

> =A02) Make variable sized swap clusters. Right now, the swap space is
> =A0organized in clusters of 256 pages (1MB), which is less than the typic=
al
> =A0erase block size of 4 or 8 MB. We should try to make the swap cluster
> =A0aligned to erase blocks and have the size match to avoid garbage colle=
ction
> =A0in the drive. The cluster size would typically be set by mkswap as a n=
ew
> =A0option and interpreted at swapon time.
>
> =A03) As Luca points out, some eMMC media would benefit significantly fro=
m
> =A0having discard requests issued for every page that gets freed from
> =A0the swap cache, rather than at the time just before we reuse a swap
> =A0cluster. This would probably have to become a configurable option
> =A0as well, to avoid the overhead of sending the discard requests on
> =A0media that don't benefit from this.
>
> =A0Does this all sound appropriate for the Linux memory management people=
?
>
> =A0Also, does this sound useful to the Android developers? Would you
> =A0start using swap if we make it perform well and not destroy the drives=
?
>
> =A0Finally, does this plan match up with the capabilities of the
> =A0various eMMC devices? I know more about SD and USB devices and
> =A0I'm quite convinced that it would help there, but eMMC can be
> =A0more like an SSD in some ways, and the current code should be fine
> =A0for real SSDs.
>
> =A0 =A0 =A0 =A0Arnd
>
>
>
> _______________________________________________
> linaro-kernel mailing list
> linaro-kernel@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-kernel



--=20
Zach Pfeffer
Android Platform Team Lead, Linaro Platform Teams
Linaro.org | Open source software for ARM SoCs
Follow Linaro: http://www.facebook.com/pages/Linaro
http://twitter.com/#!/linaroorg - http://www.linaro.org/linaro-blog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
