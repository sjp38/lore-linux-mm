Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05D12C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:43:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A28332190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:43:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=mit.edu header.i=@mit.edu header.b="peCBFvQ8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A28332190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DB798E0002; Wed, 13 Feb 2019 10:43:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C1B8E0001; Wed, 13 Feb 2019 10:43:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52D1A8E0002; Wed, 13 Feb 2019 10:43:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE3A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:43:14 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f5so1926390pgh.14
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:43:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9lnyQ7AVnbrGfnKtwlVFpwOKm7zcHoxbOluiOFqFf6k=;
        b=bwbXPUuRV0iTp7J5J8Ux8I9695jJVryfi3oixz7p0HEKNlsJ+DJDQU8+pX3cMYsrxp
         u3ifV2gJAspjDdM3uznT/t7MzpG3iXxG0k8ULer9tn8GW0nw0I/jyqHOCYx9Xi9MAJrO
         mPcqsmPXVQY3T524rM+GVOQsF3SFyP2FKjF67ufB8seK8q+Z2le2TKSpIMd2S4hvXmLT
         ACRuCaiOMW9brk6brvoKJPw6afKAqPuiRDRQJ4Ju0GS62uaWI71G6ZLGmf1ycZ2YuTAB
         A7zpKNG1yRBYAoZrrtfXGbuX8aX0JpEFUUb/xcfeuJZ0ozAZ9k66YoBV7jXu1PoHqUIc
         wqGg==
X-Gm-Message-State: AHQUAubBLyV1FH3jJAs46Qt2LQJEocF+IF+ebsNUFJkJ4IjVcc0aU/l6
	/ruj0+mBV5Sqh/9BD7TXM8VGz4xnTsNmLnQPBqoilOaL+KePTBwDutiIqiv028REUUzU7DQz5Sa
	1+WwUExMynJB+3jdvNo7nt5FC5WlU9LPdZvLNRYMkh09/DerrROKG6gAsrbwUadfJgg==
X-Received: by 2002:a63:d50f:: with SMTP id c15mr989415pgg.287.1550072593622;
        Wed, 13 Feb 2019 07:43:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ1VO1CaO0jdCxmGAya66iXNFoGPz3b22foMVezbZNcqadUe9iL1ToumjibNkmuIlLi6/An
X-Received: by 2002:a63:d50f:: with SMTP id c15mr989380pgg.287.1550072592844;
        Wed, 13 Feb 2019 07:43:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550072592; cv=none;
        d=google.com; s=arc-20160816;
        b=py2SylAiTpIvVi5SasmGduQBOsQRL/oXSAPZnaxRRtf/MVmqcCoSX4oy1zMe38quEn
         bzUYrJUcy8fCvVL3Pi9AXuHQD9v0OIVeiYkwW75WmtNKOAk8EcwBA3mo36GGM8onCjNd
         qxfZ5PH7yfhsNcurJ7vX7OyC/Wo57SxykkNfCCuWXVnTD0KdPxtZaJUq1gxbiK06n79H
         xkKF2uZ6xNCeG9lGhx+s1DNj0inLOun+f6fJoDdLDE64z6uLjPUkX2TRR5S7MQgJ8g2z
         1W9TqADLcAZVv+O04PD9NDOLGqFDRD9+19pfwaQw2bUPK98Sb2ctaki9u8yCAY6ZXAG5
         PXaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9lnyQ7AVnbrGfnKtwlVFpwOKm7zcHoxbOluiOFqFf6k=;
        b=DFgJBE2+8cUrYx9RaSOwX2xHNT3yMcVircFV5BsUwoXOvzwVxBrhNgq+cPtqnGy6FI
         5HxaEyBkAKlM2GsorAzYwqDffpBT27Pmb8euv+jEcoXBcCTQrFaQyDt2lJxlZnCO63FK
         KI6BQ71yG79C/G2oWtyR5gY033yxTziD5r8Mw6CjYZRl+1oPfAvBWWUe9coaZrDDNR56
         KGI5uaktCgK8D0atxF8EQCZMmsbNvjxu25Bijj67K57AtM0ge02gGysbPCCi8mnc9/H7
         uwGe5YjZDwIQpbXRlv4Cr8CVV+lASx//pg/yGLWUBRD7Crcr576aE4e7rUUhS1D/5Me9
         1aTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=peCBFvQ8;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.72.110 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720110.outbound.protection.outlook.com. [40.107.72.110])
        by mx.google.com with ESMTPS id b12si15987494pls.32.2019.02.13.07.43.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 07:43:12 -0800 (PST)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 40.107.72.110 as permitted sender) client-ip=40.107.72.110;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=peCBFvQ8;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.72.110 as permitted sender) smtp.mailfrom=tytso@mit.edu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9lnyQ7AVnbrGfnKtwlVFpwOKm7zcHoxbOluiOFqFf6k=;
 b=peCBFvQ8wjKwzdmc8B+EJC71L2CZKFMwEwho8Mt8yVJT+cEIXrlwi9Q2+jerDLe1Hcj+Du4yYUCoquI1NmKMAp5FlBNHGffcQ5XDeXVWvCPPth4AA50dKuGN5GvIcSFMWi8Ykbtf8kLWOrjxDyt/GLN1dDSxt8LbfhQHktV5lfA=
Received: from DM5PR0101CA0003.prod.exchangelabs.com (2603:10b6:4:28::16) by
 DM6PR01MB5593.prod.exchangelabs.com (2603:10b6:5:156::29) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Wed, 13 Feb 2019 15:43:10 +0000
Received: from DM3NAM03FT054.eop-NAM03.prod.protection.outlook.com
 (2a01:111:f400:7e49::207) by DM5PR0101CA0003.outlook.office365.com
 (2603:10b6:4:28::16) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1622.16 via Frontend
 Transport; Wed, 13 Feb 2019 15:43:10 +0000
Authentication-Results: spf=pass (sender IP is 18.9.28.11)
 smtp.mailfrom=mit.edu; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=mit.edu;
Received-SPF: Pass (protection.outlook.com: domain of mit.edu designates
 18.9.28.11 as permitted sender) receiver=protection.outlook.com;
 client-ip=18.9.28.11; helo=outgoing.mit.edu;
Received: from outgoing.mit.edu (18.9.28.11) by
 DM3NAM03FT054.mail.protection.outlook.com (10.152.83.223) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.10 via Frontend Transport; Wed, 13 Feb 2019 15:43:09 +0000
Received: from callcc.thunk.org (guestnat-104-133-0-100.corp.google.com [104.133.0.100] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x1DFh3bn024692
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 13 Feb 2019 10:43:07 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 69E227A4EA7; Wed, 13 Feb 2019 10:43:03 -0500 (EST)
Date: Wed, 13 Feb 2019 10:43:03 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
To: Dan Williams <dan.j.williams@intel.com>
CC: Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>,
	<lsf-pc@lists.linux-foundation.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Shutemov,
 Kirill" <kirill.shutemov@intel.com>, "Schofield, Alison"
	<alison.schofield@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>,
	Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Jaegeuk Kim
	<jaegeuk@kernel.org>
Subject: Re: [LSF/MM TOPIC] Memory Encryption on top of filesystems
Message-ID: <20190213154303.GU23000@mit.edu>
References: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com>
 <20190212235114.GM20493@dastard>
 <CAPcyv4jhbYfrdTOyh90-u-gEUV7QEgF_HrNid5w5WbPPGr=axw@mail.gmail.com>
 <20190213021318.GN20493@dastard>
 <CAPcyv4g4vF84Ufrdv8ocwfW3hrvUJ_GaF65AbZyXzaZJQVMjEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAPcyv4g4vF84Ufrdv8ocwfW3hrvUJ_GaF65AbZyXzaZJQVMjEw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-EOPAttributedMessage: 0
X-Forefront-Antispam-Report:
	CIP:18.9.28.11;IPV:CAL;SCL:-1;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(136003)(39860400002)(2980300002)(189003)(199004)(316002)(76176011)(36906005)(93886005)(786003)(86362001)(14444005)(52956003)(90966002)(106466001)(88552002)(54906003)(47776003)(46406003)(16586007)(229853002)(50466002)(106002)(2906002)(6266002)(58126008)(26826003)(6246003)(42186006)(305945005)(4326008)(8936002)(246002)(26005)(186003)(1076003)(23726003)(6916009)(356004)(11346002)(103686004)(2616005)(476003)(33656002)(75432002)(446003)(8676002)(7416002)(97756001)(126002)(336012)(486006)(478600001)(36756003)(18370500001)(42866002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB5593;H:outgoing.mit.edu;FPR:;SPF:Pass;LANG:en;PTR:outgoing-auth-1.mit.edu;MX:1;A:1;
X-Microsoft-Exchange-Diagnostics:
 1;DM3NAM03FT054;1:z1Rs0vwB1vYbX6LXXAIsyLEY73JEPE/kzPTY6U5gLG7hwcUFrj5dp6WRmtmxzU7alpKxhU6FCcN48zXHQv0FsOziC3F/Vp1RItkMqw0IL8Mqd1SD676iqtJ28AddKHVnPTMiaaWJpVeCvb2tH8O0uA==
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 1171eba9-c8bb-407e-5207-08d691c9f4d6
X-Microsoft-Antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4608076)(4709027)(2017052603328)(7153060);SRVR:DM6PR01MB5593;
X-MS-TrafficTypeDiagnostic: DM6PR01MB5593:
X-LD-Processed: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b,ExtAddr
X-Microsoft-Exchange-Diagnostics:
	1;DM6PR01MB5593;20:cUPqseb3/utlwzxhgGf5mNHS+MPqc6vlreNb8vYbr4S3NkVgmelIEgMiJ6pVFbcjrczFVmyc9vItbua6xwyiVYH7GvVXlW1PX4oiq2PBLhMz9Ve6ZhvjYbRxIfZZgrjnhPf8ieFi/DhKtGLQavvvGZUitz8nb5CyHNCR+02fOJQdKO8nYrbhcle43neBS1pdF/EGndjlEqtqviLk/iI+GhG0Hw7bObVTlQqRSW3tFAKx++UgNiATso5WBE+ODikAhmfVSwrYCJ/b4ztUeYhMXM/zSKM77r1AoKepocC0HaBbNx5+OzwbX589EZxS6jeb8uf1kPI3Y4CCuOfxzotVmgoCFg2lvj6XlCmyFxFKB8RN6jrSb1AjScI0yw7Ee1Rk8rg9KQjYF22dvYJU3CuA0q0V6Yn9tzQG2kcrzxqhwFI2XIjapWB11t4B4CQ/sQuRWxSpcRAoSN2DsZpHQn6Q/Yxkk2sMDvTnLkPmy3pAv0NrHSqtJjEu8eIJm77ls4KMr0diDZtLaJVCQWw3J23E9oM/KUohIDy0SMfuHlPQKkkxD+nbJ0Xn7Z5ivuiBoSCJ//5fxt9gktGN7tLx/e90IT7CIod9zTk7LmzZh5uPWic=
X-Microsoft-Antispam-PRVS:
	<DM6PR01MB55936DE67567FA1FA4DEAAD2B5660@DM6PR01MB5593.prod.exchangelabs.com>
X-Forefront-PRVS: 094700CA91
X-Microsoft-Exchange-Diagnostics:
	=?us-ascii?Q?1;DM6PR01MB5593;23:ew1ru7V2XS4N0ojn3dd66wo+FXtIA/ZSKiN51dBLx?=
 =?us-ascii?Q?MjYUWjaDGSJrt5D02mn0DjRXJFM+FLDky/f7HmJ9fCJG3hWJXm4CZlUlt0/W?=
 =?us-ascii?Q?f7feKzTNmrYfHC90ZjSdCMpnaZW+aCg248lxu+3Hnd6un0J4IYp0lwV2T7w1?=
 =?us-ascii?Q?UaVQylzS3IrHAEHvKdhJN64bLrrOGeI72iyAeCiV9VmTL3c/xQ71Yow0IohC?=
 =?us-ascii?Q?ddOcgTJ4Ry+N+zu3I+mTvcpk+Vh7FXMXcQvIbQCB4XJZ4hcUqq0nfyUs/N2T?=
 =?us-ascii?Q?sg2/+UuWKMRe9tus2VBze36GrgEkZ/c+KNPGhRKCpIg/aWHYU7B9xFw2W/AV?=
 =?us-ascii?Q?vGIwQKjnY+L+YZQZOCtOpNXnLSehvnu+6+Mu2P6S7r0Un2dK7nS/PNbijpEv?=
 =?us-ascii?Q?GCfaZ0YITkRn38jscHRKUPp5ltAr4mKXibYeZNFtQikKfvOSYvX5zdwpP9Ao?=
 =?us-ascii?Q?AUJbd0jfT2yNkRcP/3gssnZ4c4Uc8Y0UJXS4oCSNqqrqmBDS3tkZdVhdDDTD?=
 =?us-ascii?Q?Zba18ofQm+K7ozZohvyzudE7zZ/zqRZU6EOLNdBZboOsuxE8qh5rTgmyrqQd?=
 =?us-ascii?Q?HzKiPYCguIQICuCso5zl+2Rqgxh2xYZ9WAIaYnPbadiQeOjgPVN7nLuGuhYP?=
 =?us-ascii?Q?3ysEzPdNpmwBctwdHbvBtF3iCfj6EjTigLJ2QFHVw8x8i6C4/C6sk2PA0WGH?=
 =?us-ascii?Q?dGBqDCulLU8YJHfM2GIScjf9P+8O3uV8xhRlGX6qN9+cvA6XZ/sFEMmJ++6X?=
 =?us-ascii?Q?J+7x4524t8saOxHUF9E/2FWVAf5sGQioCqFZmKdFG7+sU/eihpyxMRhFxa3n?=
 =?us-ascii?Q?e/u/Cq5re5aRA35CIvf3uolc2fHvH3EBRE7a2WBUQtxX50+sinyoKVIs7qiB?=
 =?us-ascii?Q?incE3PRC/X924Zk+IvE6qExA71IIPHgR523GUwobGE4TlhIFnaQdj9XsamBT?=
 =?us-ascii?Q?VCUuY8tPQC4AQV87Vq1weerOeu4DpFhwUESpGqADx3GjEYeaSNiZD18vhloM?=
 =?us-ascii?Q?zW6cuu+siHVX9qkgdU5dCLd39mvBSZIlUUs0SvIBIdUzkDQVt8M0Zczc3rk6?=
 =?us-ascii?Q?qqlbRIoxqC872okkWBWMUx8uZAmGw7OlLyc46Cujs7db5dWLzUSaKJ8pIObR?=
 =?us-ascii?Q?bKBGPt6eEsqJZeXFMXBM/1JPQhV23e4D59vpGOjuAOrMmSCads0rScsd98Rx?=
 =?us-ascii?Q?zak/IafURb6kg9wv+YLx0HQkrh92pAnLFzQwfjp321Ri6+ilM2a6u2cqXUw2?=
 =?us-ascii?Q?Z/aBC12+rTFsJn01BdtxlIGwMncOIzIAahTIk5GEM47CBndgYpAtGGnn0+xZ?=
 =?us-ascii?B?Zz09?=
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	Poy80u0aSVQ4iqh5fJBe7WaUdoeJ2CHauD6m9Y877/ufxN59gUoYJA7NP0KK6Y+UdmGZbk+1zb8ccmu2FqtfFCJ8pbK/I8RqpXuVA9YmdZ7khyoKSRMtUSyH1yNuLqH6bRhU2jT1/WSKm+c5/ZDS0h/I+orRldJsMpZFns8rNpMM+xc7jdzOXZNF6iYxZxmWB8aqTlFyruOGgVvewzF1yX7lS1fZiyyZ4LYxo2sY8Wemp5sazk3bcfcqyzennVches0pF1jWhWgl2hrxlL9aeji6pu/T6y35srR4JPQ7G2LWQqlbnjH6rW2AsBe9EP5cfhwfmae7x/CJZuK4JtFvFytgSvoXnyu7J8XnvZO1qabqk0CbNGjzsNQDArzQaH6C/niY5ba1Vz7PsdilE12rjvlW/1k7rWm7nBvf09xIS8I=
X-OriginatorOrg: mit.edu
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 13 Feb 2019 15:43:09.3934
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 1171eba9-c8bb-407e-5207-08d691c9f4d6
X-MS-Exchange-CrossTenant-Id: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=64afd9ba-0ecf-4acf-bc36-935f6235ba8b;Ip=[18.9.28.11];Helo=[outgoing.mit.edu]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR01MB5593
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 07:31:37PM -0800, Dan Williams wrote:
> > fscrypt encrypt/decrypt is already done at the filesystem/bio
> > interface layer via bounce buffers - it's not a great stretch to
> > push this down a layer so that it can be offloaded to the underlying
> > device if it is hardware encryption capable. fscrypt would really
> > only be used for key management (like needs work to support
> > arbitrary hardware keys) and in filesystem metadata encryption (e.g.
> > filenames) in that case....
> 
> Thanks, yes, fscrypt needs a closer look. As far I can see at a quick
> glance fscrypt has the same physical block inputs for the encryption
> algorithm as MKTME so it seems it could be crafted as a drop in
> accelerator for fscrypt for pmem block devices.

Yes, and in fact this would solve another problem that is currently
being solved in an adhoc fashion, and that's where the
encryption/decryption engine is located between the storage device and
the DMA controller.  This is called an Inline Crypto Engine (ICE), and
it's been done on many mobile devices.

For fscrypt, we want to use to use a different key for each file,
where the per-file key is derived from the per-user key.  (This allows
mutually suspicious users to share a single Chrome OS device; so for
example, if Alice is logged in, she can access her files, but she
willt not be able to access Bob's file.)

So that means we need to pass a key selector (a small integer) into
the struct bio, so that it can be passed to encryption engine.  And we
will need an interface that can either be plumbed through the block
layer or through the memory co ntroller where we can upload a key to
the controller, and get back a key selector which can be passed to an
I/O request.   (Or mapped to a persistent memory range.)

The other important question is how to generate the per-block
Initialization Vector (IV).  There are two ways of doing this; one is
to base the IV on the logical block #, and the other is to base the IV
based on the physical block #.  Normally, fscrypt uses a logical block
number; this allows a file to be defragged, or for the block to be
moved (which is often required for log-structured file systems).  For
the ICE use case, we can't read or write the block without the data
passing through the IV, and it's painful to figure out how to get
logical block number to the ICE, so what the mobile handsets have been
doing is to let the ICE deal with generating the IV, since it has
access to the LBA number since it's located between the flash device
and the DMA engine.

I would imagine that the simple thing to do here for persistent memory
is to base the IV on the persistent memory address for the page.

Cheers,

						- Ted

