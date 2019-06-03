Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C46BEC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 10:32:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 526EB27F4E
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 10:32:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=utc.com header.i=@utc.com header.b="gRC/rgfx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 526EB27F4E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=utc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4BC16B0007; Mon,  3 Jun 2019 06:32:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A22886B000D; Mon,  3 Jun 2019 06:32:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C2FC6B0269; Mon,  3 Jun 2019 06:32:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFFA6B0007
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 06:32:42 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d19so11537468pls.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 03:32:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=f8BgBsUZYh6IvHh3G7guAXejK8r8H5Sax29NiNj6zT4=;
        b=phdAYs/70e/veTWMnreuavozfuGSMLusjpTUgQyCRJSXCmD3xoCIDA54cDQJx1IHUK
         K0+n/GpV2iu5n//7UNnou/JJobyEQsY9GguTo91kM+MWBzUqbQAnwK4mJ5qr8Yl4njKa
         kprmbTRB6+RFgu3I6lSJ1q/30m0QSt3PO/riRz6Z+kQwdPGas7VUydwQgjysSiHx0ca8
         IfYnXu6ZMXgYusTXWh+gCOQ6QvL0Av0cNPrxw/WnBoy67KcsXv1TZcjL9Gxf0XyugS4I
         3ktBDzuqylgEVGmJ1IVfiyfV4n4kU9QKUWRi66O+m4hGMdmnwHiHZO+NHVJrZJCZqkEF
         oqhg==
X-Gm-Message-State: APjAAAW6q5cY3Jy3YvkuqX4ZFVrnoTVjTIwfyKC0ehZy/oInXJoKx5jT
	R/VTO979F3cm+7Jh9B5EN0SMtCT1pFmrlXCdhUwbZHJyQSYOfAJ9JGTaQCV2VzB8hMn+0SxnQCd
	1Z33qj0J94EZhcZx8In6tn5pVQTUex4+V1iCuiN+ftbcm7h3huRVQcHbkEsjiZcEz+w==
X-Received: by 2002:a62:e205:: with SMTP id a5mr30250473pfi.40.1559557961786;
        Mon, 03 Jun 2019 03:32:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPIRnLeQK2qJy81s+geNxFrFXLdX1/BZNL7ezE1hPLHc9HFwYgy/FgpkTrkVrDYc3OYdaz
X-Received: by 2002:a62:e205:: with SMTP id a5mr30250346pfi.40.1559557960728;
        Mon, 03 Jun 2019 03:32:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559557960; cv=none;
        d=google.com; s=arc-20160816;
        b=GisBRE6JSZV+dbwwhosMLmbfEOM7JWtE7EJjiMooDL+ve5ksVAGzy+HYveeubA2+Pn
         t+sQo0CZC9+iAQ62UGQdo4f1E/TTAim+NtVAc1gCuAivi+up1DNKtOc+x+nD1dmyb+bS
         uKlWljGkaPnOQLVZv5JyKsT+s+DFRHwkx7imY0kk4lc0rqi+YW9g6disrGWB6rsIC3Ut
         HCYUsHf2Tv8r1vXiOKmCzPHEVBQkm1CXEl9fvBYPWrMudpqdqw6OgbKaKbDe1gUjldW+
         nzNlXcqR5pTXTkGei5Ec9470q9B2OrkiDuqSLlqnXHSjSCGiMGItmKK5ekmSADydV+w0
         vKZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=f8BgBsUZYh6IvHh3G7guAXejK8r8H5Sax29NiNj6zT4=;
        b=bjV3rEwamusXWxcxHPY0AkUMMSZSynJCBjWXrUrUWXfGdMKuNbpYi0m3U0wgUKWZIa
         l5T4ihvRQafvPin+V/dZxxfGlpPmRibg8RreCgam91pXGqYxJIdQ+b9uBdp+T7dTRGS9
         AOL91mQg6JwZ6dK3hHZ0Yc0FucYz6WLILaIZ1zl9Zn/7zjPqSBd0PKComkCsmwrwIv51
         fP6NASHsUEuC7oX3NN5kQB+scYzc9JwGznr6jReOCwQDEVTqHB6QxqCjK13Lok0+IAHN
         +7e+O33n7YYobJG+oZfuTJhSuV3c2wPAVldhnoY/0DADdqtfN9aXr+e8Sb4Zf0K41Pzf
         9npQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@utc.com header.s=POD040618 header.b="gRC/rgfx";
       spf=pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) smtp.mailfrom=Amit.Nagal@utc.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=utc.com
Received: from mx0a-00105401.pphosted.com (mx0a-00105401.pphosted.com. [67.231.144.184])
        by mx.google.com with ESMTPS id l21si1387630pgb.409.2019.06.03.03.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 03:32:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) client-ip=67.231.144.184;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@utc.com header.s=POD040618 header.b="gRC/rgfx";
       spf=pass (google.com: domain of amit.nagal@utc.com designates 67.231.144.184 as permitted sender) smtp.mailfrom=Amit.Nagal@utc.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=utc.com
Received: from pps.filterd (m0078137.ppops.net [127.0.0.1])
	by mx0a-00105401.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x53AUiec024221;
	Mon, 3 Jun 2019 06:32:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=utc.com; h=from : to : cc : subject
 : date : message-id : references : content-type :
 content-transfer-encoding : mime-version; s=POD040618;
 bh=f8BgBsUZYh6IvHh3G7guAXejK8r8H5Sax29NiNj6zT4=;
 b=gRC/rgfxnyG2qtr5HZsl/vtkw8vZf97jNb6/swSqMBoO1QJuLf76Ky40chBWRv6nG6bu
 FmWL45oSrNc/8r1IN5QX304wlySFr2t1jGIwRLQ0cstLvSkY7dTuwqEaFgERcUrwQ9zx
 gDT2Fd4c+7H3zKb+JVX/FTNJBcLqOWTxCbhiAbxGHTkSdkehTYla9WGu1128bB1sQHs5
 6CLkQnPE+feJwbxN8loseSJ6XOIVEpTDsE+W4j+azdhsaBHwrQ2fiS1fKM93776A2Ki2
 UaV10dGxg6N5qPL5OwIFUMUaHRXNwNtJz79RvH6Y7HRciJsg48mybD24U1nA3MNP9cRW FQ== 
Received: from xnwpv37.utc.com ([167.17.239.17])
	by mx0a-00105401.pphosted.com with ESMTP id 2svy1a23mm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 03 Jun 2019 06:32:29 -0400
Received: from uusnwa7g.corp.utc.com (uusnwa7g.corp.utc.com [159.82.101.105])
	by xnwpv37.utc.com (8.16.0.27/8.16.0.27) with ESMTPS id x53AWSat181263
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 3 Jun 2019 06:32:28 -0400
Received: from UUSTOE0W.utcmail.com (UUSTOE0W.utcmail.com [10.221.3.13])
	by uusnwa7g.corp.utc.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id x53AWNCE005177
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=OK);
	Mon, 3 Jun 2019 06:32:25 -0400
Received: from UUSALE1A.utcmail.com (10.220.3.27) by UUSTOE0W.utcmail.com
 (10.221.3.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 3 Jun
 2019 05:32:22 -0500
Received: from UUSALE1A.utcmail.com ([10.220.5.27]) by UUSALE1A.utcmail.com
 ([10.220.5.27]) with mapi id 15.00.1473.003; Mon, 3 Jun 2019 06:32:22 -0400
From: "Nagal, Amit               UTC CCS" <Amit.Nagal@utc.com>
To: Matthew Wilcox <willy@infradead.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "CHAWLA, RITU              UTC
 CCS" <RITU.CHAWLA@utc.com>,
        "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>,
        "Netter, Christian M       UTC CCS"
	<christian.Netter@fs.UTC.COM>
Subject: RE: [External] Re: linux kernel page allocation failure and tuning of
 page cache
Thread-Topic: [External] Re: linux kernel page allocation failure and tuning
 of page cache
Thread-Index: AdUXwJaEVv2cRvqaQPqGQFhwqLYB3QASEIWAAHE1M4AACmMPEA==
Date: Mon, 3 Jun 2019 10:32:22 +0000
Message-ID: <4b58a8b546334a0d8cdae9a56af29f53@UUSALE1A.utcmail.com>
References: <09c5d10e9d6b4c258b22db23e7a17513@UUSALE1A.utcmail.com>
 <20190531193035.GB15496@bombadil.infradead.org> 
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.220.3.243]
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Proofpoint-Spam-Details: rule=outbound_default_notspam policy=outbound_default score=0
 priorityscore=1501 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0
 spamscore=0 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906030078
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



-----Original Message-----
From: Nagal, Amit UTC CCS=20
Sent: Monday, June 3, 2019 11:08 AM
To: 'Matthew Wilcox' <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; CHAWLA, RITU UTC CCS =
<RITU.CHAWLA@utc.com>; netdev@vger.kernel.org; Netter, Christian M UTC CCS =
<christian.Netter@fs.UTC.COM>
Subject: RE: [External] Re: linux kernel page allocation failure and tuning=
 of page cache



-----Original Message-----
From: Matthew Wilcox [mailto:willy@infradead.org]
Sent: Saturday, June 1, 2019 1:01 AM
To: Nagal, Amit UTC CCS <Amit.Nagal@utc.com>
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; CHAWLA, RITU UTC CCS =
<RITU.CHAWLA@utc.com>; netdev@vger.kernel.org
Subject: [External] Re: linux kernel page allocation failure and tuning of =
page cache

> 1) the platform is low memory platform having memory 64MB.
>=20
> 2)  we are doing around 45MB TCP data transfer from PC to target using ne=
tcat utility .On Target , a process receives data over socket and writes th=
e data to flash disk .

>I think your network is faster than your disk ...

>Ok . I need to check it . But how does this affect page reclaim procedure =
.

> 5) sometimes , we observed kernel memory getting exhausted as page alloca=
tion failure happens in kernel  with the backtrace is printed below :
> # [  775.947949] nc.traditional: page allocation failure: order:0,
> mode:0x2080020(GFP_ATOMIC)

>We're in the soft interrupt handler at this point, so we have very few opt=
ions for freeing memory; we can't wait for I/O to complete, for example.

>That said, this is a TCP connection.  We could drop the packet silently wi=
thout such a noisy warning.  Perhaps just collect statistics on how many pa=
ckets we dropped due to a low memory situation.

                                           total       used       free     =
shared    buffers     cached
             Mem:                     57         56               1        =
  0              0                  20
-/+ buffers/cache:         35         22
Swap:                                    0          0                 0
eth0      Link encap:Ethernet  HWaddr D6:8C:FD:9D:35:AC
          inet addr:169.254.1.1  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::d48c:fdff:fe9d:35ac/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8466 errors:1 dropped:0 overruns:3 frame:5
          TX packets:1085 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:12230677 (11.6 MiB)  TX bytes:107425 (104.9 KiB)
          Interrupt:77 Base address:0x3000

Not too many packet drops seem to happen . =20


> [  775.956362] CPU: 0 PID: 1288 Comm: nc.traditional Tainted: G          =
 O    4.9.123-pic6-g31a13de-dirty #19
> [  775.966085] Hardware name: Generic R7S72100 (Flattened Device Tree)=20
> [  775.972501] [<c0109829>] (unwind_backtrace) from [<c010796f>]
> (show_stack+0xb/0xc) [  775.980118] [<c010796f>] (show_stack) from=20
> [<c0151de3>] (warn_alloc+0x89/0xba) [  775.987361] [<c0151de3>]
> (warn_alloc) from [<c0152043>] (__alloc_pages_nodemask+0x1eb/0x634)
> [  775.995790] [<c0152043>] (__alloc_pages_nodemask) from [<c0152523>]
> (__alloc_page_frag+0x39/0xde) [  776.004685] [<c0152523>]
> (__alloc_page_frag) from [<c03190f1>] (__netdev_alloc_skb+0x51/0xb0) [=20
> 776.013217] [<c03190f1>] (__netdev_alloc_skb) from [<c02c1b6f>]
> (sh_eth_poll+0xbf/0x3c0) [  776.021342] [<c02c1b6f>] (sh_eth_poll)=20
> from [<c031fd8f>] (net_rx_action+0x77/0x170) [  776.029051]=20
> [<c031fd8f>] (net_rx_action) from [<c011238f>]
> (__do_softirq+0x107/0x160) [  776.036896] [<c011238f>] (__do_softirq)=20
> from [<c0112589>] (irq_exit+0x5d/0x80) [  776.044165] [<c0112589>]
> (irq_exit) from [<c012f4db>] (__handle_domain_irq+0x57/0x8c) [  776.05200=
7] [<c012f4db>] (__handle_domain_irq) from [<c01012e1>] (gic_handle_irq+0x3=
1/0x48) [  776.060362] [<c01012e1>] (gic_handle_irq) from [<c0108025>] (__i=
rq_svc+0x65/0xac) [  776.067835] Exception stack(0xc1cafd70 to 0xc1cafdb8)
> [  776.072876] fd60:                                     0002751c c1dec6a=
0 0000000c 521c3be5
> [  776.081042] fd80: 56feb08e f64823a6 ffb35f7b feab513d f9cb0643=20
> 0000056c c1caff10 ffffe000 [  776.089204] fda0: b1f49160 c1cafdc4
> c180c677 c0234ace 200e0033 ffffffff [  776.095816] [<c0108025>]
> (__irq_svc) from [<c0234ace>] (__copy_to_user_std+0x7e/0x430) [=20
> 776.103796] [<c0234ace>] (__copy_to_user_std) from [<c0241715>]
> (copy_page_to_iter+0x105/0x250) [  776.112503] [<c0241715>]
> (copy_page_to_iter) from [<c0319aeb>]
> (skb_copy_datagram_iter+0xa3/0x108)
> [  776.121469] [<c0319aeb>] (skb_copy_datagram_iter) from [<c03443a7>]
> (tcp_recvmsg+0x3ab/0x5f4) [  776.130045] [<c03443a7>] (tcp_recvmsg)=20
> from [<c035e249>] (inet_recvmsg+0x21/0x2c) [  776.137576] [<c035e249>]
> (inet_recvmsg) from [<c031009f>] (sock_read_iter+0x51/0x6e) [=20
> 776.145384] [<c031009f>] (sock_read_iter) from [<c017795d>]
> (__vfs_read+0x97/0xb0) [  776.152967] [<c017795d>] (__vfs_read) from=20
> [<c01781d9>] (vfs_read+0x51/0xb0) [  776.159983] [<c01781d9>]
> (vfs_read) from [<c0178aab>] (SyS_read+0x27/0x52) [  776.166837] [<c0178a=
ab>] (SyS_read) from [<c0105261>] (ret_fast_syscall+0x1/0x54) [  776.174308=
] Mem-Info:
> [  776.176650] active_anon:2037 inactive_anon:23 isolated_anon:0 [=20
> 776.176650]  active_file:2636 inactive_file:7391 isolated_file:32 [=20
> 776.176650]  unevictable:0 dirty:1366 writeback:1281 unstable:0

>Almost all the dirty pages are under writeback at this point.

> [  776.176650]  slab_reclaimable:719 slab_unreclaimable:724 [=20
> 776.176650]  mapped:1990 shmem:26 pagetables:159 bounce:0 [=20
> 776.176650]  free:373 free_pcp:6 free_cma:0

>We have 373 free pages, but refused to allocate one of them to GFP_ATOMIC?
>I don't understand why that failed.  We also didn't try to steal an inacti=
ve_file or inactive_anon page, which seems like an obvious thing we might w=
ant to do.

>Yes that's where I am concerned . we do not have swap device so I am assum=
ing perhaps inactive_anon pages are not stolen , but inactive_file pages co=
uld have been used .=20

> [  776.209062] Node 0 active_anon:8148kB inactive_anon:92kB=20
> active_file:10544kB inactive_file:29564kB unevictable:0kB=20
> isolated(anon):0kB isolated(file):128kB mapped:7960kB dirty:5464kB=20
> writeback:5124kB shmem:104kB writeback_tmp:0kB unstable:0kB
> pages_scanned:0 all_unreclaimable? no [  776.233602] Normal=20
> free:1492kB min:964kB low:1204kB high:1444kB active_anon:8148kB=20
> inactive_anon:92kB active_file:10544kB inactive_file:29564kB=20
> unevictable:0kB writepending:10588kB present:65536kB managed:59304kB=20
> mlocked:0kB slab_reclaimable:2876kB slab_unreclaimable:2896kB=20
> kernel_stack:1152kB pagetables:636kB bounce:0kB free_pcp:24kB=20
> local_pcp:24kB free_cma:0kB [  776.265406] lowmem_reserve[]: 0 0 [=20
> 776.268761] Normal: 7*4kB (H) 5*8kB (H) 7*16kB (H) 5*32kB (H) 6*64kB
> (H) 2*128kB (H) 2*256kB (H) 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D=20
> 1492kB
> 10071 total pagecache pages
> [  776.284124] 0 pages in swap cache
> [  776.287446] Swap cache stats: add 0, delete 0, find 0/0 [=20
> 776.292645] Free swap  =3D 0kB [  776.295532] Total swap =3D 0kB [=20
> 776.298421] 16384 pages RAM [  776.301224] 0 pages HighMem/MovableOnly=20
> [  776.305052] 1558 pages reserved

