Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22556C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:33:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAAE62086D
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:33:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Siaob2p8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAAE62086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72A316B0005; Tue, 25 Jun 2019 14:33:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D9DB8E0003; Tue, 25 Jun 2019 14:33:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C8428E0002; Tue, 25 Jun 2019 14:33:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 482716B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:33:35 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id c12so4561210ybj.16
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:33:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=c1bhlSYUHtmacSSZu3GVj7bv0K+nCRKddkIcoLBahUI=;
        b=tUsnIZG1R1LZ+KIYBZPcY7DCHwLUUF4ag+wHlbRNyZEn02a387Ieyd+fRtMz54g0mx
         Cdo5WLWhp/scNyfvO6NdSdQj4LPSbrg6M1DoYM89NY5tvcEX7d3d4pNMK75PxeqzoHc9
         gl74p7ywVPZ9QD10/Gt8AnPpAMdbK2mj/pWkSvC9WBpAm/CuPEkuHdW9nMgxRwRiq31s
         5DG3Cj4uEkrGZnBOGGVRnWY3+llrjFoaY9PaSdjQqbqNcNeLn7BgPTPwIQc+R44RogpW
         iAaEm9utY+z3afRf+cJByf1Xk7qricVo5h/cekCsQWlggNJ5/He1nIE25qKC5nO6gUdF
         bIUw==
X-Gm-Message-State: APjAAAXpsrtg66En/DHV9f8DRdKYcEDe9q/G+1uNZz13QTOertMErAV6
	Uh173ddN9O3Iwk+ko7Mp4p9+5WnfiJVz9M4JpgRqNS+p1eq5YBl8I3chScr7s0pUaBXDsDsHxvd
	tc3AhYPhjLa/KdH1C0GmFWfhpKFyiCxlgH+ObuoaTznpB5rN4BcwXpIWks9JSwHNXCg==
X-Received: by 2002:a0d:d904:: with SMTP id b4mr46765ywe.465.1561487615094;
        Tue, 25 Jun 2019 11:33:35 -0700 (PDT)
X-Received: by 2002:a0d:d904:: with SMTP id b4mr46740ywe.465.1561487614601;
        Tue, 25 Jun 2019 11:33:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561487614; cv=none;
        d=google.com; s=arc-20160816;
        b=yve7bUwki9ArodzA64V3x8uUXjNqMLsmPSJomrK87BEtOcfNpP6swq5M4Es4hHo3a8
         ocqhxL79rXqgxqGLm+X3BcdnNkHUgrQ3NDzqKq5zoUpYR5LgHzfjj02DBfAIwqYEysZc
         haLN/KqVNy5qowGXAn4jjilLDxlkLoD1aSDW0pjVDDxJ3NdZgnTGSxxNFfoqSV8pTQWF
         wm0MY6AljzLOHopaYnyUG8uEID/hvSjB+zTwq44/x1j3f7o66rFv3aWzzrJQtyLke7QX
         KeixonE3d7hMizyIfs/igq3h4hy+qKsUHW8JvNs7xyuWyzuCcE8iBREWOcp3FNYOViOR
         bWcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=c1bhlSYUHtmacSSZu3GVj7bv0K+nCRKddkIcoLBahUI=;
        b=MRR4BHWwDZQ28cOCchUa7jVT9YDbQGYVXnVNT0u2HiraQ0+80Hbjr0WIXpf58D9mXT
         Gj62MdaNaNtNdIUEgqZ4ZvH0Pl4D02Qkkm2BDIhukvRs1PVzDSf1ncYcUPcT49EhUUXt
         xW9bzjVICzKa/sWDuB5UqQwurhqPDCYoXfrFAM4/KBAuqoy3Qtw6x4NdJQILMtz6GZyz
         3+rBF9FLBxJIvX67d+S3Usk7Igi8a/1nr0KXW6ULu4f/74uHRXuOsW5BZZ0AxblaIvs4
         Nmv5XYNDEP4mmJF8NvZh8PBz8PdV2VbVUSPl6alqibPhNSnenm5yrrJU2pyKjI1dCZWm
         2jVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Siaob2p8;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9sor8103913ywm.132.2019.06.25.11.33.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 11:33:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Siaob2p8;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=c1bhlSYUHtmacSSZu3GVj7bv0K+nCRKddkIcoLBahUI=;
        b=Siaob2p81baD4yZPX63ez9l1o9fjOkHn0DslQPlKa+/CotLvGRfg2bD7y+vsM38XIA
         8OzOkIkfy3f347jH+OkizC7buijoVIRXQvNC5nR0RkXsMfMX/CVnlfL5IcckK/a2K/CX
         iM5EpSF8zJkMeLQpEPga/bkb3OXdQTBzJEwQKD2Ic90tYUHT3SbiHyPJmOLLGqiR52QS
         pRAEIf2JVRHm35WgdunMsfdmU2vzOtc0TQDDdokbA9WEY2dxqfQxUJmcIgMj2YbIhd1K
         qvlg5/rlWRToD5oMKqFqrSJjF/81sX6w/LB6cP/k20ylrxDGTA0ESeJdvcbt4CiSvt4d
         P4mQ==
X-Google-Smtp-Source: APXvYqzB2SGCBLLDlRYUQopLUMQh20hwgk0JlEIVaKoR2twTZTObVhIb0w7G5cEHMSePdBylToiRO03nIDF7L9Lxyhw=
X-Received: by 2002:a81:4c44:: with SMTP id z65mr112330ywa.4.1561487614082;
 Tue, 25 Jun 2019 11:33:34 -0700 (PDT)
MIME-Version: 1.0
References: <20190611231813.3148843-1-guro@fb.com> <20190611231813.3148843-8-guro@fb.com>
In-Reply-To: <20190611231813.3148843-8-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 25 Jun 2019 11:33:23 -0700
Message-ID: <CALvZod7EZYZJR68dqKF7V9xdgeYo8YnssR94O5zku9qii+xJPA@mail.gmail.com>
Subject: Re: [PATCH v7 07/10] mm: synchronize access to kmem_cache dying flag
 using a spinlock
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Waiman Long <longman@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 4:18 PM Roman Gushchin <guro@fb.com> wrote:
>
> Currently the memcg_params.dying flag and the corresponding
> workqueue used for the asynchronous deactivation of kmem_caches
> is synchronized using the slab_mutex.
>
> It makes impossible to check this flag from the irq context,
> which will be required in order to implement asynchronous release
> of kmem_caches.
>
> So let's switch over to the irq-save flavor of the spinlock-based
> synchronization.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

