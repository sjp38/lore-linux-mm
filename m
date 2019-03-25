Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A9E3C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 00:38:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D40520989
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 00:38:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MOzZJyON"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D40520989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14F306B0003; Sun, 24 Mar 2019 20:38:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 100016B0005; Sun, 24 Mar 2019 20:38:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0148E6B0007; Sun, 24 Mar 2019 20:38:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C460B6B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 20:38:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so8018165pfj.22
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 17:38:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=FaNqeKntDsUnWDCHwttPTsMhwuJvMkwZoo20TlFjRFM=;
        b=B2TZkAij6/Qh383/moJHvkfcWcodr/cQONfPZDDhBVTzuBF7P/DPT/WwzvzlSuQ35G
         QlZZd808LE9CxvBD+YPoZ5gge1Mg9YFn6ua5m9gz0+k69oX051PbRtiNE4PIX6yZts/C
         +dlCjQSgOARC3c2gUplGsDPDvI9bgj3p35s2EYUsUJsCCLP0uKMTaOK5iuOIrnXEwViF
         6Sews3rZnOMAENbEeJI9yLovDjBS436mVUGq4smvO4g3zy7DKR0NDxtd+XY5dntdZu1y
         xswDFXVDoyo4hypFLVISiwp6zbpwXEkwdz63aeOVLAUlDyco8RVmgmeZ/FV6Vxo4vtu9
         FWWg==
X-Gm-Message-State: APjAAAX5W8/CsywhNUNtfYoHrF9MSXD+VH6lGqElF5Ur4wkkM5yI29Ws
	vDwcUu9g35xRBuNfL2TJQmKfDcG1WeMI4qNYf1Kypm2OiNoyA0ItpPPI+FecDWkAKmZQFTf2/rF
	b2b2C5N6k7fqAlR+fxF8qqUXaBCa+rdZad5hlav8QvIDMM1c++hzj+iylY/CATpo9Qg==
X-Received: by 2002:aa7:8818:: with SMTP id c24mr21171130pfo.129.1553474302317;
        Sun, 24 Mar 2019 17:38:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwH6kyafIPPXCc/kvOqoDbaPPQAgZnI4V6Dtc64iLgpqkH97XHs+ZFKYpOnWDDYPKo9oZXW
X-Received: by 2002:aa7:8818:: with SMTP id c24mr21171095pfo.129.1553474301550;
        Sun, 24 Mar 2019 17:38:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553474301; cv=none;
        d=google.com; s=arc-20160816;
        b=fhzdxZre/9DjZC0B/vMt7f8bVvptgwiDQk6JdYCjAJojJMG4Wl6TgM/quK1g7jDxqq
         CEG7iOjmTGWuH3r1mwwC06xbTNo4FUmpdqGMou6yUUSL1WQM0bhI7bqqI3JbOvU+IdHw
         SzP0J4RL2UN4U3Hyqzy9Mcc+EB8D+lOcNEgDn4kWAh2uXmRVzdKPsdX8q9zQhmyUjkud
         b237VNiF0gd7QlyFyxqBD81goCS6ELy5itXYM+FGXR6o59xGo0VuMZdgVFQQA3V6TsNk
         sU9uwEIbDXcrWp2VLp7xHvjabdPG2ZWeB3Cgo4isIiblre3ZsvsikmrZ24Pl1shUSpAE
         fbPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=FaNqeKntDsUnWDCHwttPTsMhwuJvMkwZoo20TlFjRFM=;
        b=IbgllNCSUyvWkgtZ0GXO8Esku+hne4z/vwZJWH1CftL/PjRZtwKau1bYY38y8NsT83
         wSNmX702SkLiwlB7nYSjy7gQ+ssArOTRb8PcsMJ78qamhhZKay3ePNytydAd6kHsAIqW
         ZcIImrbYDplFUeLVIExXuw/WKEB9VF8nBaresYdMjl0XddkvXiFDvSwuePjDyNfoWdxS
         VUYHGKWVJg8VE0UyAzJylpIp/X8ClAgc00j5lzsSkBUpMtkKsR4imINYfaDINQvT1TaK
         w0Vlj0Mg0lUvuKNJ+tc+k0QUSHJY0h03Qa3tDVfBPDMGei7E6i060Z5l7xMLC+y3/Hag
         lQZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MOzZJyON;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g21si12037169pgi.448.2019.03.24.17.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Mar 2019 17:38:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MOzZJyON;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EED802147A;
	Mon, 25 Mar 2019 00:38:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553474301;
	bh=b3FdcOo/yx6+auoaIXIOAxItI8WFJVEIa4NBOmTecZQ=;
	h=Date:From:To:To:To:Cc:CC:Cc:Subject:In-Reply-To:References:From;
	b=MOzZJyONKXs2b/5tpM25wlARbVRU6Vq+trkyOeMnkMPp1l+t04BeaVEi7LHol8Rqv
	 9A8MC1ZbCi2MvMc+PJ73XBixO/N9RoO/4eVUkbi4nKG4t2+xhFZxQFC42sIQGlT5zY
	 HkKEbNbBSSNUD9kKIvNxHHjqZw/tzroBbSAcCHMg=
Date: Mon, 25 Mar 2019 00:38:20 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Jan Kara <jack@suse.cz>
To:     Andrew Morton <akpm@linux-foundation.org>
Cc:     <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>,
CC: stable@vger.kernel.org
Cc: stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
In-Reply-To: <20190311084537.16029-1-jack@suse.cz>
References: <20190311084537.16029-1-jack@suse.cz>
Message-Id: <20190325003820.EED802147A@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: b2770da64254 mm: add vm_insert_mixed_mkwrite().

The bot has tested the following trees: v5.0.3, v4.19.30, v4.14.107.

v5.0.3: Build OK!
v4.19.30: Failed to apply! Possible dependencies:
    f2c57d91b0d9 ("mm: Fix warning in insert_pfn()")

v4.14.107: Failed to apply! Possible dependencies:
    f2c57d91b0d9 ("mm: Fix warning in insert_pfn()")


How should we proceed with this patch?

--
Thanks,
Sasha

