Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B23B1C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:55:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CB4F2083B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:55:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CB4F2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC90A8E0002; Fri, 21 Jun 2019 09:55:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E526C8E0001; Fri, 21 Jun 2019 09:55:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6A338E0002; Fri, 21 Jun 2019 09:55:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A31A18E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:55:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so9293379edx.12
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:55:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TcjMNicHImtNIaiJOvceLYYKAU95NVrH9ZXITGFpy/Q=;
        b=BWsG3v5eDCx6i9PAZ/DDgGZRW3onJw7tbPbNmMg4XcB3t1xQgIGbA5WQUTdBU5FZQN
         WAQ5z3XSiVQAMnnKhZb9/tvcfb5Bkh88/g4YtHMfG9eAFJgqCh/6SzSRiEVQYIjCG4AO
         0TVdSOmgCAi7TYorRZ/9RQBZKqXPxjaWCfuzoZOVB961TQTMchWHkrWBMsbtyhxoXlN6
         4VdEujwJZBGo5F4MsX4I3zmi9pkozNRlQ8sp9DK56YC9g94ngBORrD46nGGG66xpu90V
         sYR8vS2uyA4LdLafLMzw+OefXDOHnBh9a6ZIN8UFWqdweKj1nxaqjQiCvg1iqp4LD80+
         dVOg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXPxn6yuJ4/0pAWe5CmlsHnkjKFYPAO2INFSBY1H3ACP+SgL/Fs
	ierf/SpKR6IRjnTomTBrzfI26U2rR4jH2HUDFYEAJ2n5IO6xWGu7GGispoY0wLPO5iGcEWksBHM
	JzQ1c4Odgs/7P+Nwsrx/wANjgpXQVVeA8ooFCOhqo1G9MtpzaGzq0N+6RsO62rq0=
X-Received: by 2002:aa7:d4cf:: with SMTP id t15mr87962584edr.215.1561125310255;
        Fri, 21 Jun 2019 06:55:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+93S7prf/EWGyNOVflfo0vYVgBbPtclMOUNNALXk3vLAqpLSs8dbDebd3FlxkyJ/Dmm01
X-Received: by 2002:aa7:d4cf:: with SMTP id t15mr87962524edr.215.1561125309643;
        Fri, 21 Jun 2019 06:55:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561125309; cv=none;
        d=google.com; s=arc-20160816;
        b=lHW4tlMvVVb3Ix61h+2MP0aNPQrm1PTNXA5c17fh+kW/Lc3vLMYbcd/2WHgNPv1T7l
         oP4Zh2mzPto2IxPdxwFhkCd6N0/1B0XRM8o1VYkFoo2xgPKk3xKmpXm8Biya3ooxcSMt
         I67Cjv7UcJy3XpdNjTECim+vYY3wIltEY6AYQYWkC5tiuRAqISocqegSxo5b4GCWV8R1
         7uI380j4yEEWOMSeqdF7z2geKvMS3aeAFEwKTP62u8TkM4APhawmVRVRAe+qqb+D1UE/
         KiHrsNThcOY2N15GbY0ZM9H69qamtLODO2q7DswcRglVUrXmZVN0CaKirZIppGm6Gr5D
         C3oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TcjMNicHImtNIaiJOvceLYYKAU95NVrH9ZXITGFpy/Q=;
        b=GdtQsKRxRUFk3eahBTXY8ZB+Tp6l/LiKHA0zzcI++CiqVnWD1VTpxVt8GfxhENNV9G
         rvQCCavkLble1KOaCJl2Yl8Tc+BsR7hpN0d4+WR+F+n1jfMthhM5ODRkI0BBYUOG4Zeh
         I8eZd0RFGXDsU60TtwMH96EvxgBwyWTGxZzl1gGPYxm77R/UAZQCVHT9ziZlB/VdZfgh
         IHYHzKgFXdD0hUrNLV9oeIwoHWKtAz/QiJ6jEIT6h7NM538t3nFrVMV1hYRo7w2QApuK
         hU+YjnBPHmF3KepZ3+AHcWRuFt/sOLuYPzV5vSnhc76NUDXLcu9+sLul/NfQiHeHnXBS
         D2nw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i20si1824298ejv.210.2019.06.21.06.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:55:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 06E6FACE1;
	Fri, 21 Jun 2019 13:55:08 +0000 (UTC)
Date: Fri, 21 Jun 2019 15:55:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, brho@google.com, kernelfans@gmail.com,
	dave.hansen@intel.com, rppt@linux.ibm.com, peterz@infradead.org,
	mpe@ellerman.id.au, mingo@elte.hu, osalvador@suse.de,
	luto@kernel.org, tglx@linutronix.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA
 boot
Message-ID: <20190621135507.GE3429@dhcp22.suse.cz>
References: <20190512054829.11899-1-cai@lca.pw>
 <20190513124112.GH24036@dhcp22.suse.cz>
 <1561123078.5154.41.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561123078.5154.41.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 21-06-19 09:17:58, Qian Cai wrote:
> Sigh...
> 
> I don't see any benefit to keep the broken commit,
> 
> "x86, numa: always initialize all possible nodes"
> 
> for so long in linux-next that just prevent x86 NUMA machines with any memory-
> less node from booting.
> 
> Andrew, maybe it is time to drop this patch until Michal found some time to fix
> it properly.

Yes, please drop the patch for now, Andrew. I thought I could get to
this but time is just scarce.
-- 
Michal Hocko
SUSE Labs

