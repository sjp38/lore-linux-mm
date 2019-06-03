Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12CAFC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:12:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE08422C7C
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:12:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=utc.com header.i=@utc.com header.b="ZTRbfD5R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE08422C7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=utc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A7E46B000D; Mon,  3 Jun 2019 11:12:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 559376B000E; Mon,  3 Jun 2019 11:12:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 422366B0266; Mon,  3 Jun 2019 11:12:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA186B000D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 11:12:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d9so13827410pfo.13
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 08:12:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=GVY5gYtm8GBhiLRqXu+3FbYaq7pwf7FHLL/FoCy0MYw=;
        b=QQMbOCjPY1bFtOlwfgccHV/kVYmcyW6Y+hSNTXiTLMafiNKuZ3PAoPXElfssvE66SZ
         iLYbWk24+NnsDmSIQVkZO7fJViThuRmnQIMoKd9FJCAzlDrUXqvVpdwjqN/356Yjpa8O
         5LcGn6nX0NcWRLiYg8rq2vkOCFpnNiPViDqBGAL07GP7KwZyNnfpPgNMYPz7WA8cCWWA
         0eNJB+ZCBHNGTAHt4BxX/OOhkLIL0mRWmz1u7eBVC+OBfHauZQIwBuaS8YAAMXuiozJi
         VwidpAa4pvjeuynwWWxsNvZ5CSEPguR/XYULmo+8OAsvI5FR7Cj+yWD61nzS1U9NTrsF
         Uj3w==
X-Gm-Message-State: APjAAAWx4+RQI2TlnQc7ickvGetlOd7lRpUFhtYorhNjOTVDPfHMXzMc
	bdJpnCUGMb7uWK1As2Sn/H/uhUsYMjhkZCKZgPIp2/VAtVEbDmDcZ0/7CuIZGKc2G8aHUGNFxbU
	X3MNJsvyml2F9q9h4LWiteXeFidmx2erHv9rrsHuMphRnsb/kzrB4uM3yDgZPVeY0oQ==
X-Received: by 2002:a63:f10e:: with SMTP id f14mr28739106pgi.226.1559574747515;
        Mon, 03 Jun 2019 08:12:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLdQaRUX1zv5B0tBBxzKX1upSSfGeYBWinddih9vfvQUAANwJkaybfr2o5el1sxxvPjRto
X-Received: by 2002:a63:f10e:: with SMTP id f14mr28738980pgi.226.1559574746460;
        Mon, 03 Jun 2019 08:12:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559574746; cv=none;
        d=google.com; s=arc-20160816;
        b=fl7o11eXJynx7bNszEReSOj2TMRVM6AARaQhRUMEvPlsAwNSpqdV+A+tU6aHwccTm7
         AyZ1P1CUNacnOXOpYItcL1XHJL9gg/gVeSl2DVqz20iyDfhqLTJr941Rs3JKv+gCGF0X
         gMh0Ttfi+Ypfma5+rkHaYPs7K9Zccjf/DszlUbk0bzIsHqEe0MJJNIG5ZcoxcaVJPC9G
         4SZ7/VqezDq/YBrPcRJmSBA8zEBbTxxluuOx2t7S3Oubpkrwv2yuVWAkGN/XEOhpc82W
         cCSIEuDW2Hb3J6F2PofxwUB6mgCDsPLUxbD2VMdYnaQ4JQnBqn/ftJ+oalyQE/+3zNhX
         TCZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=GVY5gYtm8GBhiLRqXu+3FbYaq7pwf7FHLL/FoCy0MYw=;
        b=tYhKiiGzvTM66Tgo0rw5DPN44UA4pXSVWu5yvip3SIvohoXcDnddIgYCDuhiVhVQ78
         MFclzgy/BgwzGVOHaFmNX0dLjWZj8qLIRE6Jo7n9pG9wgN83DzfnlLMsn2LhgVIjrT0g
         UltMr+8bjoFs+Uw5Azn5Wr3n3NikXKGGYc/m6H+4jiZtQZD9Rwka4yEGrgI+Z6ft0VMp
         WiFdl/n7avABsd1hydBqnsWc9auC7o1p0xzj4a1gj3wFVYpBI5etVrYFVUlT6G4NT3Q6
         NANpz4dltUKn3g2298HzY4yik8kaAhVOML83Um9Hjn0VtV/KGHiF/V8acAlmsA0owJC4
         cl4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@utc.com header.s=POD040618 header.b=ZTRbfD5R;
       spf=pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) smtp.mailfrom=Amit.Nagal@utc.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=utc.com
Received: from mx0a-00105401.pphosted.com (mx0a-00105401.pphosted.com. [67.231.144.184])
        by mx.google.com with ESMTPS id t16si20574289plm.65.2019.06.03.08.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 08:12:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) client-ip=67.231.144.184;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@utc.com header.s=POD040618 header.b=ZTRbfD5R;
       spf=pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) smtp.mailfrom=Amit.Nagal@utc.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=utc.com
Received: from pps.filterd (m0078137.ppops.net [127.0.0.1])
	by mx0a-00105401.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x53FB3dQ040125;
	Mon, 3 Jun 2019 11:12:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=utc.com; h=from : to : cc : subject
 : date : message-id : references : content-type :
 content-transfer-encoding : mime-version; s=POD040618;
 bh=GVY5gYtm8GBhiLRqXu+3FbYaq7pwf7FHLL/FoCy0MYw=;
 b=ZTRbfD5RyCngQJDIEyWH/7gG4tTwjlMOUm3ReLSkvuIPEcXfYMCoBTHnlwn5U7TU9JKW
 wTRw3zGO/ieUMuPN129PxAeS2ZWHrp2aNTJIpUB1O62MLLiuvBreSOTl20DPguyoq4Zx
 CWwEZ/3rxrAoZ0H5gkOwCfkcBCUX7XzhHJdpTRcBkDR7rLRLhsEAjltAfYaz7SxNnzCa
 fXKqWIGi9iGZPKltgMwxBVQZLtF6j3+Lm0SsjkMXwfAbAJKH+VBVDJmcOdWVCUS0GRyM
 1Sz4k6yeuAImmXBwKQIOnaL0ZsVrTwnCegnXHBaYucaJQ1cOXFwpSKNOIqvnPOrIa7zD kQ== 
Received: from xmnpv39.utc.com ([167.17.255.19])
	by mx0a-00105401.pphosted.com with ESMTP id 2sw4nbt9w2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 03 Jun 2019 11:12:20 -0400
Received: from uusmna1q.utc.com (uusmna1q.utc.com [159.82.219.65])
	by xmnpv39.utc.com (8.16.0.27/8.16.0.27) with ESMTPS id x53FCJjk147790
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 3 Jun 2019 11:12:19 -0400
Received: from UUSTOE13.utcmail.com (UUSTOE13.utcmail.com [10.221.3.20])
	by uusmna1q.utc.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id x53FCI5W020052
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=OK);
	Mon, 3 Jun 2019 11:12:18 -0400
Received: from UUSALE1A.utcmail.com (10.220.3.27) by UUSTOE13.utcmail.com
 (10.221.3.20) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 3 Jun
 2019 10:12:17 -0500
Received: from UUSALE1A.utcmail.com ([10.220.5.27]) by UUSALE1A.utcmail.com
 ([10.220.5.27]) with mapi id 15.00.1473.003; Mon, 3 Jun 2019 11:12:17 -0400
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
Thread-Index: AdUXwJaEVv2cRvqaQPqGQFhwqLYB3QAWIwGAAGydulAAFtsUAAADqGyAAAXvgBA=
Date: Mon, 3 Jun 2019 15:12:17 +0000
Message-ID: <8e23b0efaf0e43f2aa0a1fc4846f6b02@UUSALE1A.utcmail.com>
References: <09c5d10e9d6b4c258b22db23e7a17513@UUSALE1A.utcmail.com>
 <CAKgT0UfoLDxL_8QkF_fuUK-2-6KGFr5y=2_nRZCNc_u+d+LCrg@mail.gmail.com>
 <6ec47a90f5b047dabe4028ca90bb74ab@UUSALE1A.utcmail.com>
 <20190603121138.GC23346@bombadil.infradead.org> 
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
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906030106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



From: Matthew Wilcox [mailto:willy@infradead.org]
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
> > local_pcp:24kB free_cma:0kB [  776.265406] lowmem_reserve[]: 0 0 [=20
> > 776.268761] Normal: 7*4kB (H) 5*8kB (H) 7*16kB (H) 5*32kB (H) 6*64kB
> > (H) 2*128kB (H) 2*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D=20
> > 1492kB
> > 10071 total pagecache pages
> > [  776.284124] 0 pages in swap cache [  776.287446] Swap cache
> > stats: add 0, delete 0, find 0/0 [ 776.292645] Free swap  =3D 0kB [=20
> > 776.295532] Total swap =3D 0kB [ 776.298421] 16384 pages RAM [=20
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
://www.kernel.org/doc/Documentation/sysctl/vm.txt  , the minimum value min_=
free_kbytes  should be set must be 1024 .=20
is this min_free_kbytes setting creating the problem ?

Target is having 64MB memory  , what value is recommended for setting min_f=
ree_kbytes  ?

also is this a problem if the process receiving socket data is run at eleva=
ted priority ( we set it firstly  chrt -r 20 and then changed it later to r=
enice -n -20) I observed lru-add-drain , writeback threads were executing a=
t normal priority .

what I mean above is 2 separate iterations for process priority settings ( =
1st iteration :: chrt -r 20  , 2nd iteration : renice -n -20 , there was no=
 iteration in which both chrt and renice were used together) .=20
although in  both priority settings , we got the page allocation failure pr=
oblem .











