Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id A73CA6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 10:56:37 -0500 (EST)
MIME-Version: 1.0
Message-ID: <b3ab2d2f-a0a1-44ff-ac8f-bb0ed73d8978@default>
Date: Fri, 25 Jan 2013 07:56:29 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_pool
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1357590280-31535-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <CAEwNFnDWpyvmN-fU=MczXKtcay6vMMCOOHUM2M09+wx7zOVxDQ@mail.gmail.com>
 <51029FC3.4060402@linux.vnet.ibm.com>
In-Reply-To: <51029FC3.4060402@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCHv2 1/9] staging: zsmalloc: add gfp flags to zs_create_=
pool
>=20
> On 01/24/2013 07:33 PM, Minchan Kim wrote:
> > Hi Seth, frontswap guys
> >
> > On Tue, Jan 8, 2013 at 5:24 AM, Seth Jennings
> > <sjenning@linux.vnet.ibm.com> wrote:
> >> zs_create_pool() currently takes a gfp flags argument
> >> that is used when growing the memory pool.  However
> >> it is not used in allocating the metadata for the pool
> >> itself.  That is currently hardcoded to GFP_KERNEL.
> >>
> >> zswap calls zs_create_pool() at swapon time which is done
> >> in atomic context, resulting in a "might sleep" warning.
> >
> > I didn't review this all series, really sorry but totday I saw Nitin
> > added Acked-by so I'm afraid Greg might get it under my radar. I'm not
> > strong against but I would like know why we should call frontswap_init
> > under swap_lock? Is there special reason?
>=20
> The call stack is:
>=20
> SYSCALL_DEFINE2(swapon.. <-- swapon_mutex taken here
> enable_swap_info() <-- swap_lock taken here
> frontswap_init()
> __frontswap_init()
> zswap_frontswap_init()
> zs_create_pool()
>=20
> It isn't entirely clear to me why frontswap_init() is called under
> lock.  Then again, I'm not entirely sure what the swap_lock protects.
>  There are no comments near the swap_lock definition to tell me.
>=20
> I would guess that the intent is to block any writes to the swap
> device until frontswap_init() has completed.
>=20
> Dan care to weigh in?

I think frontswap's first appearance needs to be atomic, i.e.
the transition from (a) frontswap is not present and will fail
all calls, to (b) frontswap is fully functional... that transition
must be atomic.  And, once Konrad's module patches are in, the
opposite transition must be atomic also.  But there are most
likely other ways to do those transitions atomically that
don't need to hold swap_lock.

Honestly, I never really focused on the initialization code
so I am very open to improvements as long as they work for
all the various frontswap backends.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
