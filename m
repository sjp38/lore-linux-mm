Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0052C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:01:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CD29208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:01:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CD29208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3434F6B028B; Mon, 13 May 2019 08:01:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FC246B028C; Mon, 13 May 2019 08:01:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E3A36B028D; Mon, 13 May 2019 08:01:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2D776B028B
	for <linux-mm@kvack.org>; Mon, 13 May 2019 08:01:20 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b19so2001887wrh.17
        for <linux-mm@kvack.org>; Mon, 13 May 2019 05:01:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kI2y91RRPGT/5VzkD7OKqqkIDn0uCsHkdT99PzPwrJo=;
        b=Su3lxYA1zyl4a0yy/VsWl0cPp0eYoNODEsDB0R/+LrBZy2QoAuSsWCD1K8nsfLHKo7
         T2z9SFhDDe2cEXuqdEEWEj36AHnsLE/poplFm+k3cbAhmqevO3KFT/eTBWEEyDi7Xlg2
         7HpM8sHivZ66eWGTxEcL0Mix9M+n2UmkF9xOe8eHB101+lta2iSexsBKiuvnMnt9PTgt
         q5IoSP3uC4TKeHK6/YjV5xWpJr8IJuGpYlvVqVYXWh5aD1YhW1N3HpZiX5wwPvL9osQk
         MSreUuXW4DutYfyeWEuTn+oVzDCNQTnt/2LAOauZ8lNohq8PWKvifQswiEmabGZmWdjT
         WWbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXHSSwVveyfGRckv2Dm9C7pZbYp9k4uZK4MiU3GOKs2NX98LbVt
	FtcN7Hj1ZrKMb4LRu3PipHOlCR5+78qtCnhyawYu9NCxHb78z5Dst1RIQqFeS8TeOvzSq7R8SPg
	sxD9f0wqPrb4p4cQyI5znLW/nRqprIRFOrJMMGseilHQ/Mhp+J2c1GUeiWlK5kKcN9Q==
X-Received: by 2002:a5d:68d2:: with SMTP id p18mr11214161wrw.56.1557748880325;
        Mon, 13 May 2019 05:01:20 -0700 (PDT)
X-Received: by 2002:a5d:68d2:: with SMTP id p18mr11214098wrw.56.1557748879490;
        Mon, 13 May 2019 05:01:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557748879; cv=none;
        d=google.com; s=arc-20160816;
        b=XNtOW+SQIGzZvhkTrYZHm8fFwgfHMWnxHDd7dEvnaHTs2KiSr5ROGdKes90K3oUKca
         Zh4IsAz6hiXNArFjKGCv6EOo/jp8WXO8RujnmM2wA0AO6/ORLGqLQQco6ddnMxgt2Yaj
         EevU3huuEt3X176Ld1qwLjJoeC5Jwv2ItbbKP7jnMvmcNgNdmOO2ePy7T+7kFLw3jajp
         UjZ34GtP0waZBPa/SXmkABCIbgxZOFDWELfkzHlBzmRfW+1TZ3UxTcnKKS7BRJ0Y/BnN
         FIWliLalUZ8qtQG7rhb6G5NyaZFK4DoTq1UcqCmWtExSMdvj6n02k84iHk2ch+3BYFNN
         ZeCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kI2y91RRPGT/5VzkD7OKqqkIDn0uCsHkdT99PzPwrJo=;
        b=OhX2h2mEXgWt0NwgYx0JRIjgJv61AqrrMcChJnGWFXUMEXBAdFDW2ysa4oyC+RxQQP
         YfklJvbGaW4VcYQ4Ur6js/VgAiXcFMOElQKoMRlIUee3bu3k4R3zy/ZIC7H9Rq8PfCl8
         uo+E7DPFOZGlTr3CBIlaOENbflB3tLZXSfuHik8q+OXtHluTTvUi7jMXNfQ1IYy9e6+1
         4GhxzkI4QuiJRWUTtQQpGQ4SgTiTvt6B0XoKnLxMR47c8lT+Hk9R5htLjUemQKzXKkU2
         DyVHxMlZ+VN+TqhbEyfa40pJr5wsQVMQt/Zh054FVHG0Zs4pn+df+vIleTm5VIZ1qEaG
         /7Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b4sor106471wrt.16.2019.05.13.05.01.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 05:01:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzzL7E0h8PEfT4wZH/Xu0YiRnxJ/Klb7n0tQrDUCbV+E+/M9iajly6wubYQTlzvmAr0yNz3Pw==
X-Received: by 2002:adf:ce8e:: with SMTP id r14mr4611827wrn.289.1557748879134;
        Mon, 13 May 2019 05:01:19 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id j10sm44012622wrb.0.2019.05.13.05.01.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 05:01:18 -0700 (PDT)
Date: Mon, 13 May 2019 14:01:17 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Aaron Tomlin <atomlin@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190513120117.aeiij4v2ncu43yxt@butterfly.localdomain>
References: <20190510072125.18059-1-oleksandr@redhat.com>
 <36a71f93-5a32-b154-b01d-2a420bca2679@virtuozzo.com>
 <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
 <CAGqmi744Vef7iF0tuBO3uBtXbNCKYxBV_c-T_Eg3LKPY0rKcWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGqmi744Vef7iF0tuBO3uBtXbNCKYxBV_c-T_Eg3LKPY0rKcWA@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 02:48:29PM +0300, Timofey Titovets wrote:
> > Also, just for the sake of another piece of stats here:
> >
> > $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
> > 526
> 
> IIRC, for calculate saving you must use (pages_shared - pages_sharing)

Based on Documentation/ABI/testing/sysfs-kernel-mm-ksm:

	pages_shared: how many shared pages are being used.

	pages_sharing: how many more sites are sharing them i.e. how
	much saved.

and unless I'm missing something, this must be already accounted:

[~]$ echo "$(cat /sys/kernel/mm/ksm/pages_shared) * 4 / 1024" | bc
69

[~]$ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
563

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

