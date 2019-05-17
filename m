Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17759C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:20:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7D93216F4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:20:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7D93216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E1BC6B0006; Fri, 17 May 2019 10:20:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66A996B0008; Fri, 17 May 2019 10:20:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50A3B6B000A; Fri, 17 May 2019 10:20:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 016316B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:20:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g36so10943381edg.8
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:20:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xZM2gkbJR+RJIHygglV5ef/fRgWQktK9UgzdJ4faIxE=;
        b=g0Zk0L47HzSojqv8X3av1rjEYxMeOgeVWGjoNZKphyuUP+yjdT8ndZGFJBQKX5Nxei
         SeA+jlHtQoCQsFJBrRGOdE9kCGSwQzq5cnKJdLuEzrKMTzLYi/hK/roVLjVbn2mAjmtS
         Hk604Wo4gSMnbfwMywY0898/KybjJlmoX1cLjPBRX/YERJhk3Smdn3bv3nlvXwv3N0lQ
         jwgh2NV36AZWScq7qZnMEPLFuHrQYS3LQExNMnDtDtjl3KwWD5CuFYjBmHpyN9pb/E/U
         QRDH68Vcn4hqEeJF6qRsavq3KCmRdb89Pb6BRfKGEy/MXjGkdwsYOZnf075Va/ngcVwh
         MWpQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUNKgOmLzGD1s6GR2ObGCYccE2LHw8U0DalnqZlXYhcIMvzegQZ
	tGxQHChgOKQlsndMjQXJDcHoEgaMkLZm8oSqPqzKSCFgjjCndoZvIx1+atE3KGcUvfHsVtsoxEP
	7Hc+1RkFh7ydSPfa6SHuwvRQ4pTwRjWlGh0+aejH5tcqmWnSUBqpxB6u8sAz61hM=
X-Received: by 2002:a50:95ed:: with SMTP id x42mr57390048eda.103.1558102850485;
        Fri, 17 May 2019 07:20:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoA1eUbiWUnOlKWCLxngJ6c791AGEsfmt2kyIHlOBTUjkWET3PD5HdGUeFO2hkqJsgL/mV
X-Received: by 2002:a50:95ed:: with SMTP id x42mr57389967eda.103.1558102849768;
        Fri, 17 May 2019 07:20:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558102849; cv=none;
        d=google.com; s=arc-20160816;
        b=ntdzZNRaEb2qaFKi82rtRUnJuk0xFk8FHsWPLqGSm5qi+VYpJvvbIMAj/9AUtVHFq2
         otqBIFy08KGr/l77bSL4kFlq6YKFNyjz2KwMij/BhtHIrCJwrnLTyaKnCZe682aSDxkK
         VRsSOz56LATtTIIswNs0dYepV/J18FmEdFK2NGAGkaaF8N/OwfW4Wry+isWhtmP7q/3P
         C6XU/gWlHRJ60dwcLfTxXv4QA1WX1zSj6bpvB6dj+J5zJYtJ7Nw83LlNHooksvRHp6iP
         JZYtLwoFNNS3WKMtdemRnouPBFQELI/US95PZqS55xD9/8XTve26e4B1OTjQaKfIKuFW
         kg1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xZM2gkbJR+RJIHygglV5ef/fRgWQktK9UgzdJ4faIxE=;
        b=UiPS7F5ESK80906URf8zeBQ5F+zjU8nCHS4mTEB1X6vU1ZdrX+LSN0WCdyajSeqbEg
         m4xdO2goCRN29Bk8StP2FutiIXlML56mG+9I2Dk1fU/m9eTB25SfWEApYnrIDIKmkP+j
         70rz/HjZbzdTYR58MrqM5phuwU4W3BCwcfvuRMaMOI/MLIvAaDlcxIMetu+oulXcUW2B
         LIUekjDNDlJaOLghui6HXCWg+ktYhK6FO4UW0Myzs5zuQKsIyCF0zhqtGAHCP2HEVU3b
         ppv7pbIdP827EakpEJXM/PcjcWCHETA0RWBGoPYHVyzwZhVLe5tRtI3ow9V3SMOWXTxY
         z2pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z55si6196154edc.325.2019.05.17.07.20.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 07:20:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0E81CACEF;
	Fri, 17 May 2019 14:20:49 +0000 (UTC)
Date: Fri, 17 May 2019 16:20:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190517142048.GM6836@dhcp22.suse.cz>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-2-glider@google.com>
 <20190517140446.GA8846@dhcp22.suse.cz>
 <CAG_fn=W4k=mijnUpF98Hu6P8bFMHU81FHs4Swm+xv1k0wOGFFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=W4k=mijnUpF98Hu6P8bFMHU81FHs4Swm+xv1k0wOGFFQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 16:11:32, Alexander Potapenko wrote:
> On Fri, May 17, 2019 at 4:04 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 14-05-19 16:35:34, Alexander Potapenko wrote:
> > > The new options are needed to prevent possible information leaks and
> > > make control-flow bugs that depend on uninitialized values more
> > > deterministic.
> > >
> > > init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
> > > objects with zeroes. Initialization is done at allocation time at the
> > > places where checks for __GFP_ZERO are performed.
> > >
> > > init_on_free=1 makes the kernel initialize freed pages and heap objects
> > > with zeroes upon their deletion. This helps to ensure sensitive data
> > > doesn't leak via use-after-free accesses.
> >
> > Why do we need both? The later is more robust because even free memory
> > cannot be sniffed and the overhead might be shifted from the allocation
> > context (e.g. to RCU) but why cannot we stick to a single model?
> init_on_free appears to be slower because of cache effects. It's
> several % in the best case vs. <1% for init_on_alloc.

This doesn't really explain why we need both.
-- 
Michal Hocko
SUSE Labs

