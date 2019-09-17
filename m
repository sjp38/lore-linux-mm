Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3AD5C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 18:33:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F6D92053B
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 18:33:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nPHVaQbr";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Z7/Awqus"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F6D92053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB9976B0005; Tue, 17 Sep 2019 14:33:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6C2D6B0006; Tue, 17 Sep 2019 14:33:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0B246B0007; Tue, 17 Sep 2019 14:33:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id B0BCA6B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 14:33:38 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3E6A5AC07
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 18:33:38 +0000 (UTC)
X-FDA: 75945260916.26.gold17_1fa029324f045
X-HE-Tag: gold17_1fa029324f045
X-Filterd-Recvd-Size: 14437
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 18:33:36 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x8HIVbp2022731;
	Tue, 17 Sep 2019 11:33:30 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=49VjQOrmqHLAHl45j2cKRhv3oQ7fHxwhxE8osLan6oI=;
 b=nPHVaQbrzkRHrn5/fO82gqzlK+JlVgG5Gx2x9nFktkTl5Y4MeOMuIw7prFfrZISe0Ctq
 BTFPAyPkywZCd17IEKrlTxqoLIJh95YEr7X+nSrkm8hSx4Mr3Jq7FHhielTKARDipGTL
 E3mPD6MRKVhkIlaDXOPr53DkK8DgDP+WqT4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2v2kbmv3ar-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 17 Sep 2019 11:33:29 -0700
Received: from prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 17 Sep 2019 11:33:17 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 17 Sep 2019 11:33:17 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 17 Sep 2019 11:33:17 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=nEMSOAoRctmuYjs6GWMLi+4XuH9zT8bcBNgGxm0V+eoHLm4sn1VJInteGfqJXdKeUDYDpG9pEafe6057HZS6vE6YVt5Jgpy6zV+fhVvb6sEB0cygEgChZ2Y/ZthacIKpvAcrimH1lpBwlEpbElAyTc84zYAEpi8CQ7MWvJ9f9Fwzu1WOp5qiLEOsUBMEju/BlOPO3/zugWk7LA4/Lik3XbdLbQBj5kVXE9u/C/at6Foyb3GQVfo9/qGn15ii4NpCxQMmx3X8+Gx7BsVZBaMEoO/Izz9DMIIcFXnLhryav5hRzspVw2ryTAhyZqddGARWihkR5XJWad7mntsqzeS7Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=49VjQOrmqHLAHl45j2cKRhv3oQ7fHxwhxE8osLan6oI=;
 b=EAhBAERDDqg2WwDtlMKBPbCCO4jZkhNdPGEH7CLYkJZ65kG0sEHG1KRElo6Y3NG7rql8An6B/HQAbQYBH4nWNVYRmCYa1uCGwOUlaYSBMje+1ridc9E8kr//D1Bd+IRPJlSCRmtkXDZGpnnKi24PJ1wf9J6fiuBBxRo/QJrW9ewe/X248x5IjePHwOgvEhGX8pdvX7DPemHBOweueFXqPUKLjgQrI2eG/KQvzyksIgy7ekpejuI8G4VGB8Qmvzt/s28D75gogHIB6sETLnRMZ962shKZjD49eRlKreuiXCpYiC7drI4rbwIYsTvXoRJQ+nP7cQSuwLRba9tAUMi1VQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=49VjQOrmqHLAHl45j2cKRhv3oQ7fHxwhxE8osLan6oI=;
 b=Z7/Awqus9SUvpDnlM66wNA+Mbq5ZcdtdeyJpuHfaQxlosusv1eKy6lB6cdDvuaW+36rTXuop8cEdS/NSZQbQI6v/uf5/utWiBHB009N9qMvC5gZN6e2pbJkdRGhCaNe+HNzfKs1XO+KVxvapACXjMYX8Ty1FH69KIHd0nrtS1Do=
Received: from BYASPR01MB0023.namprd15.prod.outlook.com (20.177.126.93) by
 BYAPR15MB2807.namprd15.prod.outlook.com (20.179.158.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.21; Tue, 17 Sep 2019 18:33:15 +0000
Received: from BYASPR01MB0023.namprd15.prod.outlook.com
 ([fe80::e448:b543:1171:8961]) by BYASPR01MB0023.namprd15.prod.outlook.com
 ([fe80::e448:b543:1171:8961%5]) with mapi id 15.20.2263.023; Tue, 17 Sep 2019
 18:33:15 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko
	<mhocko@kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Shakeel
 Butt" <shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Waiman Long <longman@redhat.com>
Subject: Re: [PATCH RFC 01/14] mm: memcg: subpage charging API
Thread-Topic: [PATCH RFC 01/14] mm: memcg: subpage charging API
Thread-Index: AQHVZDNmLHUfmxN6PU+s0PWXiLpdV6cuU9OAgABtS4CAAOBGAIAAoukA
Date: Tue, 17 Sep 2019 18:33:15 +0000
Message-ID: <20190917183308.GA9776@castle>
References: <20190905214553.1643060-1-guro@fb.com>
 <20190905214553.1643060-2-guro@fb.com> <20190916125611.GB29985@cmpxchg.org>
 <20190917022713.GB8073@castle.DHCP.thefacebook.com>
 <20190917085004.GA1486@cmpxchg.org>
In-Reply-To: <20190917085004.GA1486@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MW2PR16CA0053.namprd16.prod.outlook.com
 (2603:10b6:907:1::30) To BYASPR01MB0023.namprd15.prod.outlook.com
 (2603:10b6:a03:72::29)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::650c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: fc78a183-2772-4c78-487b-08d73b9d80af
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2807;
x-ms-traffictypediagnostic: BYAPR15MB2807:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <BYAPR15MB2807FC4F3B59F62A98271284BE8F0@BYAPR15MB2807.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01630974C0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(7916004)(366004)(189003)(199004)(7736002)(4326008)(14454004)(6486002)(229853002)(71200400001)(6512007)(305945005)(71190400001)(9686003)(5660300002)(33656002)(486006)(66556008)(6916009)(66476007)(1076003)(64756008)(66446008)(33716001)(86362001)(11346002)(66946007)(476003)(52116002)(102836004)(498600001)(99286004)(76176011)(46003)(6506007)(186003)(14444005)(25786009)(6116002)(6436002)(6246003)(81166006)(54906003)(2906002)(386003)(446003)(81156014)(8676002)(8936002)(256004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2807;H:BYASPR01MB0023.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: /uB8BHSyAUjaC0QjTTl5Xquef6Yv/bJayPaCQyVB07qgcVXfrAyZmDC640O845l9I6pSPRqpLuh9sAKWLlDlxCJI3RxrY3w0j/73sp9EJ3ey+qKbEf5fWNeVJql5hrUgtRtNQVNbHGpl8V5hRY5EgsjuKjW3p+zOvXb3JRvjWvjZT60DMg/msjGLFL6kHebGp57SMT3zXs8uehawaGYZ6RcxsvRF7VB7Pgj+P/lIEH/4Zpn2+zLm7KGBZO2gqoHDG7JKMB5KVcmba6lD7pM+leg1QrtpH8ioD26lpnE+mNNFrl7R52uDxn+i6dkAS/LOEGvLOM0BCpNu/BEQRw8paLg99VPolrohoLmCt+Go1v9W9Mp+b4zjI2UAuOwJd3bjsdJIF9PrKl37ebCtf9oz2fWywVBXUN31gvokEWxH2+Q=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <68AA92D021D70B459000DC576A07C2A7@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: fc78a183-2772-4c78-487b-08d73b9d80af
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Sep 2019 18:33:15.4957
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: vKvU6fPID6k6m+GQFi/+b+TB8faixbnp6SBp5SEn0BJEicJ82Mj4b4a39rx1YQ2w
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2807
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-17_10:2019-09-17,2019-09-17 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 mlxlogscore=999
 malwarescore=0 adultscore=0 spamscore=0 mlxscore=0 bulkscore=0
 clxscore=1015 suspectscore=0 lowpriorityscore=0 impostorscore=0
 priorityscore=1501 phishscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-1908290000 definitions=main-1909170175
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 10:50:04AM +0200, Johannes Weiner wrote:
> On Tue, Sep 17, 2019 at 02:27:19AM +0000, Roman Gushchin wrote:
> > On Mon, Sep 16, 2019 at 02:56:11PM +0200, Johannes Weiner wrote:
> > > On Thu, Sep 05, 2019 at 02:45:45PM -0700, Roman Gushchin wrote:
> > > > Introduce an API to charge subpage objects to the memory cgroup.
> > > > The API will be used by the new slab memory controller. Later it
> > > > can also be used to implement percpu memory accounting.
> > > > In both cases, a single page can be shared between multiple cgroups
> > > > (and in percpu case a single allocation is split over multiple page=
s),
> > > > so it's not possible to use page-based accounting.
> > > >=20
> > > > The implementation is based on percpu stocks. Memory cgroups are st=
ill
> > > > charged in pages, and the residue is stored in perpcu stock, or on =
the
> > > > memcg itself, when it's necessary to flush the stock.
> > >=20
> > > Did you just implement a slab allocator for page_counter to track
> > > memory consumed by the slab allocator?
> >=20
> > :)
> >=20
> > >=20
> > > > @@ -2500,8 +2577,9 @@ void mem_cgroup_handle_over_high(void)
> > > >  }
> > > > =20
> > > >  static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > > > -		      unsigned int nr_pages)
> > > > +		      unsigned int amount, bool subpage)
> > > >  {
> > > > +	unsigned int nr_pages =3D subpage ? ((amount >> PAGE_SHIFT) + 1) =
: amount;
> > > >  	unsigned int batch =3D max(MEMCG_CHARGE_BATCH, nr_pages);
> > > >  	int nr_retries =3D MEM_CGROUP_RECLAIM_RETRIES;
> > > >  	struct mem_cgroup *mem_over_limit;
> > > > @@ -2514,7 +2592,9 @@ static int try_charge(struct mem_cgroup *memc=
g, gfp_t gfp_mask,
> > > >  	if (mem_cgroup_is_root(memcg))
> > > >  		return 0;
> > > >  retry:
> > > > -	if (consume_stock(memcg, nr_pages))
> > > > +	if (subpage && consume_subpage_stock(memcg, amount))
> > > > +		return 0;
> > > > +	else if (!subpage && consume_stock(memcg, nr_pages))
> > > >  		return 0;
> > >=20
> > > The layering here isn't clean. We have an existing per-cpu cache to
> > > batch-charge the page counter. Why does the new subpage allocator not
> > > sit on *top* of this, instead of wedged in between?
> > >=20
> > > I think what it should be is a try_charge_bytes() that simply gets on=
e
> > > page from try_charge() and then does its byte tracking, regardless of
> > > how try_charge() chooses to implement its own page tracking.
> > >=20
> > > That would avoid the awkward @amount + @subpage multiplexing, as well
> > > as annotating all existing callsites of try_charge() with a
> > > non-descript "false" parameter.
> > >=20
> > > You can still reuse the stock data structures, use the lower bits of
> > > stock->nr_bytes for a different cgroup etc., but the charge API shoul=
d
> > > really be separate.
> >=20
> > Hm, I kinda like the idea, however there is a complication: for the sub=
page
> > accounting the css reference management is done in a different way, so =
that
> > all existing code should avoid changing the css refcounter. So I'd need
> > to pass a boolean argument anyway.
>=20
> Can you elaborate on the refcounting scheme? I don't quite understand
> how there would be complications with that.
>=20
> Generally, references are held for each page that is allocated in the
> page_counter. try_charge() allocates a batch of css references,
> returns one and keeps the rest in stock.
>=20
> So couldn't the following work?
>=20
> When somebody allocates a subpage, the css reference returned by
> try_charge() is shared by the allocated subpage object and the
> remainder that is kept via stock->subpage_cache and stock->nr_bytes
> (or memcg->nr_stocked_bytes when the percpu cache is reset).

Because individual objects are a subject of reparenting and can outlive
the origin memory cgroup, they shouldn't hold a direct reference to the
memory cgroup. Instead they hold a reference to the mem_cgroup_ptr object,
and this objects holds a single reference to the memory cgroup.
Underlying pages shouldn't hold a reference too.

Btw, it's already true, just kmem_cache plays the role of such intermediate
object, and we do an explicit transfer of charge (look at memcg_charge_slab=
()).
So we initially associate a page with the memcg, and almost immediately
after break this association and insert kmem_cache in between.

But with subpage accounting it's not possible, as a page is shared between
multiple cgroups, and it can't be attributed to any specific cgroup at
any time.

>=20
> When the subpage objects are freed, you'll eventually have a full page
> again in stock->nr_bytes, at which point you page_counter_uncharge()
> paired with css_put(_many) as per usual.
>=20
> A remainder left in old->nr_stocked_bytes would continue to hold on to
> one css reference. (I don't quite understand who is protecting this
> remainder in your current version, actually. A bug?)
>=20
> Instead of doing your own batched page_counter uncharging in
> refill_subpage_stock() -> drain_subpage_stock(), you should be able to
> call refill_stock() when stock->nr_bytes adds up to a whole page again.
>=20
> Again, IMO this would be much cleaner architecture if there was a
> try_charge_bytes() byte allocator that would sit on top of a cleanly
> abstracted try_charge() page allocator, just like the slab allocator
> is sitting on top of the page allocator - instead of breaking through
> the abstraction layer of the underlying page allocator.
>=20

As I said, I like the idea to put it on top, but it can't be put on top
without changes in css refcounting (or I don't see how). I don't know
how to mix stocks which are holding css references and which are not,
so I might end up with two stocks as in current implementation. Then
the idea of having another layer of caching on top looks slightly less
appealing, but maybe still worth a try.

Thanks!

