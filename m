Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C7A7C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 17:26:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF414213F2
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 17:26:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BwFDwO7H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF414213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D3886B0008; Mon,  8 Apr 2019 13:26:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 883076B000C; Mon,  8 Apr 2019 13:26:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 723FB6B000D; Mon,  8 Apr 2019 13:26:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 366786B0008
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 13:26:38 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so10601548pgf.22
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 10:26:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=6QxCx1woXIJoxK0RRPDeFB8xTfIuPiCOmQqUjahb29M=;
        b=qpth63qAUgqWyIbdFD2ADW2cf9RJb/E5gWiRIui+NbG48yuVAiKEKcD22eMWu32oru
         7/H4HmBpCLqqy17mQqTZzxxeEGpFO4Ipv6BJFgchBV9ho+3Pl0G9FgDtHjO1/XGcCOI8
         RdJGP7xpD1w+SFoy4iI4H5vHJHLqbv0VSsguA6HUnrBwR+Ck9vRVVn/iDUhRwfPlHbA0
         GM73/0ALtDEvm3aPQUxVaM03fW3LvqHHpr6KdNfn0tJ/MmkBRjxZFAt/uv+f6YcPZRjP
         EWWqtACT6Kvn9G+arrD3pJIi17amxYlogMCv/mOUb0HEg3zBiZsZFEy3+qPnO/OMrsox
         OPpA==
X-Gm-Message-State: APjAAAWAQz5JLuOQYumEU915qbq4utqEyTQmwVfvPLbLz+03ZSS73Ylu
	VDY8DBjQmcCKGS/LXM+jnrvpv4q4/SXYnqCcp/7Nf8H8sQTssfDTR9tVlWRbfJ9LtRruZNE8L9B
	bPji4tKvfNsK5xVN2EFEoVzWoHSx+OvITIKxlMhn5462puxLEhu4zZfExoeRUr/m9ag==
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr30303506plp.74.1554744397716;
        Mon, 08 Apr 2019 10:26:37 -0700 (PDT)
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr30303465plp.74.1554744397079;
        Mon, 08 Apr 2019 10:26:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554744397; cv=none;
        d=google.com; s=arc-20160816;
        b=XDDuO9xoogKsvRI/t7UcObbMPcsxV4kh4uEZrodn+wnT8jwzzkeuU2FwxKgzFMUSYq
         47fJ/1Bpq8cy9JSKW7XHRI9ZfcnhnVbYSj3fb/Ug0vuZIvx5hYXPT4hfqXC0Rc8Cy3rg
         XYI4RCLfqqmitCyQNqOVtuveNgNYMO8EzNgUGdMSvsfSGEkRUg+SbXZTgKD0Q88PzgDh
         i9Rx0DByxsPeiBRn0C7jn4dVERmtPDpKvy9U4wh3MQ1SjI70NzWj3PzoQJItZmd1i0mT
         pADRARyZYCANsDSZiyz5o6IQuVJaHqXgqZTnkDgj8RsTf7uBNntZfam1YzctPXiLFidz
         z6gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=6QxCx1woXIJoxK0RRPDeFB8xTfIuPiCOmQqUjahb29M=;
        b=P1Fl8l3ofpAtauXjKnpTkECThYaPWMzMBxR5QOoY8Epb2BOtrjFpfxoc2eLTVJX6x5
         0JuWaZYok/mDxSqHRgBzSfcCw/huSm577J3Nmc8FR4CHN54WexZGI8WIdPVcKkZ1xR3+
         gcCnXqlLZOaZNJmdrwHxX73/bysdg+RY6/+i6sDwMObM0yP0QcozHHAFaNE+KOXmzhX5
         GtHHoTzMlepd4UgwOrMyFaLs9FPdnUMfUHQwnRdw3UUiqzY96PaN/m+HvJcOeAueQdWw
         BvyymfyP8ADc9rt4gn3iSD9lj+/f3bv7JASZDFqO1UGxachhxL2odiNPd1pTrzn1fRf3
         JE2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BwFDwO7H;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c189sor12348962pfg.45.2019.04.08.10.26.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 10:26:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BwFDwO7H;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=6QxCx1woXIJoxK0RRPDeFB8xTfIuPiCOmQqUjahb29M=;
        b=BwFDwO7HJYO/Sbbcl6GcpnqnkQ4R9noghslVuBIR+gRjaWXL6r1GbrudJUXrRfBigr
         TKdQ7T7tXJ4kfqwb2xPtKx0RUcdCZ5O8GOL3mEX/8doZRh9RsZbteU+JVSTZNbdI0Hvn
         UHb02KHL5Ce9FFqCkC/G5noSeBD6J2gGwSKIvms09qpFjWVHolNvSOSu41FyT0m3wRL6
         7R2ljrawSF/wN1T/kd+Htjyd58MnRGhVT+QC8iobCL3XWEZxx7RKmENejmWknC63Jrr2
         G8xV9D8zEh4G/1MfkcnBXmEfSObjtJd6K6A1XkuH/A0YHD7JUskDNQxVx401rdpvexeN
         jJHw==
X-Google-Smtp-Source: APXvYqxoD7TJg/5RfiXfJwBrQPJ5TVIwaYDza8AWix3cekWOYoWn0tQ/GaA6txBLqUceRZqwTvpb5w==
X-Received: by 2002:a62:ac08:: with SMTP id v8mr30836524pfe.42.1554744395845;
        Mon, 08 Apr 2019 10:26:35 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id x128sm26790619pfx.103.2019.04.08.10.26.34
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 10:26:34 -0700 (PDT)
Date: Mon, 8 Apr 2019 10:26:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
cc: Hugh Dickins <hughd@google.com>, "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Kelley Nielsen <kelleynnn@gmail.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer
 dereference
In-Reply-To: <1b0bc97a-8162-d4df-7187-7636e5934b23@yandex-team.ru>
Message-ID: <alpine.LSU.2.11.1904081014060.2770@eggly.anvils>
References: <1553440122.7s759munpm.astroid@alex-desktop.none> <CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com> <1554048843.jjmwlalntd.astroid@alex-desktop.none> <alpine.LSU.2.11.1903311146040.2667@eggly.anvils> <alpine.LSU.2.11.1904021701270.5045@eggly.anvils>
 <alpine.LSU.2.11.1904041836030.25100@eggly.anvils> <56deb587-8cd6-317a-520f-209207468c55@yandex-team.ru> <alpine.LSU.2.11.1904072206030.1769@eggly.anvils> <1b0bc97a-8162-d4df-7187-7636e5934b23@yandex-team.ru>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Apr 2019, Konstantin Khlebnikov wrote:
> 
> I suppose your solution will wait for wakeup from shmem_evict_inode()?

No, it's the other way round: shmem_unuse() gets on with its work without
delay, shmem_evict_inode() waits until the stop_eviction count has gone
down to zero, saying nobody else is at work on the inode.

Waiting in shmem_evict_inode() might be more worrying, if it weren't
already packed full with lock_page()s. And less attractive with the old
quadratic style of swapoff, when shmem_evict_inode() would have freed
the inode's swap much more efficiently than swapoff could then manage.

Hugh

