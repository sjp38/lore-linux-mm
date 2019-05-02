Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5D10C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 07:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66D4D2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 07:16:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nR8WtxOm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66D4D2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC0AD6B0005; Thu,  2 May 2019 03:16:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B49046B0006; Thu,  2 May 2019 03:16:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C2676B0007; Thu,  2 May 2019 03:16:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60D5A6B0005
	for <linux-mm@kvack.org>; Thu,  2 May 2019 03:16:16 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a5so787885plh.14
        for <linux-mm@kvack.org>; Thu, 02 May 2019 00:16:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=8E/Xlfqhfo0vf1+GOu+GJdon4fjnIK8RWeWcR7c5CxQ=;
        b=if7XLfbn6BjUkaPVFbJ12NuptbQ4lywhWseYm2VHcgoyJyIMiH29JLlS9edESJGece
         i080ylkyr5lnhpwvPKfdVezD1r8DSetdeIcY7iFjUm3xBO0ac/ZGiXoEMEsdhVUK6zoM
         Qm4m1SAtABmteQ74X1HMIvDESaquTvo/5wQW1qEwpUunW4+n3SWFtY5JSBlD82WCRnJO
         Xz4HZYusmSmY0KPPxNfZ74I1PAF7K4SX8IButanmFmGaxYhdbDKkw/gapdM1cbSxFR3I
         qNWsY+WsLQfHNbNgJzNNvMLEdDpprDTZDGIAn7X2VjzwNTl29jeH7X6rHQk+DkcvDZZe
         8KNA==
X-Gm-Message-State: APjAAAXgWR/nNG/ADlx8zkldp3fvi8CKPLYdjrcxWw0vXgOJkxXANPWb
	NdndM2AE1KmHRxNhW1ATyQalesRw472P9FK0pwBO/N5DJoeobI5ekWV9AQUe35kqw7KVQkSP/vd
	YXsBJhrRKS8M6qQqQwrhw4hlgxlh1GiZpEtHwv2gc+YXfpBpGu4ftmz7REauBJ2KLcw==
X-Received: by 2002:a62:5582:: with SMTP id j124mr2529324pfb.53.1556781375910;
        Thu, 02 May 2019 00:16:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDGJJOvmOTv+wZJpXV9U37YZoiodwkn6+IEEDm6S8sbdgfUtlh3O42/Xk0ou6xofG+CTqY
X-Received: by 2002:a62:5582:: with SMTP id j124mr2529278pfb.53.1556781375096;
        Thu, 02 May 2019 00:16:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556781375; cv=none;
        d=google.com; s=arc-20160816;
        b=LVGNoU3i45h1qOAFGcZxWTawuNlVmHK3O31L4VOTvVyfUS9wzUeOpo7W9UHHm410aU
         ltTnU4bAmPQgnrJ8188fhzd76nHEE+SyQxNZBEd1UQCyuo9u0AWye0pqInaylyXdywBq
         hxbhzrSjMk1vX0qNUEPe10Uw1hcNW4fd4tOcdiDLjunkApLLwB8pKpnrOU9iVAkdVsxP
         YEpakL0rPzI7lKAotX5bUfAKNg+zbqCRgCmyWtl29I32/KFTTMcFi7SVN3uafeLJx+3o
         qjfBmRA4pBk9qf3l3LxhS1YgsafHEtdrb+Fogzq7rakSBnmKHY3dsK9KaMDlXZQZza55
         OWuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=8E/Xlfqhfo0vf1+GOu+GJdon4fjnIK8RWeWcR7c5CxQ=;
        b=PtPR+krTYREJrZ1Z2NgX2idYnXa3LwxdzDNVcAuZSpW3UPu5P9iI/4BBlIAgcC9fYz
         LflJwlfu9uLJpjmbLqa4A7OGHIBSOtIhDFJPCAoj0I5MqiL+hNvLVD7hyg38T1u3T2T6
         awhb2TpxGMq4S3Ax0xZYn5EYgWPnIrAk5ctwW11ieaawmRf8Ig9PjhKG+99wIpwgOC7X
         TARp1AxvNT8lDpbKHjI+sfoVv9b1ochQJ3uqJdPuIauflqdUUtYaD5ziwwBkmej232Rt
         9JMH8r/8VaozBY7Ptgmdz8U7EWwIFqiJZGQ+rGTceMPDEY9oy3rEA3aGJUQkWsZd2X+r
         0dmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nR8WtxOm;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id bg2si16115035plb.117.2019.05.02.00.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 00:16:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nR8WtxOm;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4264cwP036575;
	Thu, 2 May 2019 06:08:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=8E/Xlfqhfo0vf1+GOu+GJdon4fjnIK8RWeWcR7c5CxQ=;
 b=nR8WtxOm+plPvZHMSK561p3KEYr+W5P6dt5wv8Wdyq6G6c4sXKsJ27dNGyglUgYLlvQw
 TiwiQ/8ArXmSJ9Q7w4ZZqnOHmUKWrMN27w4kkS53VuPtYwVISOfzQg8cxC83uMEFA0AY
 ptwm+dRcbI2QNQ2sKnrVBJjEfy5X3NGrEgla0ZjGVVtT7DkKeko/waa8V/JrixHuQk56
 atmQcJgoSXiGDQebmXLhT1JEYypI7ONEyIAva38jMv4vOxLlwbvrWeL2xYOzmBI9We+P
 Y5PyHQUo4Q4VPRHo3QiEAr7J7oq9mMKN/9QfJgBAmoTHtmy586V2N2g2r6kmRLxrYyyd Xg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2s6xhyecfj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 02 May 2019 06:08:32 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4266meq072708;
	Thu, 2 May 2019 06:08:32 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2s6xhgmfew-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 02 May 2019 06:08:31 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4268UcT005438;
	Thu, 2 May 2019 06:08:30 GMT
Received: from [192.168.0.100] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 01 May 2019 23:08:30 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH 5/4] 9p: pass the correct prototype to read_cache_page
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190501173443.GA19969@lst.de>
Date: Thu, 2 May 2019 00:08:29 -0600
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Sami Tolvanen <samitolvanen@google.com>,
        Kees Cook <keescook@chromium.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <AEBFD2FC-F94A-4E5B-8E1C-76380DDEB46E@oracle.com>
References: <20190501160636.30841-1-hch@lst.de>
 <20190501173443.GA19969@lst.de>
To: Christoph Hellwig <hch@lst.de>
X-Mailer: Apple Mail (2.3445.104.11)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9244 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905020048
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9244 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905020048
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

1) You need to pass "filp" rather than "filp->private_data" to =
read_cache_pages()
in v9fs_fid_readpage().

The patched code passes "filp->private_data" as the "data" parameter to
read_cache_pages(), which would generate a call to:

    filler(data, page)

which would become a call to:

static int v9fs_vfs_readpage(struct file *filp, struct page *page)
{=09
        return v9fs_fid_readpage(filp->private_data, page);
}

which would then effectively become:

    v9fs_fid_readpage(filp->private_data->private_data, page)

Which isn't correct; because data is a void *, no error is thrown when
v9fs_vfs_readpages treats filp->private_data as if it is filp.


2) I'd also like to see an explicit comment in do_read_cache_page() =
along
the lines of:

/*
 * If a custom page filler was passed in use it, otherwise use the
 * standard readpage() routine defined for the address_space.
 *
 */

3) Patch 5/4?

Otherwise it looks good.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

> On May 1, 2019, at 11:34 AM, Christoph Hellwig <hch@lst.de> wrote:
>=20
> Fix the callback 9p passes to read_cache_page to actually have the
> proper type expected.  Casting around function pointers can easily
> hide typing bugs, and defeats control flow protection.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
> fs/9p/vfs_addr.c | 6 ++++--
> 1 file changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
> index 0bcbcc20f769..02e0fc51401e 100644
> --- a/fs/9p/vfs_addr.c
> +++ b/fs/9p/vfs_addr.c
> @@ -50,8 +50,9 @@
>  * @page: structure to page
>  *
>  */
> -static int v9fs_fid_readpage(struct p9_fid *fid, struct page *page)
> +static int v9fs_fid_readpage(void *data, struct page *page)
> {
> +	struct p9_fid *fid =3D data;
> 	struct inode *inode =3D page->mapping->host;
> 	struct bio_vec bvec =3D {.bv_page =3D page, .bv_len =3D =
PAGE_SIZE};
> 	struct iov_iter to;
> @@ -122,7 +123,8 @@ static int v9fs_vfs_readpages(struct file *filp, =
struct address_space *mapping,
> 	if (ret =3D=3D 0)
> 		return ret;
>=20
> -	ret =3D read_cache_pages(mapping, pages, (void =
*)v9fs_vfs_readpage, filp);
> +	ret =3D read_cache_pages(mapping, pages, v9fs_fid_readpage,
> +			filp->private_data);
> 	p9_debug(P9_DEBUG_VFS, "  =3D %d\n", ret);
> 	return ret;
> }

