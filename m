Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C29586B0027
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 10:56:29 -0400 (EDT)
Received: from mail5-co9 (localhost [127.0.0.1])	by mail5-co9-R.bigfish.com
 (Postfix) with ESMTP id 192F6600AE	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 19 Mar 2013 14:54:06 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V2 2/3] Drivers: hv: balloon: Support 2M page
 allocations for ballooning
Date: Tue, 19 Mar 2013 14:53:57 +0000
Message-ID: <27dcec9842584d5f8e162e8e25d9e0a9@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1363639873-1576-1-git-send-email-kys@microsoft.com>
 <1363639898-1615-1-git-send-email-kys@microsoft.com>
 <1363639898-1615-2-git-send-email-kys@microsoft.com>
 <20130319144608.GJ7869@dhcp22.suse.cz>
In-Reply-To: <20130319144608.GJ7869@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>



> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@suse.cz]
> Sent: Tuesday, March 19, 2013 10:46 AM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com
> Subject: Re: [PATCH V2 2/3] Drivers: hv: balloon: Support 2M page allocat=
ions for
> ballooning
>=20
> On Mon 18-03-13 13:51:37, K. Y. Srinivasan wrote:
> > On Hyper-V it will be very efficient to use 2M allocations in the guest=
 as this
> > makes the ballooning protocol with the host that much more efficient. H=
yper-V
> > uses page ranges (start pfn : number of pages) to specify memory being =
moved
> > around and with 2M pages this encoding can be very efficient. However, =
when
> > memory is returned to the guest, the host does not guarantee any granul=
arity.
> > To deal with this issue, split the page soon after a successful 2M allo=
cation
> > so that this memory can potentially be freed as 4K pages.
>=20
> How many pages are requested usually?

This depends entirely on how many pages the guest has, the pressure reporte=
d by the guest and
the overall memory demand as perceived by the host. On idling guests that h=
ave been configured with
several Giga bytes of memory, I have seen several Giga bytes being balloone=
d out of the guest as soon
as new VMs are started or pressure goes up in an existing VM. In these case=
s, if 2M allocations succeed,
the ballooning operation can be done very efficiently.
>=20
> > If 2M allocations fail, we revert to 4K allocations.
> >
> > In this version of the patch, based on the feedback from Michal Hocko
> > <mhocko@suse.cz>, I have added some additional commentary to the patch
> > description.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
>=20
> I am not going to ack the patch because I am still not entirely
> convinced that big allocations are worth it. But that is up to you and
> hyper-V users.

As I said, Hyper-V has chosen 2M unit as the unit that will be most efficie=
nt in moving memory
around. All I am doing is making Linux participate in this protocol just as=
 efficiently as Windows=20
guests do.

Regards,

K. Y
>=20
> > ---
> >  drivers/hv/hv_balloon.c |   18 ++++++++++++++++--
> >  1 files changed, 16 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> > index 2cf7d4e..71655b4 100644
> > --- a/drivers/hv/hv_balloon.c
> > +++ b/drivers/hv/hv_balloon.c
> > @@ -997,6 +997,14 @@ static int  alloc_balloon_pages(struct
> hv_dynmem_device *dm, int num_pages,
> >
> >  		dm->num_pages_ballooned +=3D alloc_unit;
> >
> > +		/*
> > +		 * If we allocatted 2M pages; split them so we
> > +		 * can free them in any order we get.
> > +		 */
> > +
> > +		if (alloc_unit !=3D 1)
> > +			split_page(pg, get_order(alloc_unit << PAGE_SHIFT));
> > +
> >  		bl_resp->range_count++;
> >  		bl_resp->range_array[i].finfo.start_page =3D
> >  			page_to_pfn(pg);
>=20
> I would suggest also using __GFP_NO_KSWAPD (or basically use
> GFP_TRANSHUGE for alloc_unit>0) for the allocation to be as least
> disruptive as possible.
>=20
> > @@ -1023,9 +1031,10 @@ static void balloon_up(struct work_struct *dummy=
)
> >
> >
> >  	/*
> > -	 * Currently, we only support 4k allocations.
> > +	 * We will attempt 2M allocations. However, if we fail to
> > +	 * allocate 2M chunks, we will go back to 4k allocations.
> >  	 */
> > -	alloc_unit =3D 1;
> > +	alloc_unit =3D 512;
> >
> >  	while (!done) {
> >  		bl_resp =3D (struct dm_balloon_response *)send_buffer;
> > @@ -1041,6 +1050,11 @@ static void balloon_up(struct work_struct *dummy=
)
> >  						bl_resp, alloc_unit,
> >  						 &alloc_error);
> >
>=20
> You should handle alloc_balloon_pages returns 0 && !alloc_error which
> happens when num_pages < alloc_unit.
>=20
> > +		if ((alloc_error) && (alloc_unit !=3D 1)) {
> > +			alloc_unit =3D 1;
> > +			continue;
> > +		}
> > +
> >  		if ((alloc_error) || (num_ballooned =3D=3D num_pages)) {
> >  			bl_resp->more_pages =3D 0;
> >  			done =3D true;
> > --
> > 1.7.4.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
>=20
> --
> Michal Hocko
> SUSE Labs
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
