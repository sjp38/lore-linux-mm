Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 6B8ED6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 22:01:20 -0400 (EDT)
References: <1374492762-17735-1-git-send-email-pintu.k@samsung.com> <20130722163836.GD715@cmpxchg.org>
Message-ID: <1374544878.92541.YahooMailNeo@web160102.mail.bf1.yahoo.com>
Date: Mon, 22 Jul 2013 19:01:18 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [PATCH 2/2] mm: page_alloc: avoid slowpath for more than MAX_ORDER allocation.
In-Reply-To: <20130722163836.GD715@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Pintu Kumar <pintu.k@samsung.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "minchan@kernel.org" <minchan@kernel.org>, "cody@linux.vnet.ibm.com" <cody@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cpgs@samsung.com" <cpgs@samsung.com>

=0A=0AHi Johannes,=0A=0AThank you for your reply. =0A=0A=0AThis is my first=
 kernel patch, sorry for the small mistakes.=0APlease find my comments inli=
ne.=0A=0A>________________________________=0A> From: Johannes Weiner <hanne=
s@cmpxchg.org>=0A>To: Pintu Kumar <pintu.k@samsung.com> =0A>Cc: akpm@linux-=
foundation.org; mgorman@suse.de; jiang.liu@huawei.com; minchan@kernel.org; =
cody@linux.vnet.ibm.com; linux-mm@kvack.org; linux-kernel@vger.kernel.org; =
cpgs@samsung.com; pintu_agarwal@yahoo.com =0A>Sent: Monday, 22 July 2013 10=
:08 PM=0A>Subject: Re: [PATCH 2/2] mm: page_alloc: avoid slowpath for more =
than MAX_ORDER allocation.=0A> =0A>=0A>Hi Pintu,=0A>=0A>On Mon, Jul 22, 201=
3 at 05:02:42PM +0530, Pintu Kumar wrote:=0A>> It was observed that if orde=
r is passed as more than MAX_ORDER=0A>> allocation in __alloc_pages_nodemas=
k, it will unnecessarily go to=0A>> slowpath and then return failure.=0A>> =
Since we know that more than MAX_ORDER will anyways fail, we can=0A>> avoid=
 slowpath by returning failure in nodemask itself.=0A>> =0A>> Signed-off-by=
: Pintu Kumar <pintu.k@samsung.com>=0A>> ---=0A>>=A0 mm/page_alloc.c |=A0 =
=A0 4 ++++=0A>>=A0 1 file changed, 4 insertions(+)=0A>> =0A>> diff --git a/=
mm/page_alloc.c b/mm/page_alloc.c=0A>> index 202ab58..6d38e75 100644=0A>> -=
-- a/mm/page_alloc.c=0A>> +++ b/mm/page_alloc.c=0A>> @@ -1564,6 +1564,10 @@=
 __setup("fail_page_alloc=3D", setup_fail_page_alloc);=0A>>=A0 =0A>>=A0 sta=
tic bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)=0A>>=A0=
 {=0A>> +=A0=A0=A0 if (order >=3D MAX_ORDER) {=0A>> +=A0=A0=A0 =A0=A0=A0 WA=
RN_ON(!(gfp_mask & __GFP_NOWARN));=0A>> +=A0=A0=A0 =A0=A0=A0 return false;=
=0A>> +=A0=A0=A0 }=0A>=0A>I don't see how this solves what you describe (sh=
ould return true?)=0A>=0A=0AOk, sorry, I will correct this.=0A=0A=0A>It wou=
ld also not be a good place to put performance optimization,=0A>because thi=
s function is only called as part of a debugging mechanism=0A>that is usual=
ly disabled.=0A>=0A=0AOk, so you mean, we should add this check directly at=
 the top of __alloc_pages_nodemask() ??=0A=0A=0A=0A>Lastly, order >=3D MAX_=
ORDER is not supported by the page allocator, and=0A>we do not want to puni=
sh 99.999% of all legitimate page allocations in=0A>the fast path in order =
to catch an unlikely situation like this.=0A=0ASo, is it fine if we add an =
unlikely condition like below:=0Aif (unlikely(order >=3D MAX_ORDER))=0A=0A>=
Having the check only in the slowpath is a good thing.=0A>=0ASorry, I could=
 not understand, why adding this check in slowpath is only good.=0AWe could=
 have returned failure much before that.=0AWithout this check, we are actua=
lly allowing failure of "first allocation attempt" and then returning the c=
ause of failure in slowpath.=0AI thought it will be better to track the unl=
ikely failure in the system as early as possible, at least from the embedde=
d system prospective.=0ALet me know your opinion.=0A=0A=0A>--=0A>To unsubsc=
ribe, send a message with 'unsubscribe linux-mm' in=0A>the body to majordom=
o@kvack.org.=A0 For more info on Linux MM,=0A>see: http://www.linux-mm.org/=
 .=0A>Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=
=0A>=0A>=0A>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
