Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3977C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:16:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65CF42147C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:16:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Ov1XYkHm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65CF42147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F114D8E0005; Tue, 19 Feb 2019 15:16:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC28E8E0002; Tue, 19 Feb 2019 15:16:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD94B8E0005; Tue, 19 Feb 2019 15:16:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B56788E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:16:09 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id 42so9472780otv.5
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:16:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Sqvq9WOCXxY9vLv/Rse2Zu7GWBX6BH0N+O595XQs04g=;
        b=amk4L5fQBSMCspcB7+N/JpQMjEGL9ho58xjTNpVMbxuWxDoP1mGQAe61EQBy5g+BDe
         6egA0LvjyQSkgvYII8A1qwCtAwdwCrk/u+Yd5W55al2EIet5JTB/3JrCOpK4hX216Bny
         kPRISp7RZ84ricJYwRhsLP5xIXj3H6YonZDqLQ2ds1leNEXOb9cP3yU3vA+wqmANtzMy
         IWwS99AT9fUSBqYoOE77L60ffE+pWi+e4Tauf1Rm/MS32xpBEtKcstoXiRyS3kb99z1g
         LeM5aHrgBerjXX6aVvvE+tFHDChpLpFCF/NndK8XpMOQvzMMJItzTlF34TJr0YCd21Vf
         N2Gg==
X-Gm-Message-State: AHQUAuarnGNJ2S26qSTEaOeaJ3TSyAUBMzJfqJY1JEQiwPjh1fFzNNeh
	Ae+6tXNTSdBKnAFzieXlQsEtbePrjQOkQfwC4t2r2b4CPz7PmmdmDwTffmHTOqN1LJN+m4wTdUR
	O1/tB+JzYVltD2IwifhPGXvCe8WjcuJHNldBh/mb86aruHp23q63ApfrqqZJ+igLQOj7ggmzUyb
	prwvFi66zrEIsSbhu8rPq0MlPPgsUrmgifnvNwYuUnwTBGrsPzwka0mfUVOEI3HL65MuiRlANw7
	6R9o+U50sAUddx4GcQC2m6fXLZL3tRwO0SAncHFSIznPRHibxi+fCbhoqvMw5/WHUTG0Tf3wNTi
	aUgOQeNjsqvmdizCM6MFfnhg3hCnRDUu0Wi9v0sSKywdEolxkCjDftKzeuOab08Aww5QHC2vwNX
	R
X-Received: by 2002:a9d:194:: with SMTP id e20mr7483760ote.68.1550607369334;
        Tue, 19 Feb 2019 12:16:09 -0800 (PST)
X-Received: by 2002:a9d:194:: with SMTP id e20mr7483725ote.68.1550607368755;
        Tue, 19 Feb 2019 12:16:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550607368; cv=none;
        d=google.com; s=arc-20160816;
        b=J2hm4huttazWJsS4UhZZZPXmVvSheG+/Ep7qvIUd//Vm6feH1SCCrP/KSqHjYLZAa8
         grMUofZVzTR0EfIahIxp2/YRi5/uwQKEkQYZKPIE62Wqhcjdl6VGNW5NkZ9+LVWN1P0Z
         F4vqmPin+DEPoJpYd9uWZbYZ45S8zeAdKTMSGe6h5pWhG6ZB5Yxh+RJ4VEyi1WnmsyTS
         /uHxJya3I5p4MvGi8iOCwd4ngu6IZBePESw/O7j038a+LOuu4u4Co/SMG+fQecPrYics
         orz3e0mDG0DnWnuczu7aKQc6wxew33r3KWtKvT9vKC+IXKAQUnD/j8hedsNzb+oQLzud
         zp9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Sqvq9WOCXxY9vLv/Rse2Zu7GWBX6BH0N+O595XQs04g=;
        b=zZDyetQG0t1jrMTsO+j+3KvQbAnZKru8A9NSzFwviiZMq9ZofCRlQPsRG5xxDzxgb8
         iVNoG36yXSC4oedz/7R5NicGO3fqTZXZvbnT/hhMualJ8KwoEdXKUdWDgZWpEZoQ07gI
         Ct7OhCF8Tc1aJE3WBzH6Wsyb3zOhk3YhlslVdR6Q8LqlrQO5GOlr6nuGtUN3DlGiKm8N
         O2KznahQYeHy/BI3tgRSGrxGFMzP23c3uCkQYVljmdCpT5ORK/tladc+Ex1J8Qli8iOH
         2BQMTzd/mur/bwKVpgG1HyDJiD6iIJohW1Bav8Ju66gm7YhIphnGJYLmtcNTK4B7jBFE
         P0iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Ov1XYkHm;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor9577125ote.147.2019.02.19.12.16.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 12:16:07 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Ov1XYkHm;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Sqvq9WOCXxY9vLv/Rse2Zu7GWBX6BH0N+O595XQs04g=;
        b=Ov1XYkHmAtXJJwOlz6WpWNLRjouvNTg6FqiLhNyeGcaRbz+EZ8xj8AWusv/VN7221i
         RPHIzg9yiFhZao0wIMOaH7U6o28ept0FonQiY9ODipSTL8IzlotLHFveT4SoZEq93TKr
         aWcr1i8LSXkUHryCAZpzUQbgYsQfpkfTzv6zYCrYJlPDOMkJPxjFhsPoyiczeDwooony
         B1sx9kPAt4fWfKKYLrMMjWwDYQ5XKtcmP1cXN7p3GyTDY3rIqvHuR32sEdU0ERsOma26
         YfaxtYn3i4//26oSxsfQkTSyyRY3H09tOIfZ5iJhNWUjYB9MKAMSEpUREC2UunglwRMc
         2s4w==
X-Google-Smtp-Source: AHgI3IZuuZYL163cx5TXOjdw2RfWgoFCi7spqelc8kItl+zNUREvx4gFxmqO7tZx5Xno0pxM5tcGGXxD2PHQQ5vsZ50=
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr9926774ota.229.1550607367114;
 Tue, 19 Feb 2019 12:16:07 -0800 (PST)
MIME-Version: 1.0
References: <20190219200430.11130-1-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Feb 2019 12:15:55 -0800
Message-ID: <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
Subject: Re: [PATCH v5 0/9] mmu notifier provide context informations
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, 
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, 
	Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, 
	Ross Zwisler <zwisler@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, 
	=?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, 
	Michal Hocko <mhocko@kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, KVM list <kvm@vger.kernel.org>, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-rdma <linux-rdma@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 12:04 PM <jglisse@redhat.com> wrote:
>
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> Since last version [4] i added the extra bits needed for the change_pte
> optimization (which is a KSM thing). Here i am not posting users of
> this, they will be posted to the appropriate sub-systems (KVM, GPU,
> RDMA, ...) once this serie get upstream. If you want to look at users
> of this see [5] [6]. If this gets in 5.1 then i will be submitting
> those users for 5.2 (including KVM if KVM folks feel comfortable with
> it).

The users look small and straightforward. Why not await acks and
reviewed-by's for the users like a typical upstream submission and
merge them together? Is all of the functionality of this
infrastructure consumed by the proposed users? Last time I checked it
was only a subset.

