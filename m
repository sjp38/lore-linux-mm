Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 692C5C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:02:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D95A320684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:02:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="paIbKxai"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D95A320684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AEE88E0004; Tue,  5 Mar 2019 20:02:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 537838E0001; Tue,  5 Mar 2019 20:02:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B2418E0004; Tue,  5 Mar 2019 20:02:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D348F8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 20:02:48 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y26so5421294edb.4
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 17:02:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=j30qyYyOOtTjp0ZTiZQ78GhxRMBWbRg6hV8WbXpIKGs=;
        b=O1W4teQJmLbCenhQs0FrJg88nSuKTFWGhz7bUKaFNtU0yrMzjmCiHDNn0fPeZDkvkT
         /N1MV43SYQuwvyqPVHpe/Fxv2U4BwUHkGJlqPsjoi8pbQ8Gz0j7tLOMoU5Y2+3QLDxit
         DjjaP93r0TmVoS8WIoxzpIwVm+kp60wdXad6JPylYgMPK8Obv09KcbVWwha08TqiND19
         3rWvTVDtKiaPZxzXCB6an76UxysgdUaT9hJb8Ho2rF4a9p1cuO5rM8hgSdmUB7BZJCSL
         AMAdMDLJJzsBz4Wh3F/4rHqKpik6a4vXhdVZosPsauNE5eO+CpcQPgB+BI+DPQ7iNrRL
         q6/g==
X-Gm-Message-State: APjAAAXJNcW2vGmq1LHhR7i9Gef/L4KIg/RUrsP45NaHI9XfxJhHK3Bk
	O4lTLcP+OZTNRadnsJYom/goBBmyjY6rv1g9YVOjnCmGnvLah3bKXJaRr6sT50UDC+2jPsFhMj+
	TWwis1YpNwfu1QJyfZnanF4vVGvaVWH7ylyrDw567jSIYwkw12v/3c3g6+aYgfh41YQ==
X-Received: by 2002:a50:908e:: with SMTP id c14mr21745455eda.251.1551834168410;
        Tue, 05 Mar 2019 17:02:48 -0800 (PST)
X-Google-Smtp-Source: APXvYqxwBPj+tFaU/KU3jhk8oWOTQMLL2UaajJ8PyUwM497rLLokLSR4CkmJCL94fP7YyhA9sOK2
X-Received: by 2002:a50:908e:: with SMTP id c14mr21745398eda.251.1551834167362;
        Tue, 05 Mar 2019 17:02:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551834167; cv=none;
        d=google.com; s=arc-20160816;
        b=s3vSQH/aONwIprLw4wQ87DTfEM/9FVrxlSws37de2p6Uot0GKS3VfuOSk3dYw+a/q/
         eXKjdJ42DEgCJ96e1UCWMvSkcpIEw+o5v+QZTOuEI5ZANRh+TLiPMPhQNatkXVYEoIvZ
         iZfYssAphOfohoB/TTTSsWqJlXK71NHOnnQLa7X9wp+KzGDuRd4WcNo7PokS81y6UptF
         oyLr8LRyxUtekdqk3uPTHa3WN91NU/ahWwbjRmAMRQriOHqjmRTRGvv5SxreFxp/BAp7
         7NjL1zeCmvzw3s0nXdeByhOrE6mCLh9HBZsL9kQukBgsaW4UxhTs15IRyjOs1KEEvWDo
         83tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=j30qyYyOOtTjp0ZTiZQ78GhxRMBWbRg6hV8WbXpIKGs=;
        b=HKn4k6a72nBI5xeLU3TAk+pHNf3fMtDju17XNhmy/YMBtgpv9d7JOKTjJx7ihLnaHe
         xWll40Jq/ZAmCehT5gyX2rXyF09oauWMgW+HHlX5mH/NcrQ1/WNYoaaWftbzmZpHsCE0
         dXN06aFsiCIm83iUVZbns5i+3aLKKRAykLSEdBmBYK+bMTeWnjOH36veagWNYegF2EOT
         4Er816pSVhdnl3MJLvA3d+C7pMTpx288sJuLmZChoveT6lL1slyfSsmhBDB881wetPY8
         FUIpBsT8u+DOaby2y3IxhX8XL+x+Kg59hw9MUbRzWA34ZC1+cH+3GFfljtqrBVMLleN+
         zh/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=paIbKxai;
       spf=pass (google.com: domain of artemyko@mellanox.com designates 40.107.3.61 as permitted sender) smtp.mailfrom=artemyko@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30061.outbound.protection.outlook.com. [40.107.3.61])
        by mx.google.com with ESMTPS id a18si31340edd.239.2019.03.05.17.02.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Mar 2019 17:02:47 -0800 (PST)
Received-SPF: pass (google.com: domain of artemyko@mellanox.com designates 40.107.3.61 as permitted sender) client-ip=40.107.3.61;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=paIbKxai;
       spf=pass (google.com: domain of artemyko@mellanox.com designates 40.107.3.61 as permitted sender) smtp.mailfrom=artemyko@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=j30qyYyOOtTjp0ZTiZQ78GhxRMBWbRg6hV8WbXpIKGs=;
 b=paIbKxaifNl25YHqfjguwSD8TkDOe5/kySMyccIzrM4lP7dg1lQZ915VoWygMm7nwt30AKQ1wOUhH3Dib90XdXg65pFwMA9uTLEmX2b3lO1a7l/8xQtZHdqlqLp1JMINbAsiZ7VpaF01WkLg+7PdQbLU20m37e8JSikr6I9P1SQ=
Received: from HE1PR05CA0181.eurprd05.prod.outlook.com (2603:10a6:3:f8::29) by
 VI1PR05MB4574.eurprd05.prod.outlook.com (2603:10a6:802:5e::27) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.18; Wed, 6 Mar 2019 01:02:43 +0000
Received: from DB5EUR03FT026.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e0a::205) by HE1PR05CA0181.outlook.office365.com
 (2603:10a6:3:f8::29) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1665.16 via Frontend
 Transport; Wed, 6 Mar 2019 01:02:43 +0000
Authentication-Results: spf=pass (sender IP is 193.47.165.134)
 smtp.mailfrom=mellanox.com; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=pass action=none
 header.from=mellanox.com;
Received-SPF: Pass (protection.outlook.com: domain of mellanox.com designates
 193.47.165.134 as permitted sender) receiver=protection.outlook.com;
 client-ip=193.47.165.134; helo=mtlcas13.mtl.com;
Received: from mtlcas13.mtl.com (193.47.165.134) by
 DB5EUR03FT026.mail.protection.outlook.com (10.152.20.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.20.1643.11 via Frontend Transport; Wed, 6 Mar 2019 01:02:42 +0000
Received: from MTLCAS13.mtl.com (10.0.8.78) by mtlcas13.mtl.com (10.0.8.78)
 with Microsoft SMTP Server (TLS) id 15.0.1178.4; Wed, 6 Mar 2019 03:02:41
 +0200
Received: from MTLCAS01.mtl.com (10.0.8.71) by MTLCAS13.mtl.com (10.0.8.78)
 with Microsoft SMTP Server (TLS) id 15.0.1178.4 via Frontend Transport; Wed,
 6 Mar 2019 03:02:40 +0200
Received: from [172.16.0.120] (172.16.0.120) by MTLCAS01.mtl.com (10.0.8.71)
 with Microsoft SMTP Server (TLS) id 14.3.301.0; Wed, 6 Mar 2019 03:02:37
 +0200
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling
 paths
To: John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Jason
 Gunthorpe" <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
From: Artemy Kovalyov <artemyko@mellanox.com>
Message-ID: <903383a6-f2c9-4a69-83c0-9be9c052d4be@mellanox.com>
Date: Wed, 6 Mar 2019 03:02:36 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [172.16.0.120]
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:193.47.165.134;IPV:NLI;CTRY:IL;EFV:NLI;SFV:NSPM;SFS:(10009020)(39860400002)(396003)(136003)(376002)(346002)(2980300002)(199004)(189003)(14444005)(47776003)(31686004)(126002)(77096007)(446003)(31696002)(26005)(86362001)(486006)(64126003)(36756003)(230700001)(305945005)(8676002)(2616005)(478600001)(106466001)(6246003)(2486003)(23676004)(11346002)(476003)(7736002)(76176011)(53546011)(65806001)(65956001)(67846002)(336012)(81156014)(81166006)(106002)(93886005)(2501003)(5660300002)(16526019)(229853002)(65826007)(58126008)(6116002)(50466002)(3846002)(4326008)(16576012)(316002)(2906002)(186003)(110136005)(356004)(8936002)(54906003)(3940600001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4574;H:mtlcas13.mtl.com;FPR:;SPF:Pass;LANG:en;PTR:mail13.mellanox.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: fae3b9ca-9343-496d-d20f-08d6a1cf7007
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4608103)(4709054)(2017052603328)(7153060)(7193020);SRVR:VI1PR05MB4574;
X-MS-TrafficTypeDiagnostic: VI1PR05MB4574:
X-Microsoft-Exchange-Diagnostics:
	1;VI1PR05MB4574;20:pRU3nLglBonSHO+OT8HXmWmCBMPpXAbSFa7RvgqoJAiJVG8Oify1l6uziLD4ryQebT5/3QOPhcahgi/VLYgCpHkz2nQhE1pPTRF5h5FAYJKYT0/Om3GXME0Nmga0lUFGDyO5kpUIGaywA2Rh8fLeckFuvhEhRZlgcjCD280iiw1LGUuixJTXTxm99K8Dbulvkj1csvbp2IZnpj0bV4oehxLtZme3YucfEvytxI2fZoSyw44id9SCx9SeOSXibus1TLLplRYWREDmBEGMxOUVVAoU5hxZ6x32cXoMj6VWhV1mWxIansO1G7XrkVnvVtbX3dJhkm3oULe1q3LUtJRgdYCBxw78aY/+d6K83NDGJ3Nvk7E9g2s7g8IwdeJyDXG9Fl0ktN3HStXdJJSVRgEtHkMCdSmtD2gs/7C737l1fJ6P+5UaDv+2XkvANhIti/A5Fs8R9Eb3Vc3gl9eMGO1wCLH8/R0jxmnBSYqmNmtSgf1HJnvq6HtBqhRzUD2hA1gf
X-Microsoft-Antispam-PRVS:
	<VI1PR05MB4574E4FAABA6FAE1DFC5BDA2B7730@VI1PR05MB4574.eurprd05.prod.outlook.com>
X-Forefront-PRVS: 0968D37274
X-Microsoft-Exchange-Diagnostics:
	=?utf-8?B?MTtWSTFQUjA1TUI0NTc0OzIzOkdrRUFYSm1ha1NGbUg1YUtVZ09xS0Z6c0pI?=
 =?utf-8?B?ZlhrdG9BZ3g1dHQyVVhzT2VmVHFOcHY5V045TWRrQUtqWExxdWhTL1JzYnFT?=
 =?utf-8?B?RWs0MjVOYzhzV0dLb2xuMlM1c3lyd0J0V29wQWRadTA0T3dqajFUdndwbzFN?=
 =?utf-8?B?ZStIcVV5SDhxUWFGaGhNai96amZsejArdVZFYklsUzg5Q24xTmZhemFPQWlj?=
 =?utf-8?B?MFdhMXJNejg2bDB6L1dNTXFYclRQRTVuRmdaNEtsQ09keXV3WHBKTGdrSno2?=
 =?utf-8?B?cFk5NlhTQVExOWNEaVh6VzlTMlBFZ1RDTkZDZGFtMDZNWjk1MGxSOEZ0Z0dW?=
 =?utf-8?B?cGFFNEhlUVRRcm90K05BYXRhMTBVclBGNHF3RUtFR1V1dFJQVk5IQWNXendu?=
 =?utf-8?B?RkhxeTRJRnlFSndqaUFMN04vR2wxM1V6YXBTTkw0V3hvVmRvbFlGQnBKUEhq?=
 =?utf-8?B?S3ByTEN5bCtTVnRPc1pTYU40OGozSzVzbnJlTFFaWWhQSmNqeGlEVFpjU1lk?=
 =?utf-8?B?aEVKSkliUWNOdjN2M292bHl5ZkFUTlR0K3pGN3dkNFZWRlBWYTNISFVSY3c5?=
 =?utf-8?B?ZVlnZHFKdmNtVVBPU3E5aytHVUw2OC9Qb2llUVRTVFZlS0FTQytpWFM4M0xR?=
 =?utf-8?B?OUVvTnRqYlVpZlpaUmtBNUhST1pxdVBXcHhSeHJPLzh0bmVLamRQcXhXeWJJ?=
 =?utf-8?B?TkRGU21QeGY5bFNIMHJWbDhaK2tBTDVPdDFKVUkxZ2hpOStSRGYraGJkMXhq?=
 =?utf-8?B?Y3o3NkJWVk5CQk5xcUJFTUZ6Y1B5clFrblFWSmVrZDA5RTlHNWxQdUJmUG5s?=
 =?utf-8?B?YXlFeHpPYUlPU29QNm9YeTRaSEJsWWxKcDU3dFZGY3dHeVRZUGFOVWFIcllB?=
 =?utf-8?B?cS9wTVdKL3p1MmtEd0FwT1pZV2hCaUczM1lxM0JZNEJJby9iNEZWbVdOYzh6?=
 =?utf-8?B?RWw3NmI3djB1bzVod2hxZ1FUb0twb0ZMQUpRVTBkdmNNTmd4TnRoWVIyRndl?=
 =?utf-8?B?d01KeU1oeTZGeXZOMnNjWCsxSStmS20wWnU2OFovWG1udnJIaUFaclV1Si84?=
 =?utf-8?B?aDlFQlViWUttcHFKMEhSMjU5eXBGMFpkRXMrcG9VRGdKUlluU1lKYmQxRU1t?=
 =?utf-8?B?SkhNZ0pvQytCQXg0VjhSMm9WQW5Xa01PNnV0NDEwaWJpYXhMZkkyc1lYNjgr?=
 =?utf-8?B?VnlZYmpxa2RubnM1UG5wNWVlWjFFb1ZsZEd2QXU1aDhnS3dDdFNzZjYycUo0?=
 =?utf-8?B?QlloZmJFbEIzMURBSEswL3FBOUhXdHhkWStWZWFQN2w5bFlwZEppbTUzNnNN?=
 =?utf-8?B?SFYxaFlLOGRtZkxoVGpNUVhyd0xYdUZTVyt4Q25IMmFoSEF5ZU16ZVBRaDVX?=
 =?utf-8?B?ZllwVEJVSkhSMkY5K0JVbi9EdUY5N0F6QXNUNXZyTm9YOHlLY2M3V0hBTW5z?=
 =?utf-8?B?RFF3ajhwOHZhN2pKUEQxaUNXWERKckJKWFZzeWxYVWlWbEFLdmdMSVZTcXZD?=
 =?utf-8?B?enRwY2d5Nm03bHB6YjI2aURzNGJWaE1iZ0RQMjdnMk5ObDU5VTlzOE5WWXNH?=
 =?utf-8?B?aldIWUtuQ1JOZkplZ2N3VjlIbjhZRVU3TnJ0cTI5b1JJSVhEUTVJMjhaSHNp?=
 =?utf-8?B?ZnJRYXNiVjhKL0ViSk45NmtDNU9RTm56dEFmeE9qdUZPWEd4bDJoY1NNclo3?=
 =?utf-8?B?T2pISFhtUjloY0o5Rm1KL3ZUWjFiUzJzY1RYTG84cmE2YTdLT2xBZWh4RkpY?=
 =?utf-8?B?ODZzOXlPTXd5S1FnOHhTWlBaY3ByTExkb3ZyNzdsOVFLN3hvbHNWRG54b2di?=
 =?utf-8?Q?XMP7xeUXHqJhv?=
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	FVnAnpy/a5xqdc1PBW/br9v6Z5ccSDVz4lPi+qZty/I6kmFPKpbD0gNGu+uR2LZ7+stWbHNqoljOv8csqLFVguO3iI64y7NnJkxtJb1Zi2kS5xUs9Rqo77qNH3GlAsyMtpB5gAVA+ob2euH3QT6AaHcBqhOvYvf7ll8un1fub0OkAbxlzey9YXisLS+ryxk/2OE0zhAcK6G/buvNbs9s5Bsju6YrRQwEXxkKAG99SXjX6ijz4yPP2GH4bWlM8VLa43Kvr+g0d+0hgEeOL5u9z3t8sWz1u6F40t5hQPwYQ1+efpU2LWP1D2s9bKhF2coCybIQd9tEJpftUJlZ9xZLCalYyfJrGa21RaebSY/SywAn2Yk1qIshoweoLB2O+W2DHqA6otLbiRcezPfqDdqRNSpLjjQVWw+/vEyEf80+M9A=
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 06 Mar 2019 01:02:42.7195
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: fae3b9ca-9343-496d-d20f-08d6a1cf7007
X-MS-Exchange-CrossTenant-Id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=a652971c-7d2e-4d9b-a6a4-d149256f461b;Ip=[193.47.165.134];Helo=[mtlcas13.mtl.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4574
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 00:37, John Hubbard wrote:
> On 3/3/19 1:52 AM, Artemy Kovalyov wrote:
>>
>>
>> On 02/03/2019 21:44, Ira Weiny wrote:
>>>
>>> On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>
>>>> ...
> 
> OK, thanks for explaining! Artemy, while you're here, any thoughts about the
> release_pages, and the change of the starting point, from the other part of the
> patch:
> 
> @@ -684,9 +677,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp,
> u64 user_virt,
> 	mutex_unlock(&umem_odp->umem_mutex);
> 
>    		if (ret < 0) {
> -			/* Release left over pages when handling errors. */
> -			for (++j; j < npages; ++j)
release_pages() is an optimized batch put_page() so it's ok.
but! release starting from page next to one cause failure in 
ib_umem_odp_map_dma_single_page() is correct because failure flow of 
this functions already called put_page().
So release_pages(&local_page_list[j+1], npages - j-1) would be correct.
> -				put_page(local_page_list[j]);
> +			/*
> +			 * Release pages, starting at the the first page
> +			 * that experienced an error.
> +			 */
> +			release_pages(&local_page_list[j], npages - j);
>    			break;
>    		}
>    	}
> 
> ?
> 
> thanks,
> 

