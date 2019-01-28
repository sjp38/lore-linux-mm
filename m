Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77E66C282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:22:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34AC12171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:22:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="BWUNZDIv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34AC12171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8EB18E0003; Mon, 28 Jan 2019 16:22:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B171A8E0001; Mon, 28 Jan 2019 16:22:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B8818E0003; Mon, 28 Jan 2019 16:22:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 727C08E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:22:17 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id b20so9102826yba.21
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:22:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=R1tczXKUFzCTDG0EEeYL9B/rEiyBaMRbEigEvPcalsM=;
        b=Wd7MCacMYOvGjSgsjWHjAD5hXYyJ7l7cwUMoRVzQYTyE0C7RBSBSb2TyrOpntItv2d
         C2xUClXZYsfUP98o6L7ty1fkHrcM0UiW71m2CcMoNq9eJGfrwivTf/AymMUOuHQ7tiMA
         w9PZ5TDsRZSzd2nbwyzQLPSQf798OauQKI3cVNvIyC/9rjRTjWWilzoP7cAMQdUvbFUM
         Rdd3S+btBF9oWW20ixSNhzAs7A9UnrF7xVlXOdXh+cZHOCqAudT31Hm/LC7XG487kkay
         w6rbbcjhfMsPcP6HNZyi/fpRdW7uYcZuS82ui8U+iv47jdYBKOBETj3eLRk358ZljQXy
         FaeQ==
X-Gm-Message-State: AJcUukd27DgHlgOFYySMzMvbi4Yk7T+VlJahAmzk6I5DzLIGkN03vZSY
	iDbU1T8CXKAQyTqISOAAsFsNQRiyuAxCeXqZU1xy3ZddqvA+7oIqvNDthSAnqX+dJ8y253kARC5
	EczKFM3tGOSZvcaOIqT1DtyvxhRDYo2nO/2m4MEtasw9uaUUyeiyoJ4rQAl+0zkY5I3tseS5reO
	mSVXvtU7lIK7/8RAsxLjinWvBA8DEXAinGdz675GA7ueeuGG3+NBuqrin40wkD7Y2lAVA5Qdj0J
	txUbxES/Li3f4YSKRANeAGRbb0NdHZVDFFcSMmieOrfq+vzZyQ9JAs4yzzri+TMrSDxHVmxWDBn
	LcprI4rDOQrIlviRAc9KQybB6T0rObC/YFBvdSSKli2Fua45QHe3P5SCyK8k9ZtUSNEAudnM1Zf
	b
X-Received: by 2002:a25:3805:: with SMTP id f5mr22543712yba.361.1548710537110;
        Mon, 28 Jan 2019 13:22:17 -0800 (PST)
X-Received: by 2002:a25:3805:: with SMTP id f5mr22543685yba.361.1548710536574;
        Mon, 28 Jan 2019 13:22:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548710536; cv=none;
        d=google.com; s=arc-20160816;
        b=HhqWaJEaMU902zGtu4seSUSQEa4FDFjx2We4dj+aoCclygN8dAQS1RTiCiwgjuKicI
         WDoQATz41PgOBIi9MBMJq0omlQ6nW+LqCZYfTwRO9x33x/7ZVpxQZHbi+cgvSBhfrvX/
         6naDn8/IdTgwQaADFk/72+GOaDH9MXS7I3hZ7jjK+ejL6uFGJT5GsCHSKfu0S2f9Edan
         5Ehse6heNHVRHTDx5aVu3y+M0sO5ya785mZzYNfHelpq+GgdpFs9NTBrctmRNTQdj+iB
         DHkTL8hhuOOMWjRUmv8C6kSRDLlWbEf/yrbRoaq0Fn2jbg+YqMp+zxlXN/H11Er0Iojy
         nwYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=R1tczXKUFzCTDG0EEeYL9B/rEiyBaMRbEigEvPcalsM=;
        b=E9hU3taNCUg4R+x3AoE+5D6V1qo9KSdpVaXJOcvypNXpFwtyw79IcPVdVS60D28ex/
         tffzNhXpbJ5EFqx39hNT5QpCwOQwiP0dfdL6+pyblvFT6aCg3H9OwWjWUyJfW+Z09+rP
         BIoVNjQUfT9/gDpBTcJIVXmSsHf9VBz4vAvicJ7fe4MgNxWi0Ccc07bg0xkbvLyOTXu1
         5SzEdQeQIeatrz/Uevj5fQCjrZupzg+NNEFChhc4E6dsG5lp0R2jLg3tu7Q3Cd4w2k0e
         2LLycvc8P0IotyYKBv2b5aphRgLJMIueG2zfrOTziotDLHftyV++ZpfZynszKeV2dyUl
         +acA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=BWUNZDIv;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r16sor15266431ybd.77.2019.01.28.13.22.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 13:22:10 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=BWUNZDIv;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=R1tczXKUFzCTDG0EEeYL9B/rEiyBaMRbEigEvPcalsM=;
        b=BWUNZDIv09sdTYAuXBiMqvx25t8xYdms70LlJhXdraVVD4ND8QZS1Egu8kl28LrAv4
         2rsNe0xfjtXsa/7pAXDQX6XO7sQieqd+EoOUKyCtprrkAymp9xe1Aeo74Y3eoOJVKeVx
         I0w6f357EMaAsZhJCUprEfPEHCLSP0tmMJuLaozqSHfrax7T2Pd23uVXFhJM/TXo9Rtj
         PtLwtSrHs9eF41prnQYcst3HKBz6IZj/I4ryQ30PPfy07J7OPxoEMq7LNSjHJp/VE7vL
         sg4s3VlxembefLFtixuvyf9Ov0Z+CqLqVM1dYMADBiaWsKBM2idCLIzQtE30kWIsBQOi
         9yig==
X-Google-Smtp-Source: ALg8bN67pMPbU43pXLl6O/DjG+0UAfhqYH7oETTn698WBm4AXKfHjyzns7FKkPi/tFPcEFuAgdI2CA==
X-Received: by 2002:a25:cc04:: with SMTP id l4mr16091947ybf.50.1548710529969;
        Mon, 28 Jan 2019 13:22:09 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:42c8])
        by smtp.gmail.com with ESMTPSA id i128sm13849151ywb.82.2019.01.28.13.22.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 13:22:09 -0800 (PST)
Date: Mon, 28 Jan 2019 16:22:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v3 3/5] psi: introduce state_mask to represent stalled
 psi states
Message-ID: <20190128212208.GA1416@cmpxchg.org>
References: <20190124211518.244221-1-surenb@google.com>
 <20190124211518.244221-4-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124211518.244221-4-surenb@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2019 at 01:15:16PM -0800, Suren Baghdasaryan wrote:
> The psi monitoring patches will need to determine the same states as
> record_times(). To avoid calculating them twice, maintain a state mask
> that can be consulted cheaply. Do this in a separate patch to keep the
> churn in the main feature patch at a minimum.
> This adds 4-byte state_mask member into psi_group_cpu struct which
> results in its first cacheline-aligned part to become 52 bytes long.
> Add explicit values to enumeration element counters that affect
> psi_group_cpu struct size.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

