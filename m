Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DD66C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:17:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D605321850
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:17:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ElkF0jZ2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D605321850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76DC18E003B; Thu, 25 Jul 2019 02:17:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71EC68E0031; Thu, 25 Jul 2019 02:17:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60C938E003B; Thu, 25 Jul 2019 02:17:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 411398E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:17:34 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id u84so53889728iod.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LRoqbDJHGfr38RXpT7qcza55DevlOlHgy5CoUePAUmA=;
        b=iLa3WKmCTJE4X5AJMOym5X0BE/UWoKUr5cdmweUq/Y3Ao9BBn4N/n3dz2DiKDFwIim
         nzPDChuDs3mN2gxwIxWBQveae3aZn+tRr2fNWiCy9Wo1sLcVl6utV8l6QA2lkx11JQRR
         TA51uPjHu0Htiq+LlNx/WK+3UIpEuVtYAmMvW0CNNpaAVGjlqDPdGRLKGxS0o3qrcTAm
         yOZndmPIx46Ks4cD09eqPy1YF0i5Ja6dtggTNdn+HwlBs6y40Xl6P2c1P7CPm3jr7Pez
         pxjFsVBfeHPNUyJ5qMgvJ/tnbqXzzYKn7gujPZefCqYwcQzfWqgmvNl1gRcT0bGgkNvu
         BrAQ==
X-Gm-Message-State: APjAAAUtYPCgYREM4lRXiy0WAHNzR1ctGFe0t1CcgO5LaGq76nagSiex
	zi8JY6luz5YE6fXRFKVLuoOhJGapQ68Vk5q3FdKXwjBCH8ZhJkHjAM/OwY1L6zLl7BEkoA/FFu6
	ni8dRdujg5AF0xt4HRWL0F7B3CQ1XtgOKMvG+4JmqFdn3/CMSa73Lx5HuLMJKjf3ouw==
X-Received: by 2002:a6b:f80e:: with SMTP id o14mr10835924ioh.1.1564035453990;
        Wed, 24 Jul 2019 23:17:33 -0700 (PDT)
X-Received: by 2002:a6b:f80e:: with SMTP id o14mr10835884ioh.1.1564035453220;
        Wed, 24 Jul 2019 23:17:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564035453; cv=none;
        d=google.com; s=arc-20160816;
        b=r3b+qigoyHrtsv77A0J8AupFc4biXzabaauUnzRLjj0WXSbBXu+cQv/ZqbDeKAureM
         Zk8lpKQkqaGsftX/1hGuluGwubhOoUMKzpbQqyZYgWkO/hh6918PjYsmvAHgH8SHRKkv
         6GPgyUMtFV29OOeb3Mzi3RtIhb6t25zVAE2RvOhlE6hMJaegSmxTUfrMRvmyMEaN4wde
         PMntDjL/jAgXV0dgw+IMuzxrA1TKcha0IxQlrd5/IKImnciZKF0XbCWwqaiQ0w9awXvy
         hLOyZDSkcYKFGK1JbUZo2YJy6JhpV6NH1ipeHb/+QINRzP8iNoZK0fugACU7rv84c4bU
         rxng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LRoqbDJHGfr38RXpT7qcza55DevlOlHgy5CoUePAUmA=;
        b=mCptUjxtCuteoCdWj/PyAzxES3QC92n21azP0tkOHWH/zfVUIa5NN/XQQJWBl4IVsI
         fHdHiefDkEkYRxnZHmkpy0OLdokwDi/XHQVQbSIkTUYmhdUWIagpuEXJc54RTM/Bt1QD
         CriT4Igle7xkbryqZkcwZyj9LogD0BfnDGfeizFFizp5ebnwxEZx/VfIZbRZbiDXDRW0
         wqjHe6zA5X+lCYATV1FQfeTUU3PWqBnkac9LA4sBY4gWew4FQJjDM1YvMWPWIyfzWo66
         Dmv6V0OSBam0MBRh/VJd6LIUasWnMqkXA/cjq045Bn8uaY2BsEa4uY8zeYorxfTzeIWD
         IL3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ElkF0jZ2;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26sor114684352jaf.1.2019.07.24.23.17.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 23:17:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ElkF0jZ2;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LRoqbDJHGfr38RXpT7qcza55DevlOlHgy5CoUePAUmA=;
        b=ElkF0jZ2oXdbwt+dCFUKNeLkDixlYYHEpD+pFLmuOYWj6wWyJcscplUObqPiiwAmyW
         OKcMh09HoG8tb6nJaEneRZMa7p/p5Aa/Xw2wOGBvu5ro3WetRLqQ5RNfjfwGwGGgfbMH
         AtZf04obC8OEXzLfTJ1vFUeSdSJpVszRAbPF/6rDDPB0O44x5zPiNIm7uJUsewru5p0o
         VU31YGLkjCU0mUhgaDfqke3vxe43OfWiFY81rhYW99fQKA1gkl+6P1rHoZGwGG2mUS9I
         On/OQMC0fFPzzFgBI79nNP9Y9yiH8Fjs6jxIK10ffXre40U7yqMytaLqS/z5gaxBx5Eh
         zMBQ==
X-Google-Smtp-Source: APXvYqw3GQTATk7TCpJIxhOvn2PyGKQTOn1eklEiI+U7h4SZXAwdtGqiBf2d5eqHcZ865TD85nByVoKsejn8s5nuf38=
X-Received: by 2002:a02:bb05:: with SMTP id y5mr86296517jan.93.1564035452598;
 Wed, 24 Jul 2019 23:17:32 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
 <CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com>
 <878ssqbj56.fsf@yhuang-dev.intel.com> <CABXGCsOhimxC17j=jApoty-o1roRhKYoe+oiqDZ3c1s2r3QxFw@mail.gmail.com>
 <87zhl59w2t.fsf@yhuang-dev.intel.com>
In-Reply-To: <87zhl59w2t.fsf@yhuang-dev.intel.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 25 Jul 2019 11:17:21 +0500
Message-ID: <CABXGCsNRpq=AF1aRgyquszy2MZzVfKZwrKXiSW-PnGiAR652cg@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: "Huang, Ying" <ying.huang@intel.com>
Cc: huang ying <huang.ying.caritas@gmail.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jul 2019 at 10:08, Huang, Ying <ying.huang@intel.com> wrote:
>
> Thanks!  I have found another (easier way) to reproduce the panic.
> Could you try the below patch on top of v5.2-rc2?  It can fix the panic
> for me.
>

Thanks! Amazing work! The patch fixes the issue completely. The system
worked at a high load of 16 hours without failures.

But still seems to me that page cache is being too actively crowded
out with a lack of memory. Since, in addition to the top speed SSD on
which the swap is located, there is also the slow HDD in the system
that just starts to rustle continuously when swap being used. It would
seem better to push some of the RAM onto a fast SSD into the swap
partition than to leave the slow HDD without a cache.

https://imgur.com/a/e8TIkBa

But I am afraid it will be difficult to implement such an algorithm
that analyzes the waiting time for the file I/O and waiting for paging
(memory) and decides to leave parts in memory where the waiting time
is more higher it would be more efficient for systems with several
drives with access speeds can vary greatly. By waiting time I mean
waiting time reading/writing to storage multiplied on the count of
hits. Thus, we will not just keep in memory the most popular parts of
the memory/disk, but also those parts of which read/write where was
most costly.

--
Best Regards,
Mike Gavrilov.

