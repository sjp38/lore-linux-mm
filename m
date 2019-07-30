Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89A17C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 10:24:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 460862089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 10:24:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i2D2zmIM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 460862089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C28498E0003; Tue, 30 Jul 2019 06:24:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD8E38E0001; Tue, 30 Jul 2019 06:24:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC81C8E0003; Tue, 30 Jul 2019 06:24:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 778898E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:24:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5so40289383pgq.23
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 03:24:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PpkuFgEpyrfTUn2xO93gAkOHvkzw/VpUAN2pijyls6U=;
        b=WHlVr+JH7P5OhF72lbi5q26RNqzRg8RIHxuzrJKadcIGhi2+uwKZSxXvnilQ5SjStN
         vMUSgfcOkWDkzOjARGBsuVtYEMkdTnTlPqkAjiYo39VjvLQ19RVg5gRBi1e+mdz07/l+
         p2RNw5qqXF3aIFnY29oTKfL6WLfHyDXjZ31MEfeSScnQ1Nlt74mESKpRaBMk1qQvtR3h
         7HVn0N89Vas0X9PwPMtVyVHwgdF1foBs9Akfv8Nqfl3FyX3eMICgus2K59fOaD8WXnIx
         T5jCe3fBhbCtJAxXfjBJ9dZghP5Y5YyK2xMOxrbGrygE5cmGPeexBu/vgBfs4XRk/d/A
         eQ5A==
X-Gm-Message-State: APjAAAVmRZ3NDiZhes3wsKAgqbMlkmlxQ2Fu2TYcbz1kSB8LHklTB3Xk
	O86DmRKyRbgH7yvpzfzlynjCULA+K3DlCglm8fa8QHFlWOngzw72sxzPKR9u4oz/0GFe+B/A6yk
	79oRbWWFcv+/zr/O7RjE7QsaUVvm31fL/g7xPm8xJ9ue4/qCPijyFHRQRl+W+quMfTg==
X-Received: by 2002:a63:d30f:: with SMTP id b15mr107315537pgg.341.1564482287961;
        Tue, 30 Jul 2019 03:24:47 -0700 (PDT)
X-Received: by 2002:a63:d30f:: with SMTP id b15mr107315491pgg.341.1564482287154;
        Tue, 30 Jul 2019 03:24:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564482287; cv=none;
        d=google.com; s=arc-20160816;
        b=RqKdI9P7RkpZ8u0HSDD+Sx25Tz+yAQh5eatlnHMBDXid7tSzlztaZgxaaUcNf34AUi
         +jsV80r2YNzAHIPZsdT/BhAteRhsBJ49Maip9T/e4goNrr7EL5PeiXllhGS6tBVYonNV
         MGfaoHSl6i6G74uCCFkTB4PZ0AKXqciNH7M26yutXS4WLNENtHwy6c30jMYwXD0zsGCw
         ifihzeRl3zDwQID7CFeu5jR1Xkff/6YcZPzsg3ERyx7JzwE82P6bPYdSzAQHKV/xX2MB
         izou10TJBf9QYDJToNfGD1rFlj8LxJ9dtEWVi1bbbJRcBn+G4rXoIg/+Zs4UPRd738Py
         XxoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PpkuFgEpyrfTUn2xO93gAkOHvkzw/VpUAN2pijyls6U=;
        b=nYWXpMY32cKUkxwKkRcvC6JD5Epg+sOlRvZHNEA/euqfghACRDNo8NZOMjI6zZnmxN
         7suTiJh8jt00g72YCYQrTdrffXJW0NWC/8MG2Cga4mYL+KBkPqAlR/xuqfZIyUSAZ35O
         72z+Z2z6UKJQ+6yTHlbmIKTBHgLCpDSSXD+1kZp58OaWrIFTOwjuXaOGXJu4V8PZ1QcP
         O7601wuOAiizNV7yJNMdiTcWOQC02jpJjyVOEIAh05gp/3ULSB86KihEmOPFZA2wKGYE
         KNMxPM0RnKPNzozkWyIZ6xuoOjdG+Y8IH2DpJoZWHl065ExcSPWmNVIS/ewrUufadMJv
         TZUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i2D2zmIM;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l36sor5782954pgb.24.2019.07.30.03.24.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 03:24:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i2D2zmIM;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PpkuFgEpyrfTUn2xO93gAkOHvkzw/VpUAN2pijyls6U=;
        b=i2D2zmIM4ny6wmoPxR2fSSipScSI/XAkAlZZjNtJiFjveqSDh7apLS0aLxVPcO7J7F
         ftCu4WiPU41LhKu3ChkWomPRlxIa0aHVFvIGF7MilnjQAMPPNAup7H+RKw2Gc/OHXP+6
         itoTx38nN8845TcXtwB1kd/cNQzwW0zkWzMDdYpsNXsSI+kyG7Es7mABVmiOEkbIFibA
         uGO1SWOsGb5HYI0LY04jiakQA6V4UiI3+vNnZX0qHBq5SNAm21s1Lq/EUahrcYb41InY
         cPgAJHeEnO8W9ZoEPB0r/+zvdKDqqrBxETuOkK6c9R1YDjfTxM9ZDr4tczITMpdiSPfL
         b+3w==
X-Google-Smtp-Source: APXvYqwA8gWk7GLzEOo/IlpB9GVuTNJbHsDBEkm5fOjRfwYQi/1Pa+NxWHVSXFOHqNHnEhwFE2YlXA==
X-Received: by 2002:a63:2cd1:: with SMTP id s200mr103839175pgs.10.1564482286634;
        Tue, 30 Jul 2019 03:24:46 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.31])
        by smtp.gmail.com with ESMTPSA id p27sm98530002pfq.136.2019.07.30.03.24.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 03:24:46 -0700 (PDT)
Date: Tue, 30 Jul 2019 15:54:39 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Matt.Sickler@daktronics.com, devel@driverdev.osuosl.org,
	John Hubbard <jhubbard@nvidia.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v4] staging: kpc2000: Convert
 put_page to put_user_page*()
Message-ID: <20190730102439.GA6825@bharath12345-Inspiron-5559>
References: <20190730092843.GA5150@bharath12345-Inspiron-5559>
 <20190730093606.GA15402@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730093606.GA15402@kroah.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 11:36:06AM +0200, Greg KH wrote:
> On Tue, Jul 30, 2019 at 02:58:44PM +0530, Bharath Vedartham wrote:
> > put_page() to put_user_page*()
> 
> What does this mean?

That must have been a mistake! I just wanted to forward this patch to
the Linux-kernel-mentees mailing list. THis patch has already been taken
by for staging-testing. I ll forward another patch just cc'ing the
mentees mailing lists and won't disturb the other devs.

Thank you
Bharath

