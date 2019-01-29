Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A980DC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:49:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 541A02147A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:49:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 541A02147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6B3A8E0002; Tue, 29 Jan 2019 08:49:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF2108E0001; Tue, 29 Jan 2019 08:49:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BB628E0002; Tue, 29 Jan 2019 08:49:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E03F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:49:24 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so7970071ede.14
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:49:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UzqVNet3b/UgBm4C+cMBdyDexbf7bVMzh3zZt8Ri8lQ=;
        b=OgE/mFyFnNDTc8NSsZC2FQmWabf56Qx1vNVvCiVJmZ4x8PG5zJuPcbv14j+VAAqeT3
         KaoOjmJaW3OnV7hnMCb6ozSGxS/vbHOezW7BepXPH7uiKaw8n8Q21nKGqrLNtc5t+agQ
         EBsfPZ+/W5A8EHuJglS28ZTEilHwK+4XgoaFjFvEVrapUhzcLoaymzLcS8QT7mfxR2Hk
         L4RG7Yg0QWwrrHwKZkP8D+WFLK9r+aG3Hpe+uh6uH7c8pkC8Dx6+pvfv6EY8A5r4qrO1
         398qADjQ3MnSG9Q1vA+LxJ3nzcZ+i/BMUltOii368vmJgbKZcDbffkFM2nu5I90lOWRn
         Fvxw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcA0lVfM1vHsY+ksBY4fF3A8LUTQMaYYuvTEOO/LIbXwb0SEkzf
	zcd/2Hs1mc78yIj2lkqoHifWbhlHHJWnaVQcs2ora+s6HdWncf/26TXjbAHTDrmVniN9RBFmTKd
	IEciNERig0ltuSPWl5AmTPvTFXupPPwkf3xkg8eAmuv5VRnKA8OZxtrtT6dXoFvs=
X-Received: by 2002:a17:906:1c86:: with SMTP id g6-v6mr22982581ejh.195.1548769763715;
        Tue, 29 Jan 2019 05:49:23 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6qv6bcAAj/A7NQWGxieePn4yeR3uKpMRRgdNPZq/tKaOyFdTABK44g0ZGekpduR5zkI+hp
X-Received: by 2002:a17:906:1c86:: with SMTP id g6-v6mr22982531ejh.195.1548769762708;
        Tue, 29 Jan 2019 05:49:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548769762; cv=none;
        d=google.com; s=arc-20160816;
        b=pxZWOhPlpyCVmbf9uWe5wiw6G2NbX1L1BErD+8nSUJuFewcKW8Dt3MgNp5Ck3KtfYJ
         TmoOoOmmJbHfXbqU+EsjHBNd/wDE4OjKyxAWTzQeq/kUDB9RKo0aIOuEdzTedr//wl/c
         3YbZsCY9OPUd5l1rhfcVdVrXtNMgqk5MA4hBcUoqbdnvoGGVTpi7T+kmK7rZa/W/7zSm
         3UGuXWPPwnb9FOH4MCd2EvW5cxV0EOPdEEFNBpUDttFeDLMRnrYgx9S1ezFzb07mRtig
         MqiQJLu4sdrP4jhsm4cdAhAzgL+5evnNS/+0oI5Fq6TMDodd7EsBLSIimqawJU5qrD0s
         U0Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UzqVNet3b/UgBm4C+cMBdyDexbf7bVMzh3zZt8Ri8lQ=;
        b=rV8sO5O5QlDDySzm827N/y9HQwyEeKMJZXjIEPNC9snLtgf+vj9Y0SgoAz4p4A8yMI
         kl2/L9/LAhpgScW92nuQVxP4QWS/wOe+dWSadNEn3RD8dYOCeMjatJxaAXuiJzoj8xUN
         JGKfzid67Aqc11xHoAFxON4qVpB4eOOZwzygyBMYJifrnfiJAnycGqjfka7hSZHgItlV
         m20/L+U26Yl7FpzBHzgMgrw/VWV3vRpgW1skm3wsGE9T4IVvlnwZdGA8raC0pDtfLOtD
         lQqFvXhPYJwMYq8gcr4eEbQYEDZpYY6CoKs7rMMYuVX3HdEnw0vDOFMRfcN7ry96XSFC
         fBKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n3si2585291edo.15.2019.01.29.05.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 05:49:22 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E4EE7AD5D;
	Tue, 29 Jan 2019 13:49:21 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:49:20 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages fallouts.
Message-ID: <20190129134920.GM18811@dhcp22.suse.cz>
References: <20190128144506.15603-1-mhocko@kernel.org>
 <20190129141447.34aa9d0c@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129141447.34aa9d0c@thinkpad>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 14:14:47, Gerald Schaefer wrote:
> On Mon, 28 Jan 2019 15:45:04 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Hi,
> > Mikhail has posted fixes for the two bugs quite some time ago [1]. I
> > have pushed back on those fixes because I believed that it is much
> > better to plug the problem at the initialization time rather than play
> > whack-a-mole all over the hotplug code and find all the places which
> > expect the full memory section to be initialized. We have ended up with
> > 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
> > memory section") merged and cause a regression [2][3]. The reason is
> > that there might be memory layouts when two NUMA nodes share the same
> > memory section so the merged fix is simply incorrect.
> > 
> > In order to plug this hole we really have to be zone range aware in
> > those handlers. I have split up the original patch into two. One is
> > unchanged (patch 2) and I took a different approach for `removable'
> > crash. It would be great if Mikhail could test it still works for his
> > memory layout.
> > 
> > [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> > [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> > [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz
> 
> I verified that both patches fix the issues we had with valid_zones
> (with mem=2050M) and removable (with mem=3075M).
> 
> However, the call trace in the description of your patch 1 is wrong.
> You basically have the same call trace for test_pages_in_a_zone in
> both patches. The "removable" patch should have the call trace for
> is_mem_section_removable from Mikhails original patches:

Thanks for testing. Can I use you Tested-by?

>  CONFIG_DEBUG_VM_PGFLAGS=y
>  kernel parameter mem=3075M
>  --------------------------
>  page:000003d08300c000 is uninitialized and poisoned
>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>  Call Trace:
>  ([<000000000038596c>] is_mem_section_removable+0xb4/0x190)
>   [<00000000008f12fa>] show_mem_removable+0x9a/0xd8
>   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
>   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
>   [<00000000003e4194>] seq_read+0x204/0x480
>   [<00000000003b53ea>] __vfs_read+0x32/0x178
>   [<00000000003b55b2>] vfs_read+0x82/0x138
>   [<00000000003b5be2>] ksys_read+0x5a/0xb0
>   [<0000000000b86ba0>] system_call+0xdc/0x2d8
>  Last Breaking-Event-Address:
>   [<000000000038596c>] is_mem_section_removable+0xb4/0x190
>  Kernel panic - not syncing: Fatal exception: panic_on_oops

Yeah, this is c&p mistake on my end. I will use this trace instead.
Thanks for spotting.
-- 
Michal Hocko
SUSE Labs

