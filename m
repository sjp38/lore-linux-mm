Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 4BC026B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 04:17:06 -0400 (EDT)
Date: Tue, 3 Sep 2013 04:04:25 -0400
From: Chen Gong <gong.chen@linux.intel.com>
Subject: Re: [PATCH v2 2/4] mm/hwpoison: fix miss catch transparent huge page
Message-ID: <20130903080425.GA32295@gchen.bj.intel.com>
References: <1378165006-19435-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378165006-19435-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130903031519.GA31018@gchen.bj.intel.com>
 <52256342.4ad52a0a.2e24.ffff8c60SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
In-Reply-To: <52256342.4ad52a0a.2e24.ffff8c60SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 03, 2013 at 12:18:58PM +0800, Wanpeng Li wrote:
> Date: Tue, 3 Sep 2013 12:18:58 +0800
> From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> To: Chen Gong <gong.chen@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen
>  <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya
>  Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>,
>  linux-mm@kvack.org, linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v2 2/4] mm/hwpoison: fix miss catch transparent huge
>  page
> User-Agent: Mutt/1.5.21 (2010-09-15)
>=20
> On Mon, Sep 02, 2013 at 11:15:19PM -0400, Chen Gong wrote:
> >On Tue, Sep 03, 2013 at 07:36:44AM +0800, Wanpeng Li wrote:
> >> Date: Tue,  3 Sep 2013 07:36:44 +0800
> >> From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> To: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu
> >>  <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
> >>  Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com,
> >>  linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li
> >>  <liwanp@linux.vnet.ibm.com>
> >> Subject: [PATCH v2 2/4] mm/hwpoison: fix miss catch transparent huge p=
age=20
> >> X-Mailer: git-send-email 1.7.5.4
> >>=20
> >> Changelog:
> >>  *v1 -> v2: reverse PageTransHuge(page) && !PageHuge(page) check=20
> >>=20
> >> PageTransHuge() can't guarantee the page is transparent huge page sinc=
e it=20
> >> return true for both transparent huge and hugetlbfs pages. This patch =
fix=20
> >> it by check the page is also !hugetlbfs page.
> >>=20
> >> Before patch:
> >>=20
> >> [  121.571128] Injecting memory failure at pfn 23a200
> >> [  121.571141] MCE 0x23a200: huge page recovery: Delayed
> >> [  140.355100] MCE: Memory failure is now running on 0x23a200
> >>=20
> >> After patch:
> >>=20
> >> [   94.290793] Injecting memory failure at pfn 23a000
> >> [   94.290800] MCE 0x23a000: huge page recovery: Delayed
> >> [  105.722303] MCE: Software-unpoisoned page 0x23a000
> >>=20
> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> ---
> >>  mm/memory-failure.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>=20
> >> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> >> index e28ee77..b114570 100644
> >> --- a/mm/memory-failure.c
> >> +++ b/mm/memory-failure.c
> >> @@ -1349,7 +1349,7 @@ int unpoison_memory(unsigned long pfn)
> >>  	 * worked by memory_failure() and the page lock is not held yet.
> >>  	 * In such case, we yield to memory_failure() and make unpoison fail.
> >>  	 */
> >> -	if (PageTransHuge(page)) {
> >> +	if (!PageHuge(page) && PageTransHuge(page)) {
> >>  		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
> >>  			return 0;
> >>  	}
> >
> >Not sure which git tree should be used to apply this patch series? I ass=
ume
> >this patch series follows this link: https://lkml.org/lkml/2013/8/26/76.
> >
>=20
> mmotm tree or linux-next. ;-)
>=20
> >In unpoison_memory we already have
> >        if (PageHuge(page)) {
> >                ...
> >                return 0;
> >        }
> >so it looks like this patch is redundant.
>=20
> - Do you aware there is condition before go to this check?
> - Do you also analysis why the check can't catch the hugetlbfs page
>   through the dump information?
>=20

Looks like we use different trees. After checking your working tree,
your patch is right. So just ignore my words above. FWIW, please be
polite and give a positive response.

> Regards,
> Wanpeng Li=20
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSJZgJAAoJEI01n1+kOSLHakkP/1Uy6gLGTSAHWV65Dp9hl60e
KEs2qtDf7c1acLQTXB9ItT95Pj4oEZybpezhyBIksextO6az5u+9eSi9SxbsCtQd
AwWPUb02sOqD3DUKk0MZTaAC5F4t6GWq4Ub/ZTtD4bvqYRXem+pyfJbjpGVtz7Vv
ZwK3tC1q5amf2RZWKYI01zFbqaiiXSiqGuIJUUBriFnCubwZQ3BFMA/eMCkVLROk
FT2Ohu7VmW/bvjaDb9Vw7k7qZbEJb+SHzlSLItB424DOP4ZpBTuifs7p5A6qiEcT
1X9lZ11bSV5gSmoBTue91rX5IxVgKBgNYjERFXN+xh43chXQxAWg7BiBOJin4SxQ
E74ZGEicVaBjJLjmVEcH5ZvYeFvQ2QxixeJrysYOaEVZDwv2iRTYz3DmBSw89JQ5
2XZq8f3mi3xJ40zqbgqogFMym06L19XbGDCcFYdA2/O/u2J0M3P+rTXXzxm4nFwm
S7mHvJ7ELNF/yfLP8m/KqOX9Q4HZaLOgJNxw97/NRHfW/Slaqj1LMKpiarFZq3SA
h3gwzXGknWuEyWvyFB5DswefOjR2SXiM/xt3K6Sl6ccYGwCvkcEoZ1pkhR39Ce6X
xok4ub2LfDlikDa3ZViSHL24dQoHr3/guSn6KRzZyaPutHALVmRJ7MNO/xuWmARA
fVGevW1UqXA4249EDuHK
=W5CL
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
