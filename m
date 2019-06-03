Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0395C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:50:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AD2826BA1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:50:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=utc.com header.i=@utc.com header.b="QFhr+rO1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AD2826BA1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=utc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19A926B0008; Mon,  3 Jun 2019 10:50:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14C486B000A; Mon,  3 Jun 2019 10:50:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A906B000C; Mon,  3 Jun 2019 10:50:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C07F16B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:50:07 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j36so10076155pgb.20
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:50:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=FSiJPJPkYdS+osE+iTurtwGkbAGRi9Sce6GJOZsjXPc=;
        b=pIDw9fLcYQrRcwlQT0HLKIXC+f3XmQTP/E63Q8cAHbnYQOz20lrdc9RfLkDZzfGsam
         1krNklAMkM0i3xmbFxpooMIYZ/Y7Ui3FRY5cYcFwTxXSaPmG8uUyXblcmBF9mJKv2L2W
         qIjWUB+Wjh/G7YViu2XGlvyJIxU7OXi+aaa3C8SqjwNx+Zbz65REv1SLkfTRTL70ngEg
         9Eg8CIA0DlbotY4cX6oL7sKswWzBuEsBPbjhjljROVuq0Z4wRvlOW4TP8uA88h32hxrO
         GKj/2u49mPJVomcrXQOxAIs+DgPNZPXH1hkbCCSKkkK25tJmtVcbR9k4kc60dsKgTEHp
         +Wnw==
X-Gm-Message-State: APjAAAWgR9K5mYHi5tDoXbUw+SSFmAMz9dDzA6t5aUtSFLC/lVmWEErW
	+SQhSvaP8YqELykpWTwq3Tc/zsmWMrY6NiEFz4eE2m7226ZgrBBvWH7xU0MtcittO8X+rfy3vb4
	gT/+3L3mnOedcsBiNbN6/dsaf6pyUPTjDbLEK/1q/NYN4ByG0ZGeyVMACUnvot2Nzvg==
X-Received: by 2002:a63:cc4b:: with SMTP id q11mr28940287pgi.43.1559573407288;
        Mon, 03 Jun 2019 07:50:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhLErRyUk4/mVMr7uTZVw/KxCG3EP63bB/kHrD1IKiqjo+cSkUfNkc/m6uUv4Q4yKMGfFc
X-Received: by 2002:a63:cc4b:: with SMTP id q11mr28940194pgi.43.1559573406328;
        Mon, 03 Jun 2019 07:50:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559573406; cv=none;
        d=google.com; s=arc-20160816;
        b=ZieS1abOaDZjmNxO9VaSZ2PFBrBzEwfQBMi6vQSIYtivo7fGZ+tH/bDhLiKnR0a7nZ
         Cw7NAkqGWHy4Bir/VtdM0/swbV9ZROAHK0+AUZrtognZwTvIXNGe49T9TfWhe6l4hGTJ
         Cu1wf+FzM5h4w1XCPccpZ1vhVh0hVRwXt3k9UYLc0JcFfFn91O1soVvLMXkALwRkH/FF
         5+qN1ult4u4N0uXy8ItM20SMcwj/ipb/R9/zoIsxOD+DQJ/uO0/4lLV9Vrwx6B8bw+aT
         +gw/PuZBPnmCOkxtUkDyi+ef3ywuRs9kC3Dr1Mv9Cznqg4HdePmvtjY2FFVsvLvOdOyF
         zPkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=FSiJPJPkYdS+osE+iTurtwGkbAGRi9Sce6GJOZsjXPc=;
        b=BP2FdYUnTkVH6AhK/X30gx1j3ELis/4sWFCJ75VLI/3jovAA205TI83ejOy+iMxIz3
         1B1C5c/Y+eQDnE0ppNuQ8gSImBzx/kYj7TukPqekzQ21x0Wli8jAnBLXj5ORXVZ5xywJ
         t9NULPwsESAd7aIa3FbrW23jTAFr3qp4UPuXbPe1E0A7RIuODzhrYFkRcMmQB7cwA3LM
         X3nDRaG9kq16EY/Q8BUBoWD089IoHKTgxT072nGPPnnd5GHzuLpn9MtRSs8wZLDScNAj
         Yy7BgjW3WqXCHEfiVlATtuk+DTTSExAyr1nWODieNWv/yuqVyd9rTJvb8uzs54R6126x
         GB0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@utc.com header.s=POD040618 header.b=QFhr+rO1;
       spf=pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) smtp.mailfrom=Amit.Nagal@utc.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=utc.com
Received: from mx0a-00105401.pphosted.com (mx0a-00105401.pphosted.com. [67.231.144.184])
        by mx.google.com with ESMTPS id b19si21517102pfi.23.2019.06.03.07.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:50:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) client-ip=67.231.144.184;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@utc.com header.s=POD040618 header.b=QFhr+rO1;
       spf=pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) smtp.mailfrom=Amit.Nagal@utc.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=utc.com
Received: from pps.filterd (m0078137.ppops.net [127.0.0.1])
	by mx0a-00105401.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x53EkeDp042562;
	Mon, 3 Jun 2019 10:49:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=utc.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=POD040618;
 bh=FSiJPJPkYdS+osE+iTurtwGkbAGRi9Sce6GJOZsjXPc=;
 b=QFhr+rO17Ip3boWsaBycMcQDqZY2554hxwuIWjCTMmYu2Ei7zA+fAdL/5xV/zcaqp+oY
 6Bi57/mboH9f3slANRWa7G7moE/KubPXlD5c1kCGTG40/Y0CtTSbQPGJYuE0n0jUNf2k
 WSdk2spV9ZEZgstJViUDjcCm8xRBQYKjW6KP8llGdiDloguRei58XiW24HeHpQUlR/cf
 d0ERDbILqUSqrpg+60J7mESE/kQqp1TdoGFNTtOZ1nVeCnVCWYqSUZww1m7kygOgbVRT
 9YgZ6zQs3hbBw3xEC/GoF9H1qMfekZxPVybawBRU8fpxo+AqP4Ug2wCq7srMww8V3Rsi Bw== 
Received: from xnwpv36.utc.com ([167.17.239.16])
	by mx0a-00105401.pphosted.com with ESMTP id 2sw4nbsv47-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 03 Jun 2019 10:49:58 -0400
Received: from uusmna1r.utc.com (uusmna1r.utc.com [159.82.219.64])
	by xnwpv36.utc.com (8.16.0.27/8.16.0.27) with ESMTPS id x53Ent7b149578
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 3 Jun 2019 10:49:55 -0400
Received: from UUSTOE1Q.utcmail.com (UUSTOE1Q.utcmail.com [10.221.3.41])
	by uusmna1r.utc.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id x53EnsFA003894
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=OK);
	Mon, 3 Jun 2019 10:49:55 -0400
Received: from UUSALE1A.utcmail.com (10.220.3.27) by UUSTOE1Q.utcmail.com
 (10.221.3.41) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 3 Jun
 2019 09:49:53 -0500
Received: from UUSALE1A.utcmail.com ([10.220.5.27]) by UUSALE1A.utcmail.com
 ([10.220.5.27]) with mapi id 15.00.1473.003; Mon, 3 Jun 2019 10:49:53 -0400
From: "Nagal, Amit               UTC CCS" <Amit.Nagal@utc.com>
To: Matthew Wilcox <willy@infradead.org>
CC: Alexander Duyck <alexander.duyck@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "CHAWLA, RITU              UTC
 CCS" <RITU.CHAWLA@utc.com>,
        "Netter, Christian M       UTC CCS"
	<christian.Netter@fs.UTC.COM>
Subject: RE: [External] Re: linux kernel page allocation failure and tuning of
 page cache
Thread-Topic: [External] Re: linux kernel page allocation failure and tuning
 of page cache
Thread-Index: AdUXwJaEVv2cRvqaQPqGQFhwqLYB3QAWIwGAAGydulAAFtsUAAADqGyA
Date: Mon, 3 Jun 2019 14:49:53 +0000
Message-ID: <4f5f770de6254adb943854865a3484cd@UUSALE1A.utcmail.com>
References: <09c5d10e9d6b4c258b22db23e7a17513@UUSALE1A.utcmail.com>
 <CAKgT0UfoLDxL_8QkF_fuUK-2-6KGFr5y=2_nRZCNc_u+d+LCrg@mail.gmail.com>
 <6ec47a90f5b047dabe4028ca90bb74ab@UUSALE1A.utcmail.com>
 <20190603121138.GC23346@bombadil.infradead.org>
In-Reply-To: <20190603121138.GC23346@bombadil.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.220.35.246]
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Proofpoint-Spam-Details: rule=outbound_default_notspam policy=outbound_default score=0
 priorityscore=1501 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0
 spamscore=0 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906030104
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


From: Matthew Wilcox [mailto:willy@infradead.org]=20
Sent: Monday, June 3, 2019 5:42 PM
To: Nagal, Amit UTC CCS <Amit.Nagal@utc.com>
On Mon, Jun 03, 2019 at 05:30:57AM +0000, Nagal, Amit               UTC CCS=
 wrote:
> > [  776.174308] Mem-Info:
> > [  776.176650] active_anon:2037 inactive_anon:23 isolated_anon:0 [=20
> > 776.176650]  active_file:2636 inactive_file:7391 isolated_file:32 [=20
> > 776.176650]  unevictable:0 dirty:1366 writeback:1281 unstable:0 [=20
> > 776.176650]  slab_reclaimable:719 slab_unreclaimable:724 [=20
> > 776.176650]  mapped:1990 shmem:26 pagetables:159 bounce:0 [=20
> > 776.176650]  free:373 free_pcp:6 free_cma:0 [  776.209062] Node 0=20
> > active_anon:8148kB inactive_anon:92kB active_file:10544kB=20
> > inactive_file:29564kB unevictable:0kB isolated(anon):0kB=20
> > isolated(file):128kB mapped:7960kB dirty:5464kB writeback:5124kB=20
> > shmem:104kB writeback_tmp:0kB unstable:0kB pages_scanned:0=20
> > all_unreclaimable? no [  776.233602] Normal free:1492kB min:964kB=20
> > low:1204kB high:1444kB active_anon:8148kB inactive_anon:92kB=20
> > active_file:10544kB inactive_file:29564kB unevictable:0kB=20
> > writepending:10588kB present:65536kB managed:59304kB mlocked:0kB=20
> > slab_reclaimable:2876kB slab_unreclaimable:2896kB=20
> > kernel_stack:1152kB pagetables:636kB bounce:0kB free_pcp:24kB=20
> > local_pcp:24kB free_cma:0kB [  776.265406] lowmem_reserve[]: 0 0 [ =20
> > 776.268761] Normal: 7*4kB (H) 5*8kB (H) 7*16kB (H) 5*32kB (H) 6*64kB=20
> > (H) 2*128kB (H) 2*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D=20
> > 1492kB
> > 10071 total pagecache pages
> > [  776.284124] 0 pages in swap cache [  776.287446] Swap cache=20
> > stats: add 0, delete 0, find 0/0 [ 776.292645] Free swap  =3D 0kB [ =20
> > 776.295532] Total swap =3D 0kB [ 776.298421] 16384 pages RAM [ =20
> > 776.301224] 0 pages HighMem/MovableOnly [  776.305052] 1558 pages=20
> > reserved
> >
> > 6) we have certain questions as below :
> > a) how the kernel memory got exhausted ? at the time of low memory cond=
itions in kernel , are the kernel page flusher threads , which should have =
written dirty pages from page cache to flash disk , not > >executing at rig=
ht time ? is the kernel page reclaim mechanism not executing at right time =
?
>=20
> >I suspect the pages are likely stuck in a state of buffering. In the cas=
e of sockets the packets will get queued up until either they can be servic=
ed or the maximum size of the receive buffer as been exceeded >and they are=
 dropped.
>=20
> My concern here is that why the reclaim procedure has not triggered ?

>It has triggered.  1281 pages are under writeback.
Thanks for the reply .

Also , on target , cat /proc/sys/vm/min_free_kbytes =3D 965 .  As per https=
://www.kernel.org/doc/Documentation/sysctl/vm.txt  ,=20
the minimum value min_free_kbytes  should be set must be 1024 .=20
is this min_free_kbytes setting creating the problem ?

Target is having 64MB memory  , what value is recommended for setting min_f=
ree_kbytes  ?

also is this a problem if the process receiving socket data is run at eleva=
ted priority ( we set it firstly  chrt -r 20 and then changed it later to r=
enice -n -20)
I observed lru-add-drain , writeback threads were executing at normal prior=
ity .











