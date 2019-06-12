Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6079CC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:41:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B0C0208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:41:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B0C0208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91F036B000D; Wed, 12 Jun 2019 17:41:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A8B96B000E; Wed, 12 Jun 2019 17:41:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7966C6B0010; Wed, 12 Jun 2019 17:41:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14D3C6B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:41:39 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id x19so1724322ljh.21
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:41:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=Wjz9w9lMQqSePDZ2ivGq+I2OodehqGpXzd1bko3gwvc=;
        b=rFS1W1pQdRezYzZ7jBLxabgccjMNTgXQp45UikSMmszukXWTER2zkIyYj+5MaX9//O
         i9ucQOsmSSYdQTcNftiwlb5mcPdGJC1JAe8jmI8CVDsJIbiUVuulnWEE3gtQ5N3ImQz6
         E0VXfMphVkCZ5Q35lZzoMLnrIXWaTCQU1v0m+S/NUllvhmqM61gl+jcyw/8vzaE/S/IA
         Op12cO8x7fiTmFtN9i2JKLH6zuaQME86lNaru9PmkLQ3hpvSNSG2z4a1robdCGAP7wEX
         4asb4S6x7Ok4Z65KFOkNoCBwVJD5eXEShkFp/aVJc3e6xWJ+6tIaGM1GNODDX+bQZHNT
         G+Cg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVuXaPDUOu/F0RnOZAfNi4dQ7RudW1T6rlC9f7sPy6L6D0dA7iI
	g9TZwaCmOO/tLud/4eYaHez0FtnqK0YzILsQWb+vc6cxj85GHp1erFOjIZesCLDrVOflLAoA9Nc
	KvU3FWnU1iHmA1JgCFbrpT8j3amLSnaXCT3dvjw5y3G3FHd0t2EfswBOsOrMR6FAlUQ==
X-Received: by 2002:a2e:3013:: with SMTP id w19mr32923641ljw.73.1560375698479;
        Wed, 12 Jun 2019 14:41:38 -0700 (PDT)
X-Received: by 2002:a2e:3013:: with SMTP id w19mr32923610ljw.73.1560375697436;
        Wed, 12 Jun 2019 14:41:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560375697; cv=none;
        d=google.com; s=arc-20160816;
        b=Qc2yp01R2LJnGlVQLNoQ+DRZkbNUVAl5Fddhx8CPb++0q5H9ekdCSw9LY9NHA6BFgl
         x2X4aZEp+2GknPUNUuTKow+KGrHrWqrZps3YFp7yelXs1ApRIp7PMqsAwmJK4QH6YuL1
         WkG7ASnQBDABIF5KgSQLOiDCwWUJ5Dn2XOGzNgxk0pkY+HyeoNP0VNQ+GQq9v0O/ht3h
         Ew0E5cRVL+iqAmqX/4HbBLUiGL8FWrazbxJTc5qukbDBouGfWyuFrivsZYuv4bACXDcO
         3WTZqSwI0bb9puC3z6aosqoyJiIT1DmgRhZd6NrEHLLcdldiCLVSW+4yHQVhK865sQNN
         Za2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=Wjz9w9lMQqSePDZ2ivGq+I2OodehqGpXzd1bko3gwvc=;
        b=P0y4ClmWtQrHKjwF6Cn88WqJ4WqTFioghrn7yVQLaZ0Vbh6ZGpM7MLDbBjl+bz4tPW
         pSVk5QqDM2k/jx2XDoZXhqcO1zPGCzRf6PXRpQJoWE3hCpExS3sSYWcQANjo0pqmLSn2
         LdyNxA0MlITjv+SO5Xv70NHkADI5EZ6UwYgHy3VdbNsHCm3iDzmDDPxDJh8OoKfoA/uG
         Lsmv1RY6yZeJ+la01ffJayflb0tqzP6luctUD0oqM/PJ94orY9J/IN/FkfhLN7nc/JOG
         gtwoL8oSlPaUyjjB0hAlb014JgsQKtMvxffA0nAnxeUyrN+cpc0iEhFCGMwaH8VhIcjF
         b4zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor628911lji.25.2019.06.12.14.41.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 14:41:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcroce@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcroce@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxWsiGJzzSmrJWzPtxAYvGPq+33C2n3hV7/sJbO7Cz64ykCKr43CIsqDxgUc/wtjsjxhhKJ798aDBixn040ZXk=
X-Received: by 2002:a2e:751c:: with SMTP id q28mr20284560ljc.178.1560375696975;
 Wed, 12 Jun 2019 14:41:36 -0700 (PDT)
MIME-Version: 1.0
References: <201906130111.tSFtzMVZ%lkp@intel.com>
In-Reply-To: <201906130111.tSFtzMVZ%lkp@intel.com>
From: Matteo Croce <mcroce@redhat.com>
Date: Wed, 12 Jun 2019 23:41:00 +0200
Message-ID: <CAGnkfhxnq4yoR+djuNKgRjRbv9TcETrwOE_Lexo99iLRMogLew@mail.gmail.com>
Subject: Re: [liu-song6-linux:uprobe-thp 119/186] kernel/sysctl.c:1730:15:
 error: 'one' undeclared here (not in a function); did you mean 'zone'?
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, 
	Aaron Tomlin <atomlin@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 7:44 PM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Matteo,
>
> FYI, the error/warning still remains.
>
> tree:   https://github.com/liu-song-6/linux.git uprobe-thp
> head:   9581ef888499040962ffc3287d8fc04ced9c2690
> commit: 115fe47f84b1b7e9673aa9ffc0d5a4a9bb0ade15 [119/186] proc/sysctl: add shared variables for range check
> config: m68k-sun3_defconfig (attached as .config)
> compiler: m68k-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 115fe47f84b1b7e9673aa9ffc0d5a4a9bb0ade15
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=m68k
>
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>
> All errors (new ones prefixed by >>):
>
>    kernel/sysctl.c:1729:15: error: 'zero' undeclared here (not in a function); did you mean 'zero_ul'?
>       .extra1  = &zero,
>                   ^~~~
>                   zero_ul
> >> kernel/sysctl.c:1730:15: error: 'one' undeclared here (not in a function); did you mean 'zone'?
>       .extra2  = &one,
>                   ^~~
>                   zone
>
> vim +1730 kernel/sysctl.c
>

Hi,

this is because the following commit references 'zero'.

commit cefdca0a86be517bc390fc4541e3674b8e7803b0
Author: Peter Xu <peterx@redhat.com>
Date:   Mon May 13 17:16:41 2019 -0700

    userfaultfd/sysctl: add vm.unprivileged_userfaultfd

I will make a patch for linux-next which Song can backport into his tree.

Bye,
-- 
Matteo Croce
per aspera ad upstream

