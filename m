Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96402C31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 01:41:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 594CC20B7C
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 01:41:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="OLRFKsHo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 594CC20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13C806B0006; Fri,  2 Aug 2019 21:41:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EFE06B0008; Fri,  2 Aug 2019 21:41:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1E3E6B000A; Fri,  2 Aug 2019 21:41:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAEE86B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 21:41:41 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so42677138plo.6
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 18:41:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=zc1wJBCk6oa4TZJ5kpnxYLs8I/mCQFC0KqXiV/MQqAc=;
        b=ONk6uip+yxl8uO20TnIJjEU8N0DNNjV8CtrOClcGKkB7jxyl0x08gfCvno9Oz50FT5
         XUTNT2st+/Ojj0HGZLqaJBZ+CEaQftg5xWzVkF/n084JmaI+F2n2ugT9uWpnFYL8CXmc
         3xIkd6gAR3ryS6sQEKBuPWUd61NLDPiIZTEXWmOUsZSpYTkE23JOJWV5mvTTvNDo4kkQ
         ZW4e7w1vB6zYGoEsBmK7SUlLRlMPM8tzQ0IT4unzEVuRXxp+VgcnqsqQUPpOGQsTPnzr
         eB/Yhj+3D28fVN2Mk2tqpHdotLjgKYEGTj1oCuJr+DPfaIIH7ib974HV/zW7CrMcZLIp
         DJoQ==
X-Gm-Message-State: APjAAAUzYPKKGoF4jn6bpSzpbfcpgAdZTKNIfY5Bvv+WwGrhU7YFZxQ/
	bblt4u49z9T0B/S4ufAahrgTtrDwMtpmw0XLhgqhiQLbJAsXeNy1LZR9OlWRYHj+pwK+bKHASl5
	nSI3a046e0HtrAZsRJBpFWgJZ+tDnSJQcAqg4fajjPJ7Dv11MxsbVcppBluEghlPbeA==
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr129932461plp.95.1564796501290;
        Fri, 02 Aug 2019 18:41:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcVIA72TpHyjJDXH1KQ3QLnDHYigq/BhXP+N/kLUfD+OrhboBfLNzrs7TjhvUPzER2CCpp
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr129932429plp.95.1564796500484;
        Fri, 02 Aug 2019 18:41:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564796500; cv=none;
        d=google.com; s=arc-20160816;
        b=oi0Clo6bcLgoMUb1i7xwY5GDm0bb4g0S08f8T6xezjFU7fhFuBkEXPoRUU6R3xrYHB
         EF9FvAnvWUD2jec7FHupuM/IyyZWtxwcmH4wgMFXJj5CA50hvozjfTohfRwpNgUV7iXP
         oH1XPNSRiiPXhXJ4Jlg5kB4Lc7K1TxtQJZD0Dk6N2cnm0Tihel/7cTPF9rT4VCH/gbdZ
         rGTp/jbk9MW+1LqLwYjJ4qsGnphR7llSoSfJwhVU4g72Z8G0Rb4nJKo7fam73lueAIgL
         ddzKhDxeTQ0hOZSfKTTIiJulkpZVkzqkgz0yIow9YLP/vRSw6pfL2eP+yYtZLI+SKcPc
         +k6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=zc1wJBCk6oa4TZJ5kpnxYLs8I/mCQFC0KqXiV/MQqAc=;
        b=G3PjO45QZYEa51hdvKDm+nSkjc6DLNJ0b38DvVbtWY0dPmDbhfZ6ousQBSrApxPq+0
         jebphk6uSWwoh2N3lcaLLfPXoW7OGiYQQpfaCkT0Mhlg6ubIL2nUxgKy+eOE2yo/n/EM
         3OZFwXZZMD3jChoJwb28oyNCB26Lg4GXcsuD1h6XWS7AGqT3W/E0z0ixhDFNCu1DLWYR
         4iZ27aMk4rp2VeA/5MjCaLTRXZI3wkvqoHfhTrmwMiy1ZpcE4OU1pocjnRo06SRq7kU0
         SfgfLVLLEE8yylYLDXTh7wYNzIJFSpChMShlIDvU6fvRrTaW4+oSLioDyaYhxco0fGL+
         UFow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OLRFKsHo;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id z26si38774266pgl.562.2019.08.02.18.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 18:41:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OLRFKsHo;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d44e6540001>; Fri, 02 Aug 2019 18:41:40 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 02 Aug 2019 18:41:39 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 02 Aug 2019 18:41:39 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 3 Aug
 2019 01:41:38 +0000
Subject: Re: [PATCH 31/34] nfs: convert put_page() to put_user_page*()
To: Calum Mackay <calum.mackay@oracle.com>, <john.hubbard@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<ceph-devel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
	<devel@lists.orangefs.org>, <dri-devel@lists.freedesktop.org>,
	<intel-gfx@lists.freedesktop.org>, <kvm@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-block@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-media@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-rpi-kernel@lists.infradead.org>,
	<linux-xfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rds-devel@oss.oracle.com>, <sparclinux@vger.kernel.org>, <x86@kernel.org>,
	<xen-devel@lists.xenproject.org>, Trond Myklebust
	<trond.myklebust@hammerspace.com>, Anna Schumaker <anna.schumaker@netapp.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-32-jhubbard@nvidia.com>
 <1738cb1e-15d8-0bbe-5362-341664f6efc8@oracle.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <db136399-ed87-56ea-bd6e-e5d29b145eda@nvidia.com>
Date: Fri, 2 Aug 2019 18:41:38 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1738cb1e-15d8-0bbe-5362-341664f6efc8@oracle.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564796500; bh=zc1wJBCk6oa4TZJ5kpnxYLs8I/mCQFC0KqXiV/MQqAc=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=OLRFKsHoXBw1TGfx4yjE0Mz6/NwSHjUP/99RYZUV8BmAJcU3vy970b00AWaqBbqwn
	 eDliId8mLescIf+v3MwQ2SrvN7VrnEwLTirEIw8jXzAjeXgqN3dtxI2Suyrp0L+f3G
	 YPfLBq5YLuEzykUeYyNQ/IXUTk0ew3pKoxF86cxfpvc0Iih+8axjrF9wmXCYOssEh/
	 dFyCupj1u3LqFaTu0iXYZzaL8I/Fkdd+Hdao45WQIFetVoCK43sV9CCZfHZ6uY+1an
	 0Rm4XSFjiP2H1hfdLpXkesSoEJK75cPPtD+8sANcEv6R5DjbxYeg7dbcB8wnnzerOG
	 BX10+9E+Fxe0Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/2/19 6:27 PM, Calum Mackay wrote:
> On 02/08/2019 3:20 am, john.hubbard@gmail.com wrote:
...=20
> Since it's static, and only called twice, might it be better to change it=
s two callers [nfs_direct_{read,write}_schedule_iovec()] to call put_user_p=
ages() directly, and remove nfs_direct_release_pages() entirely?
>=20
> thanks,
> calum.
>=20
>=20
>> =C2=A0 =C2=A0 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinf=
o,
>>
=20
Hi Calum,

Absolutely! Is it OK to add your reviewed-by, with the following incrementa=
l
patch made to this one?

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index b00b89dda3c5..c0c1b9f2c069 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -276,11 +276,6 @@ ssize_t nfs_direct_IO(struct kiocb *iocb, struct iov_i=
ter *iter)
        return nfs_file_direct_write(iocb, iter);
 }
=20
-static void nfs_direct_release_pages(struct page **pages, unsigned int npa=
ges)
-{
-       put_user_pages(pages, npages);
-}
-
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
                              struct nfs_direct_req *dreq)
 {
@@ -510,7 +505,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nf=
s_direct_req *dreq,
                        pos +=3D req_len;
                        dreq->bytes_left -=3D req_len;
                }
-               nfs_direct_release_pages(pagevec, npages);
+               put_user_pages(pagevec, npages);
                kvfree(pagevec);
                if (result < 0)
                        break;
@@ -933,7 +928,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct n=
fs_direct_req *dreq,
                        pos +=3D req_len;
                        dreq->bytes_left -=3D req_len;
                }
-               nfs_direct_release_pages(pagevec, npages);
+               put_user_pages(pagevec, npages);
                kvfree(pagevec);
                if (result < 0)
                        break;



thanks,
--=20
John Hubbard
NVIDIA

