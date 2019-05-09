Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D024C04AB3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 12:23:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0354521744
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 12:23:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qk8MMLe0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0354521744
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 321776B0003; Thu,  9 May 2019 08:23:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D4886B0006; Thu,  9 May 2019 08:23:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E8116B0007; Thu,  9 May 2019 08:23:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C35BF6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 08:23:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f41so1390008ede.1
        for <linux-mm@kvack.org>; Thu, 09 May 2019 05:23:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kK0i9uM3pyYFcRAwxUAkFyXbwheiX8gFOss9me4xCFo=;
        b=FMEUhdXau61VPvmp248sGODZaquYv3y4fSAz66CVtp3YVMQIVSJRJkzr9b4vlaTOUY
         Ixg7yEyr0iJ/fZDVzS++CdQNnaeXSLkiJxM5/3+zY0UH8x1+Y7Ipt7LwhEYQTlMFIDDF
         eQt3ES3HRSowJiJNwX+6ZOx1p/xq/nMNptRU94oMqlTBpU/LNgDkqifVSBVSrmaL7b9r
         SJ9edfWTTSJyiN2DPjyMG4bAFbYGdszIE9ZdrF4zI9SOWGQntWLIl5RmTDTR8Ma1L/GQ
         IZcuP7DCf6VOXA25b54akOk5UIfSmHxNMVJeTxmC910a29U0Vkl1qLQVSYX6luYeEppu
         1pMQ==
X-Gm-Message-State: APjAAAVCcLpvBj+QUpW+gDOIcymOEUb4aKz5fZLpoN8EHiVqxmFOqfYS
	rZFzy+NABAfxAUmptaiYtLgCpmhXv2Y96Phhc4n5/uDrXDvCh2DO192SaQ6yv82Yd8sHRx7XtFb
	D1YHF4dM9ojZQlcOlZ9TFTQw7zN2IfjSeczKXFYYKRDTpvCsWw7gUFgcyeHaItG2Uhw==
X-Received: by 2002:a50:a951:: with SMTP id m17mr3454228edc.79.1557404588124;
        Thu, 09 May 2019 05:23:08 -0700 (PDT)
X-Received: by 2002:a50:a951:: with SMTP id m17mr3454146edc.79.1557404587254;
        Thu, 09 May 2019 05:23:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557404587; cv=none;
        d=google.com; s=arc-20160816;
        b=eHdo9VFzG0sRTB8v/ZN51xqAj47vUiYTAW1+SH1Et5bYL7VdbpnWBVh/sqFfuOYm5q
         uemer8S/kd4l9zwQNsE7JrqCoRRFI93e2bYHssFmN+gsvRBG9GUF4khjR0DGW5jZnc+D
         LTIVLyAbKcgvH/JWC2AMwnG30ZMfYY2vTyNgXhIqyT6b17BkPXsE0QlFvVM1ogUF33Rs
         Mwx175bXD/RDyfroqPLo4lWhIINeXqE2kE1kP7IhqHUMqobfNNxJ6XpN6BUqkRznjkBb
         wHLjYkqKjLfCZQNTh944xHfXMbZPEvAa63j4+NJuTezJSZrbPJjeYG6TDcE/DEz44aaB
         4TvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=kK0i9uM3pyYFcRAwxUAkFyXbwheiX8gFOss9me4xCFo=;
        b=X96uLCl4HforHRSkXNgmaLBDYBpMM8SN5P0SMEHE9sf/zJduGeToD7iOeAj+id3GMZ
         T43AqsteOTpM5e73QVyESy7WkY2AxY8EL8mtq6eLo48mdDGCUSh30yY0e19QycSwVifw
         aJwmr7qNx7+2OLTxwe+rBQ3n7APqopTVBGgQLY4r9E85I5D4N1rQtYhKXTQ3lspkXxlR
         /ye0oCb7cSP8ukysIfGT9FtML/ab6FyIqLomqOuCDqEcdFeqKHjSQuUI+MtMo+EHFlpV
         JEZeCJrsav6U4J94fD7fjHAebFMqxknxleoh+r79byMqVsVWl6SQKOdP+TZ0vsSZ8FOk
         Flhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qk8MMLe0;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m18sor656184ejb.22.2019.05.09.05.23.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 05:23:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qk8MMLe0;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=kK0i9uM3pyYFcRAwxUAkFyXbwheiX8gFOss9me4xCFo=;
        b=Qk8MMLe0+SuyWjMgP91XatGFW2t4dggZxTtSGYKpznsJLPVr8BcONtuSS7vK2+gf7K
         AOz8f2Re+43WGH4w2gU97ZACFASGwvlJ9BsYZk/I6zKhqxZtdFYrjX/38dnU40HQkh1U
         G4tN2R4s9R9CwWJ/bmndCbeWVPryUwwLWlbwiPDwH/eQq8vJx/xuBrsY/S0DY47vftPl
         beRNHavogoku7ouurr5Qk28cy6CYq3fUoDbbB7XwFqW/xUFQkGf9jzXQyPoxzYSR02oS
         LuXCyGRPIx2GXpfe/NaXJcWMPc29xGk8RCsL4VkdyzOoOb94p8cK40z5g0o66s7TUtCa
         IGkw==
X-Google-Smtp-Source: APXvYqx/LQ9p+oEzzHrZ1uIdWPZDCJZ5+WDWvbYvuz3X/C9E2PgZsOqljcdk3brSDSoy+FnXpjuuOw==
X-Received: by 2002:a17:906:5013:: with SMTP id s19mr2949960ejj.203.1557404586529;
        Thu, 09 May 2019 05:23:06 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id c2sm299961eja.61.2019.05.09.05.23.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 05:23:05 -0700 (PDT)
Date: Thu, 9 May 2019 12:23:04 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v2 1/8] mm/memory_hotplug: Simplify and fix
 check_hotplug_memory_range()
Message-ID: <20190509122304.haksywk3p2ks6gcg@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507183804.5512-2-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 08:37:57PM +0200, David Hildenbrand wrote:
>By converting start and size to page granularity, we actually ignore
>unaligned parts within a page instead of properly bailing out with an
>error.
>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>


-- 
Wei Yang
Help you, Help me

