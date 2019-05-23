Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39414C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 01:47:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C88482081C
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 01:47:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RAHsstRp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C88482081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 830596B0003; Wed, 22 May 2019 21:47:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E0226B0006; Wed, 22 May 2019 21:47:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D0306B0007; Wed, 22 May 2019 21:47:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20FC96B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 21:47:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t58so6408941edb.22
        for <linux-mm@kvack.org>; Wed, 22 May 2019 18:47:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GhDOpD+a8hZjtMNIICSVb0siagk1dgNYZl1xyc8Nh/s=;
        b=eCCOfNC/Roj/rsI69MKIkXWYJn5tgejp05qoAXNumPQycEH9JtQISDv/elYQwJ41dl
         4ASbfzZ9ooEU+DtHbMBKAAgOe9J/qd0fXYUCOZogjGUix78EfLsUxgoN8JL8sLq89QfL
         SR8CssmprnWLAQrui66zTkaGGb69Nb5LA0cETgxmDiKBkX9xcqN1AUMu8SuvvYay9lhP
         DOUGkiAzUejjIvSguggHhgknTKAkQvPEf9v0+tJQ6C3PApA9NMHZHugsTA90W4W7qDwD
         sjdRFBS3ySLXFB8L4pcKPuiX+5cr9+SMvLmYubi114C1sgVyLQPVzLG8hfWQgyVfXg/j
         zKmw==
X-Gm-Message-State: APjAAAVmeV8nHSzY7U/qnChEDXZVpn0by3CVCPwEJ6UqgZViLOg5eZyf
	Pqw6Yej21XF4bL0ihMOSxV1CNWVNiL3RMVWbN4IWJuWPIjjBpCNjaFK5yCvV6IJtXuuSoq+Pmsr
	zPXdarwy/GwcdlDZTBOe8rRa6aW8blo/aBEihJ52dYTqS3JGvbf9IDqOPFJzWtT4v0g==
X-Received: by 2002:a50:fb01:: with SMTP id d1mr88297553edq.267.1558576056730;
        Wed, 22 May 2019 18:47:36 -0700 (PDT)
X-Received: by 2002:a50:fb01:: with SMTP id d1mr88297505edq.267.1558576055969;
        Wed, 22 May 2019 18:47:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558576055; cv=none;
        d=google.com; s=arc-20160816;
        b=1Cpeg2ZLjqpg+cpwh09fChLWSanHIXb34bdzv60nlMv9zklUCEMZA9JM35d7CIhacR
         a7srTaGUfz6hQufUM+KoHh+3Nkqbs8yAG+GmCxCSrUD911pY8eymBIb1UkVbHwO7qWar
         scU03H05uA22eAGCyI6+KTvV9xRV036cycx0qgT7PcGpi29zRkEAu1BjzjmACYZADAnJ
         oGr1poucYgpiiNTYg/BWtAsx0bQ1EbLuewMz5yqWW5fafq86NLZrTTrKMojbU+wbHMJf
         hQMD/p+C7hqbYTwi3OiyFyrbLi/ap3ZWzLOn0+xOZB6G+M//8fMpGQ5yoVK8BFmwwFi3
         wsvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GhDOpD+a8hZjtMNIICSVb0siagk1dgNYZl1xyc8Nh/s=;
        b=ZK+NCLJ5S2NLjs/AE+R/xca94EpvFsWOGCs1alMavLNF5tVy2ni/L3aYkPvub9Cy5q
         1Bv8oEopx9DvjVSmF5SC4XxZe0IDJyYoI2eDcmJkVVm71Ixv1rIMZk06Y4VspbYmZ3m1
         SqjKkJ6/ko0r6U5LT8LM+0TbU+s/FlnojJUO5ZCmMuhQajlWYhHveQ/KN3caN/OeX3jO
         pvn1L4jru6jQlxR6GtSxeKe7ltC6rwO8RwlUOnU/lcW8UaLyD75auDQ9L28zGsrvux5p
         d6c5bMEcF49V/q2USr33N36/jKQpsIvLNfgmXUVtaYnd9kwUDk7ecNEMGbHMMdBzTxWH
         4Rew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RAHsstRp;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id br8sor6631601ejb.61.2019.05.22.18.47.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 18:47:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RAHsstRp;
       spf=pass (google.com: domain of natechancellor@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=natechancellor@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=GhDOpD+a8hZjtMNIICSVb0siagk1dgNYZl1xyc8Nh/s=;
        b=RAHsstRpbLf3k0oQL3ZdAxZNnhWB9ZQx211cpf9TbvlO+3D6SP3+7mmzu0LlgM8ldM
         YwAGFs03guyR/13fWGrGfOdZTr/4PaK0iMdmiCPXcSlfRGUqpo8DxXbX92/urJpReydV
         ZjMcA3YzivAX4MdtizE4zM2cqlAYzaJ6ofb2Iz/tCiBMhFHhoO1Ln/GsI0hd8uSESLm5
         ekrjS6LIpq+TSnewT23Yp7Fd825pMCcCj10h04CJZEpHj9FPgUqM+w5N50Bq50LoFzva
         QPaI8Irw+hkLdwcEis8BoraD6dx5NA7m5xWV/KpTMQpf0oBfAknVCAYX1XMfmXp0SvHg
         gpUQ==
X-Google-Smtp-Source: APXvYqw/Jq1ILra5N4580sMe/IeEHxM9pGabgCBEXURpJwUD5K34xnviPekD1/bHpG4yUCsySFosJA==
X-Received: by 2002:a17:906:488e:: with SMTP id v14mr33945656ejq.216.1558576055392;
        Wed, 22 May 2019 18:47:35 -0700 (PDT)
Received: from archlinux-epyc ([2a01:4f9:2b:2b15::2])
        by smtp.gmail.com with ESMTPSA id x22sm7584539edd.59.2019.05.22.18.47.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 22 May 2019 18:47:34 -0700 (PDT)
Date: Wed, 22 May 2019 18:47:32 -0700
From: Nathan Chancellor <natechancellor@gmail.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	kasan-dev <kasan-dev@googlegroups.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	clang-built-linux@googlegroups.com
Subject: Re: [PATCH v2] kasan: Initialize tag to 0xff in __kasan_kmalloc
Message-ID: <20190523014732.GA17640@archlinux-epyc>
References: <20190502153538.2326-1-natechancellor@gmail.com>
 <20190502163057.6603-1-natechancellor@gmail.com>
 <CAAeHK+wzuSKhTE6hjph1SXCUwH8TEd1C+J0cAQN=pRvKw+Wh_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+wzuSKhTE6hjph1SXCUwH8TEd1C+J0cAQN=pRvKw+Wh_w@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 02, 2019 at 06:40:52PM +0200, Andrey Konovalov wrote:
> On Thu, May 2, 2019 at 6:31 PM Nathan Chancellor
> <natechancellor@gmail.com> wrote:
> >
> > When building with -Wuninitialized and CONFIG_KASAN_SW_TAGS unset, Clang
> > warns:
> >
> > mm/kasan/common.c:484:40: warning: variable 'tag' is uninitialized when
> > used here [-Wuninitialized]
> >         kasan_unpoison_shadow(set_tag(object, tag), size);
> >                                               ^~~
> >
> > set_tag ignores tag in this configuration but clang doesn't realize it
> > at this point in its pipeline, as it points to arch_kasan_set_tag as
> > being the point where it is used, which will later be expanded to
> > (void *)(object) without a use of tag. Initialize tag to 0xff, as it
> > removes this warning and doesn't change the meaning of the code.
> >
> > Link: https://github.com/ClangBuiltLinux/linux/issues/465
> > Signed-off-by: Nathan Chancellor <natechancellor@gmail.com>
> 
> Reviewed-by: Andrey Konovalov <andreyknvl@google.com>
> 
> Thanks!
> 

Thanks Andrey! Did anyone else have any other comments or can this be
picked up?

Cheers,
Nathan

