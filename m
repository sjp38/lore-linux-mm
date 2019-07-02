Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.0 required=3.0 tests=DATE_IN_PAST_03_06,
	DKIMWL_WL_HIGH,DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B229DC5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:04:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64A1B218B6
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:04:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ZMFtd4fn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64A1B218B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E94D88E0001; Tue,  2 Jul 2019 17:04:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E45A76B0005; Tue,  2 Jul 2019 17:04:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D36338E0001; Tue,  2 Jul 2019 17:04:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F77F6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 17:04:09 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 30so136387pgk.16
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 14:04:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=a6DSR9zMVNSIPOHutOGYYowzxyygnNjjAgHH6t/fH3Q=;
        b=oJDGYj+IBG7r+gJa9ExXIf1d2iuthazjfgPa5epncJYUGHH6RKSvQtoiDSSLS18sFM
         5yz4xaNyJEtknt5bB6SShdrjPGOZwBP6SfElwv9WEsZKRmZPaACOt/5GejWInxrqrK8C
         cDop0Pz5H9mFDZmS+PyfD4OSIoSD3CFWGF7VUrBXfM+rrsok69dK9sfbWKzpobyUf4Ix
         koSKLm6ecFfXZ8iuEMGnSVDmegCy0aaM6eNaVA6IaKhDBTdtNCU6yaRqMMhVnoaaml8V
         BQOAkNQ7R4++DLqOwfUXJn+EGphSJLGqFgCCzAccHqt+IBlYRI/WYKKtFHs239Eorsb4
         bxvQ==
X-Gm-Message-State: APjAAAUEtxfos14uFmSLeal9DxRH2iRs6taLCy3P4uPwbCFePVnvbGhy
	oC2DTqfB55s3t/eAw9cWD1G7UdqevQhW7HzeaVTMoF+l3rXz4q966qyAawk8uW2ZVwJlPUwBCpS
	AFGzXFNmuWRhujYrL4m4Qyfn6FqvujodPhAuZuTRUKYkWY4UiyLi1z4YPf0R/e9oSyg==
X-Received: by 2002:a65:5901:: with SMTP id f1mr32225121pgu.84.1562101449200;
        Tue, 02 Jul 2019 14:04:09 -0700 (PDT)
X-Received: by 2002:a65:5901:: with SMTP id f1mr32225058pgu.84.1562101448254;
        Tue, 02 Jul 2019 14:04:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562101448; cv=none;
        d=google.com; s=arc-20160816;
        b=fv1bAg7gwox67h2LaJJM206Dxpjj4zMnyaVc7MHa/msDEmqsEYgjr0kFb7SpM7h22D
         tldemWn+fxrIi7HiyGrfTgRD5e0nIcqtOvSXFOsct4I0SCbOzTV3nCDtAlgft8n3+Anm
         5aYigfQdlErC9HQ8ytZnvfiznHbhCp9ahzPlGExllTfrsDM4aFpIsUMmMq314Ol6lt3a
         aSMMSrjND0WYLZDXhxur+qYW2YS+2snFeBX5xrwaHHedFW0skD/DVKnzXomc/ITKwNac
         BPORIbGjvArGyDhH9rg5nrw+SVnIwqIxIJPbQTxHyQ2e59JOtAw4IWan5x3qjiQgwQe3
         JuyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=a6DSR9zMVNSIPOHutOGYYowzxyygnNjjAgHH6t/fH3Q=;
        b=GFTzoE/jVa6SDMn3m8ZjwPGm6tSbI8HAQWYT701BWmj5sdcSvIKj4xilHyqR2FfFO3
         q8/LWh0Pveb2+/v2EvD2f0rqW9sc+Wcie58/LeoEeZNZ39077LQkoeo7lXlsuE76xnoX
         6c5j12Dmm6js1ayumdM1FImk/+F77eMZi4vRs+ougxCB6/KAF2nB6nvOEvFE7tZWiX12
         E5Olb0YqeZHIG7jbwzzUNo1HYU2MlysQ5Lxt+B4l4VxBGpCsr6d+DoHPBwS43hQQacXe
         XlipI8LCI4HMf4PvGmtXavF/wc5GC2m1WOcSsg8N0y9kQvF9UkU1QDYuxrrjFqSK5zoM
         7Ptg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ZMFtd4fn;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor241380plo.54.2019.07.02.14.04.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 14:04:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ZMFtd4fn;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=a6DSR9zMVNSIPOHutOGYYowzxyygnNjjAgHH6t/fH3Q=;
        b=ZMFtd4fnwBhjqDgEcmMPYqwTfM3scvxup6E9ES0eTl1QBLbkm4L+EYQQqrUrDt7I0f
         1W7i7K4qFAKEM9FkLZbBvOwEPA2KShqct0FnQuEtwjRtbN+49uyAwET1ta2fkPFntUdL
         d1HKAJ/XrkEjycdCCsfgQI1lqoOc8poLOC7Ys=
X-Google-Smtp-Source: APXvYqxbnDf0epA4zxEVMf+KQtiS47h5ZVi4HVl0lxeY8pfHVzHmCshNhotvWTcEjEQC+XEnSbkkRg==
X-Received: by 2002:a17:90a:b908:: with SMTP id p8mr7901348pjr.94.1562101447970;
        Tue, 02 Jul 2019 14:04:07 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id g1sm52207pgg.27.2019.07.02.14.04.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jul 2019 14:04:03 -0700 (PDT)
Date: Tue, 2 Jul 2019 09:33:02 -0700
From: Kees Cook <keescook@chromium.org>
To: Joe Perches <joe@perches.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	Shyam Saini <shyam.saini@amarulasolutions.com>,
	kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	intel-gvt-dev@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	netdev@vger.kernel.org, linux-ext4 <linux-ext4@vger.kernel.org>,
	devel@lists.orangefs.org, linux-mm@kvack.org,
	linux-sctp@vger.kernel.org, bpf@vger.kernel.org,
	kvm@vger.kernel.org, mayhs11saini@gmail.com
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF
 macro
Message-ID: <201907020931.2170BAB@keescook>
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
 <20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
 <6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca>
 <20190629142510.GA10629@avx2>
 <c3b83ba7f9b003dd4fb9cad885461ce93165dc04.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c3b83ba7f9b003dd4fb9cad885461ce93165dc04.camel@perches.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 29, 2019 at 09:45:10AM -0700, Joe Perches wrote:
> On Sat, 2019-06-29 at 17:25 +0300, Alexey Dobriyan wrote:
> > On Tue, Jun 11, 2019 at 03:00:10PM -0600, Andreas Dilger wrote:
> > > On Jun 11, 2019, at 2:48 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > On Wed, 12 Jun 2019 01:08:36 +0530 Shyam Saini <shyam.saini@amarulasolutions.com> wrote:
> > > I did a check, and FIELD_SIZEOF() is used about 350x, while sizeof_field()
> > > is about 30x, and SIZEOF_FIELD() is only about 5x.
> > > 
> > > That said, I'm much more in favour of "sizeof_field()" or "sizeof_member()"
> > > than FIELD_SIZEOF().  Not only does that better match "offsetof()", with
> > > which it is closely related, but is also closer to the original "sizeof()".
> > > 
> > > Since this is a rather trivial change, it can be split into a number of
> > > patches to get approval/landing via subsystem maintainers, and there is no
> > > huge urgency to remove the original macros until the users are gone.  It
> > > would make sense to remove SIZEOF_FIELD() and sizeof_field() quickly so
> > > they don't gain more users, and the remaining FIELD_SIZEOF() users can be
> > > whittled away as the patches come through the maintainer trees.
> > 
> > The signature should be
> > 
> > 	sizeof_member(T, m)
> > 
> > it is proper English,
> > it is lowercase, so is easier to type,
> > it uses standard term (member, not field),
> > it blends in with standard "sizeof" operator,
> 
> yes please.
> 
> Also, a simple script conversion applied
> immediately after an rc1 might be easiest
> rather than individual patches.

This seems reasonable to me. I think the patch steps would be:

1) implement sizeof_member(T, m) as a stand-alone macro
2) do a scripted replacement of all identical macros.
3) remove all the identical macros.

Step 2 can be a patch that includes the script used to do the
replacement. That way Linus can choose to just run the script instead of
taking the patch.

-- 
Kees Cook

