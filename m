Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09BDBC4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 18:03:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5E6920870
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 18:03:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5E6920870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 672F06B026B; Mon, 10 Jun 2019 14:03:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FC136B026C; Mon, 10 Jun 2019 14:03:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 475C46B026D; Mon, 10 Jun 2019 14:03:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BBBD6B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:03:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e16so7367754pga.4
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:03:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=XeUuZJIqgFh2AOYyDBiTJRoH+VW4wwivg0ytgU9RuL4=;
        b=EtFp29/tWlpnEhxdxDyrGN+yhFCw7TybAqnR5eSHKptVplCoTWFnFJx2NhpSkoNAY4
         /1tBuukl+dCpqUpt6TyfIjwur3jwcAhfRw6y9RHaP7gqt0X5MyTlKh0q6y9GWEGneyqb
         RVcpT9ri5mS+XDvLG2xnnOnV117AGXz2wP5J/5iIy/YS5DeE2uCIMsa5RHAkELHX0O/t
         N8n3PayjRq+G0Vxr331VwFupo8R7aJfBojALbD0ELBXOiJZFZkv/hYmMrCvOmFcYqHSR
         zY4QOeHoca1QLtFxoMMgWsZikTbRAubS9pA1RT8UhK0vm7szUhfjSCUWCbTSb/nRy+rW
         /Iiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWYv3uquaZ+jtpI7iDyvgeWjcesgX4avAnoP227b93W9/yn7dSc
	XkybT7vNH94X06dlzaQHUb8zcGTdSKGi6gjQiSUtl/6DYIx8hjtBA1NHOrQGjtH+QEGtsH6e0xT
	tvXnT+eZVaiydrZF0spxAYfx0GKGqc8382XBYQdO5Zbm7kkGlbFuPnKnnixURVfhEpA==
X-Received: by 2002:a17:902:165:: with SMTP id 92mr44210077plb.197.1560189781718;
        Mon, 10 Jun 2019 11:03:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxe6nE1ZO7dXo7yTuHdmmsESQ9T4N4nQ3ni44s0BQhBNWkXHfwVx47HHm8OoTyzsiyeLBo
X-Received: by 2002:a17:902:165:: with SMTP id 92mr44210029plb.197.1560189781053;
        Mon, 10 Jun 2019 11:03:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560189781; cv=none;
        d=google.com; s=arc-20160816;
        b=VUznwBrX/H83CczpOvWwFEuCLhKVPdghbIhchvT2b/cyWZyMmf97qlndemfnwJ8JF9
         lR9qS7wMNzplEi1Yp5EQI3Ytryv6LNsU3j/PQIrWWis/eboRaf/VfYnxQAWOWgALCRUd
         Itl0DVzH6AQPMNe1sTBIc9jHHNerJvdhCGIBScIF6DqF27/FE5QVTJYtPcEzwPFuDKLq
         t61BzWmvNbrzf2w1TGqvYuf2IzsMbM7oYF4fFRhxgRkzpizfD9i5X1Tach3RmkD+dIYc
         VZY218ykNqxZucaRwXCaYsVf8BO/NfOk0Gg6oE5dImLMsd98ONYrqcDLYpKQxMzvC2JY
         vjAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=XeUuZJIqgFh2AOYyDBiTJRoH+VW4wwivg0ytgU9RuL4=;
        b=oAF89brZH1Hdha07dg//u9Yv767h3bnPLqbInrVR60SOtqf0mx7HV0uZgmGZWziuLE
         LyVSC0rDj6WKpSTcVjw2VJgILd+RK+kltrQsGHR/yP3bHGUj5Xg6jHSslpcsJ4RHTtZz
         zteCQAHLfRJLSfSmDwuluOhOdgXNIlrLSW+ceuTcGCEG0uDGrj4vVFcc0VqGxdBBrwyG
         jfuXEBJd3ZRVlEthR4H2L5oBeQLbH+M/W64lyqU4BhKTO+OWplLWbTDFTiUC280KSrX0
         6VcprT8k9G4bwf66sqlYOy36/ttf+vJoVcOsqMAMqZNPUpoKr5G7bz3WWYKpCHPH1H2K
         qRdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r20si10290815pls.389.2019.06.10.11.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 11:03:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 11:03:00 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.198.156]) ([10.7.198.156])
  by orsmga002.jf.intel.com with ESMTP; 10 Jun 2019 11:03:00 -0700
Subject: Re: [PATCH v2 0/5] Introduce MADV_COLD and MADV_PAGEOUT
To: Minchan Kim <minchan@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>,
 Joel Fernandes <joel@joelfernandes.org>,
 Suren Baghdasaryan <surenb@google.com>, Daniel Colascione
 <dancol@google.com>, Shakeel Butt <shakeelb@google.com>,
 Sonny Rao <sonnyrao@google.com>, Brian Geffon <bgeffon@google.com>,
 jannh@google.com, oleg@redhat.com, christian@brauner.io,
 oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com
References: <20190610111252.239156-1-minchan@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <21cf2918-ba0e-aae1-a20e-36ee1ad4f704@intel.com>
Date: Mon, 10 Jun 2019 11:03:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190610111252.239156-1-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I'd really love to see the manpages for these new flags.  The devil is
in the details of our promises to userspace.

