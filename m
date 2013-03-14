Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 1B3BB6B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 12:11:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d02b5afd-bcb0-47df-9960-8e2122a04ad8@default>
Date: Thu, 14 Mar 2013 09:10:48 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 4/4] zcache: add pageframes count once compress
 zero-filled pages twice
References: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363158321-20790-5-git-send-email-liwanp@linux.vnet.ibm.com>
 <634487ea-fbbd-4eb9-9a18-9206edc4e0d2@default>
 <20130314002056.GA10062@hacker.(null)>
In-Reply-To: <20130314002056.GA10062@hacker.(null)>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> Sent: Wednesday, March 13, 2013 6:21 PM
> To: Dan Magenheimer
> Cc: Andrew Morton; Greg Kroah-Hartman; Dan Magenheimer; Seth Jennings; Ko=
nrad Rzeszutek Wilk; Minchan
> Kim; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 4/4] zcache: add pageframes count once compress zero-=
filled pages twice
>=20
> On Wed, Mar 13, 2013 at 09:42:16AM -0700, Dan Magenheimer wrote:
> >> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> >> Sent: Wednesday, March 13, 2013 1:05 AM
> >> To: Andrew Morton
> >> Cc: Greg Kroah-Hartman; Dan Magenheimer; Seth Jennings; Konrad Rzeszut=
ek Wilk; Minchan Kim; linux-
> >> mm@kvack.org; linux-kernel@vger.kernel.org; Wanpeng Li
> >> Subject: [PATCH 4/4] zcache: add pageframes count once compress zero-f=
illed pages twice
> >
> >Hi Wanpeng --
> >
> >Thanks for taking on this task from the drivers/staging/zcache TODO list=
!
> >
> >> Since zbudpage consist of two zpages, two zero-filled pages compressio=
n
> >> contribute to one [eph|pers]pageframe count accumulated.
> >
>=20
> Hi Dan,
>=20
> >I'm not sure why this is necessary.  The [eph|pers]pageframe count
> >is supposed to be counting actual pageframes used by zcache.  Since
> >your patch eliminates the need to store zero pages, no pageframes
> >are needed at all to store zero pages, so it's not necessary
> >to increment zcache_[eph|pers]_pageframes when storing zero
> >pages.
> >
>=20
> Great point! It seems that we also don't need to caculate
> zcache_[eph|pers]_zpages for zero-filled pages. I will fix
> it in next version. :-)

Hi Wanpeng --

I think we DO need to increment/decrement zcache_[eph|pers]_zpages
for zero-filled pages.

The main point of the counters for zpages and pageframes
is to be able to calculate density =3D=3D zpages/pageframes.
A zero-filled page becomes a zpage that "compresses" to zero bytes
and, as a result, requires zero pageframes for storage.
So the zpages counter should be increased but the pageframes
counter should not.

If you are changing the patch anyway, I do like better the use
of "zero_filled_page" rather than just "zero" or "zero page".
So it might be good to change:

handle_zero_page -> handle_zero_filled_page
pages_zero -> zero_filled_pages
zcache_pages_zero -> zcache_zero_filled_pages

and maybe

page_zero_filled -> page_is_zero_filled

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
