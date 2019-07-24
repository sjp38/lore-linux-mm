Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C42E2C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A13E21841
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:35:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Li1yuMA+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A13E21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 208956B0006; Wed, 24 Jul 2019 00:35:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B9B98E0005; Wed, 24 Jul 2019 00:35:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 057C38E0003; Wed, 24 Jul 2019 00:35:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id D54AA6B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:35:02 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id a9so2233980ybl.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:35:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=5ycCVDmY+zemv5AT9YYK21afucrRr/p3DH8wHXRCnZg=;
        b=Rq25IlSLb5bfINRn0JDBwxjMXxHm7kyjGEbvrplamnJm1qKytJdzW6WiyBGqbiw/eM
         AEgJwPqgXeWPrJULajOhzNcqofghPUBuqelYhgOEAqa3chNcUdUWlRMEgI6HT13ytN9g
         Bt6Y9BR1UV9kTLSQaAsC5BCveWki9CGjfqUsjrAVgi9PZ8Kn3gx/MMpW78SYGyy3wG+o
         9x1C3RQjCopAx+f5er15Ww7RYoPFY96xIOE+lZdSas3/Yl2UgUfIbWzcmjCU8jcJAu0F
         TKjhsbNxDVIkDLB6PZGsQ0mJbPgC8S+3PezOeThah6dF+5irhwcqR0pH1XI6Yx5Q0XoL
         WQbg==
X-Gm-Message-State: APjAAAW2PNnRpNuu/DbkMHLS7deX+rFtRrKzdXgfzhmn2vmo5IpZbQ8r
	YgytOfrcq+1bA7v3LDvNeozSuEW8VVlXpjOMoavZV0dQQF7xsSDw1cccGaeP7QxjQjaKRmRsy3O
	IqaFxTEQ/Mfe4kH927OQ3LIR2a+tYTMnRmYr1i/UNVmU9I4nZKT4/wPegn46gGyzXqQ==
X-Received: by 2002:a25:9cc4:: with SMTP id z4mr48973457ybo.90.1563942902585;
        Tue, 23 Jul 2019 21:35:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsnB+80PwYQCXik8E/ExfFoHFnwcila37K37oqZaGIdTHk4rhl62weXK9TkiwZcs4/BNuQ
X-Received: by 2002:a25:9cc4:: with SMTP id z4mr48973442ybo.90.1563942902081;
        Tue, 23 Jul 2019 21:35:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942902; cv=none;
        d=google.com; s=arc-20160816;
        b=xXFEORCYhJRy2EalgTUbmlrX5y59gTzUZwypi7lr15t4CyYRjd3+bzqwm80CrNX69a
         Fza/VzunXb6V9bghGxFnQehVCGK04swNtsl8o6KEfbXzzQRAfasw+klJqZOcl/FG8lHd
         T622VIsr7dwdxY7O23Z4p7FhPT6/O6SMutrc44bkAvPYwTGaQFetiZPTzFtj4QhZduqi
         ukKosBz0rljNkgZdEROJn5lfXu0LWXHEDQ2fDxLfEwmddDoiytzki+MPOXOYBopbOMEP
         ypeW6CU2sOUpT8OGNAukkpWGppXRh4UaJYlxrmocwbPhnOPMwtzN1ir7jIPCScFj4LLP
         kYtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=5ycCVDmY+zemv5AT9YYK21afucrRr/p3DH8wHXRCnZg=;
        b=EZecncp1TWWXTEhoRThTDPL1ejJmlS0aK647+wEQ8jJ9Z7dc56nhVEbrmW2citlLco
         sQBGh8WpPKMgdOAzHX7BQvOzdaIwNd9RuBl6wtiv0fcK9+3sPUyaqi1viIZuOtj0o4r8
         +2xUahs2jQW50lVr9Ig6qRCz9wD21FMAmCGrN50lWzEwgttKhKa41CDFBYZXwK38o5cG
         Trn5wVVx3uOiAvW5P8ejgrYokTmNGNBgR3E/G4Z5NA8khaj/gMG1U3/wLhCbNpIS8C5A
         ca6u1DgdrSxUprVymBqMSAwSGlwcTRInJ9N4cekAq5uQiAP0fIUYW3kl9xDwEpWEJiIw
         Z46Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Li1yuMA+;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id i136si17191350ywc.107.2019.07.23.21.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 21:35:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Li1yuMA+;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d37dfee0000>; Tue, 23 Jul 2019 21:34:55 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 23 Jul 2019 21:34:57 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 23 Jul 2019 21:34:57 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 24 Jul
 2019 04:34:56 +0000
Subject: Re: [PATCH 07/12] vhost-scsi: convert put_page() to put_user_page*()
To: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>, Anna Schumaker
	<anna.schumaker@netapp.com>, "David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>, Eric Van Hensbergen
	<ericvh@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jason Wang
	<jasowang@redhat.com>, Jens Axboe <axboe@kernel.dk>, Latchesar Ionkov
	<lucho@ionkov.net>, "Michael S . Tsirkin" <mst@redhat.com>, Miklos Szeredi
	<miklos@szeredi.hu>, Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@infradead.org>,
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	<ceph-devel@vger.kernel.org>, <kvm@vger.kernel.org>,
	<linux-block@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
	<samba-technical@lists.samba.org>, <v9fs-developer@lists.sourceforge.net>,
	<virtualization@lists.linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Dan Williams
	<dan.j.williams@intel.com>, Johannes Thumshirn <jthumshirn@suse.de>, Ming Lei
	<ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>, Boaz Harrosh
	<boaz@plexistor.com>, Paolo Bonzini <pbonzini@redhat.com>, Stefan Hajnoczi
	<stefanha@redhat.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <20190724042518.14363-8-jhubbard@nvidia.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <de40950e-0801-b830-4c48-56e84de0c82b@nvidia.com>
Date: Tue, 23 Jul 2019 21:34:56 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724042518.14363-8-jhubbard@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563942895; bh=5ycCVDmY+zemv5AT9YYK21afucrRr/p3DH8wHXRCnZg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Li1yuMA+fDKyuz/M4SCCN59d7ctSse1jfSTWQ3iZlTsXSlRURMkhcccjz+NjkScvQ
	 OT79Q+110UzH6ATtOAZE9TFWQjw4BLnCG5aUr/CalDFE2cW6KgzaPkPaa2VXwXXnY7
	 5/pADAmNdIG6y4v4o+nIoM+vpWxQn4IxAHbuuW5oIOtDNzIl/y2OpjmtWUHEk+W1aZ
	 olqi7E7lxyXO7wuTmjE0Zl5xPzM6XAPVnnMYc1B16d5wLkxA+Bss3XKDZ67aQwvlKh
	 DZPWPt41q1dZKdSXT2fR0lvzoisF0pX9tRbjvzPB2h5VmCo5KF3WlKIvbrQsfpbBjq
	 ftxyscOjUOrMA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 9:25 PM, john.hubbard@gmail.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page().
>=20
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
>=20
> Changes from J=C3=A9r=C3=B4me's original patch:
>=20
> * Changed a WARN_ON to a BUG_ON.
>=20

Clearly, the above commit log has it backwards (this is quite my night
for typos).  Please read that as "changed a BUG_ON to a WARN_ON".

I'll correct the commit description in next iteration of this patchset.

...

> +	/*
> +	 * Here in all cases we should have an IOVEC which use GUP. If that is
> +	 * not the case then we will wrongly call put_user_page() and the page
> +	 * refcount will go wrong (this is in vhost_scsi_release_cmd())
> +	 */
> +	WARN_ON(!iov_iter_get_pages_use_gup(iter));
> +
...

thanks,
--=20
John Hubbard
NVIDIA

