Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9BF3C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:41:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83CCB2063F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:41:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83CCB2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3097E8E0005; Wed,  6 Mar 2019 13:41:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B74A8E0002; Wed,  6 Mar 2019 13:41:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CDA28E0005; Wed,  6 Mar 2019 13:41:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7DD78E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:41:02 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 207so10711599qkf.9
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:41:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=WnilQ0kGUuQrDxSLcXwNuiNJ09c+crGBRItXM5tyEGg=;
        b=S2fl56GUMg+JMUU3I5Z2xiRKHhn6WZUq9mqPF8PiS6fQkl+NHosUAqmrgUjx0IqXSw
         VhjwOCnIt05mlJas2yejwLnd40sVPAWmwh4fthdvgdAxwl1dK275sOPyXmbEfxc05n2v
         zWssU5qEH26a95SRWqvzWsjlqXqHwQh5OHSmXSUjoLLMitdmbIWcT3hIZ99chHK/d0Ew
         tuFyQ/p3VPlKyjGmaKlbsnzJkSwK7YCVjYrTAd1ocl3tldbGj0l+IS+oO7cfkaQjlkl8
         jzLoHqG7sKjKJSTB77/TBa6Mqa/Z+bH8Oxt29wbZ2ghXGJiO6JOD39MBtHuhfpzNyOfs
         Sftw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWMsGbrDDVJ19Hh0EkmidNmg0mt/3BXSoDMLpfEIAYejw7BeAWn
	cDdXwVTvX8RVT4jEozmGsRDLAnHadxIzcKyrlvrnpTTR+1EWog8Hm602KxhbPXaZ6xxJ7nMn+AW
	5/DfJRvD5Qf74zn1RBSQ/MrXtU5bFpnJRvMnGsWVB4JTtzR0gAUwUU1DxNP3Mmiwxkw==
X-Received: by 2002:aed:3f2c:: with SMTP id p41mr6791643qtf.261.1551897662626;
        Wed, 06 Mar 2019 10:41:02 -0800 (PST)
X-Google-Smtp-Source: APXvYqzbUkswnuBce2F7NxFr+3Ks/GWxVfaGnFmXHrJZuDptyqKwu+jd81f6vHNkj7eXDgOZvNVk
X-Received: by 2002:aed:3f2c:: with SMTP id p41mr6791615qtf.261.1551897661988;
        Wed, 06 Mar 2019 10:41:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551897661; cv=none;
        d=google.com; s=arc-20160816;
        b=IPt9Ab3+23SWHw+ibUkU8/MfREipQJ+JuEvWdxb6eKYv2859ndPK+vgNlZa30smDn8
         eC2UmV8ketWHopMTJQa1/mcXcWFr0iC9Bu2miYcLFie4UkndeQBkImp9NF9hs+RWiNK1
         iyN7T1l+Z/mY1i7W3dJDhfrk/EZvR8pMzunttM4lECK2HbdT/mt5ApnAv3JbyCD/Yns6
         zLfD1VQhoKpI8rhJxcs6EUwdc0kb16NwwDc1NwEp7tFrTBJU8vRKGkJkbYbASpXsyaYp
         5yC9WH+JQFeM/ceCvukmFiGvVTC9p0BjAbJV82E8IxigadHBX7Wl3r8KdOlVjvAt7ubp
         1sJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=WnilQ0kGUuQrDxSLcXwNuiNJ09c+crGBRItXM5tyEGg=;
        b=nFuUGFNknsp6NA+b0mUqlzbnHrEz6/gEtmMB5zc5lDWPNxEM445nI+kLHvGl1vy2Jv
         bTbIlek7abRIeGRCA4SYRx3k2n3IqA9r2qD4veAMy0BEhRtz9Kinls3LBNyGMAc8FwC9
         iKss2BHLBakm16XnHHSkubQz5BcUVbj+uZvtrGa7PF2CcfjF74CFaocMUv6viGKJUKnd
         dX4BzWO4MYeTlZEDvqbK1yWunfPiPIad2SrPyYswdaaM6BjvCZVocrcm5tQBjrMcwz7e
         P1Mp2rsSy7YkIAypmTHctFQgg+yazxwxdd0JeciyDyfOezueaqRN4Dt7Wv3qZVD4xqrC
         YKFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x6si454058qkh.227.2019.03.06.10.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 10:41:01 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 227D21310;
	Wed,  6 Mar 2019 18:41:01 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B62CA1001DC5;
	Wed,  6 Mar 2019 18:40:51 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
 <20190306133613-mutt-send-email-mst@kernel.org>
Organization: Red Hat Inc,
Message-ID: <7a77ce2a-853f-86c6-6d10-1d8db8fb8ae4@redhat.com>
Date: Wed, 6 Mar 2019 13:40:50 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190306133613-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="d59HHRy06H8yetGwTxlr6wgZT5IDIwPC3"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 06 Mar 2019 18:41:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--d59HHRy06H8yetGwTxlr6wgZT5IDIwPC3
Content-Type: multipart/mixed; boundary="L34uAfN2VceX4UnGRao0Vn0YL6JKt8BRb";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Message-ID: <7a77ce2a-853f-86c6-6d10-1d8db8fb8ae4@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--L34uAfN2VceX4UnGRao0Vn0YL6JKt8BRb
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/6/19 1:38 PM, Michael S. Tsirkin wrote:
> On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
>>> Want to try testing Alex's patches for comparison?
>> Somehow I am not in a favor of doing a hypercall on every page (with
>> huge TLB order/MAX_ORDER -1) as I think it will be costly.
>> I can try using Alex's host side logic instead of virtio.
>> Let me know what you think?
> I am just saying maybe your setup is misconfigured
> that's why you see no speedup.=20
Got it.
> If you try Alex's
> patches and *don't* see speedup like he does, then
> he might be able to help you figure out why.
> OTOH if you do then *you* can try figuring out why
> don't your patches help.
Yeap, I can do that.
Thanks.
>



--L34uAfN2VceX4UnGRao0Vn0YL6JKt8BRb--

--d59HHRy06H8yetGwTxlr6wgZT5IDIwPC3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyAFDIACgkQo4ZA3AYy
ozlq2g/+LuhyTg5EE+QuRY1swFfvQ2XtYUvty6CPalWpGrt8mBo2479Cbj4q2sTk
MgwZzoIo5p258UcuvpapIQDdIV+J3j7i2y6Wxdqt/9w8O7WkGWXVtBPvmBEL8BjT
2FVEqK18NsKPnxF8O3dWqZynQmc0R0eucJobrRb312j4bsRHlCbtoU99RydlSls1
3gs1nBRpQb3jmklYqhVhDGjD390QMZTcGA3N5ln53oNghXrSONhH1q28ebPt8X12
rbPrRaWEvdXh3IPnlMltHcQKg9fJcNBH1k8xNv0dzrN5eKfvWCm/NZsOJdrimozR
y4rVtxP4EfpesQ1CcIVX6m2dlb/dePLUH/tEqd3R0Xb0A54k99/62E8CClOH4mkO
SDM17WavRCb+wmqoNpPumNYLezhHMS+Ei7UFEQDysOHe9XUz0d0dWg70vmemtjtz
WMxlx4rGg1ZvOjDk5tACjwxN2FqcVBgSZXXT+Jm2qQmj+dlCgIbz4zc9t7sJ7HXd
TJ/DSoktLfHMJF1K/hLCDv2MfhY+W0/Aa0mJXjlxOmSGb34pArpS0bRSDo5H2SNT
EfdTEHR//nlanuiWuHXWslS+PxkiyVdQLTnOx6gr4qLZYZ7FNYSyC0/+gbO9ntzH
blZstB6PYhEAS8itoApMpT9duHDoqegShK+l76N2HKuH4s6miQo=
=cLRz
-----END PGP SIGNATURE-----

--d59HHRy06H8yetGwTxlr6wgZT5IDIwPC3--

