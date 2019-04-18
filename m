Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 578CCC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:57:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BC8C2083D
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:57:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BC8C2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0A836B0008; Thu, 18 Apr 2019 09:57:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABAD96B000C; Thu, 18 Apr 2019 09:57:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AA496B000D; Thu, 18 Apr 2019 09:57:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0DA6B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:57:34 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x58so2100607qtc.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:57:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/19TpnOWnWWc5OyzFCOchM3J6njWx5JsSLU0Fw9kWGw=;
        b=QXjaOfNqOvG7yfLzegq9Vjc/TerCObJBG8LgDos88mYHpuQv9FyDKZvMD8cMYAtltD
         UYXTP4WZAYZtAay+p45kNNWEbc5VsRXVLDYlSeYPdhJdUbRl+eLwh2jS2O66IQDvbqwU
         KYk+MCUvtO0Q1cIETpOkF9fw68zaR8jvTe9YbNg+ZsF+aWV6IpvYM3HsvvcjK6GAzQOj
         nueuh3tk7NV7mxe74WDyMof8GG46h07KxeRlR0NOOIvxQcF8ecgQfm/9HvO+vpSDxK6X
         82AhMHjri8YhXpDUHLB7devMOqm4L9is8TZUwgX/ADtq2VnbxB24gb8z1j7pagGlg7uE
         ijAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW6kU9oWwNu+SbCNXNUJwF4MqBK/3djq42TlPoip6+4n1Ar24Z6
	UXU1j+28u3K60T9WoFe7L9vbcTJq5FPdcynA7zUu8Gnsvpu4n7mWP5ANat4SuCW4NngPl3kNo6g
	cNjLaQFa3JC5E9BeIeHv/KQsQBc4oRLUMPlj1klfmA+UsktKIV4FawXbxGTV+DRVHgg==
X-Received: by 2002:ae9:e109:: with SMTP id g9mr68619699qkm.251.1555595854201;
        Thu, 18 Apr 2019 06:57:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZ144bYMlupZDr28uEpotcNC0XWO+THsw8n+1pg2ZOVSZhCO2Juwo/LkPrAwcXlm1L2fUr
X-Received: by 2002:ae9:e109:: with SMTP id g9mr68619663qkm.251.1555595853622;
        Thu, 18 Apr 2019 06:57:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555595853; cv=none;
        d=google.com; s=arc-20160816;
        b=I2qdJjpgoKXRKSVuAMjmGeV08tX1qMnD2pU5QmZnOAbq9yzDAfosdM0U8WSEhwJV7l
         +KIa7S/yYmzuiQO/T90JpFyqSp88XDOaVoc96yUj+gs7Uie2lcR2MEdzF2jGJbisGZQ1
         IO0lLDgqMgOmhVRp9BkSczT8gvzBt6oNXHhP+x/mMwwciZkiFuJCxT7zGRUHhXjMpTbb
         lVsbdOsDZvEsHcKmR855yYOKATEqQgJjVxMvy61at8YrkZQNpr7PoXPjBqEbbiNYzXVG
         8XlfnVKsOPc4bv/mthceH7lhP+ihTHR+7l3Naj/MrkF1cW3jqefga7nm+uPkvojkdx5/
         z2vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/19TpnOWnWWc5OyzFCOchM3J6njWx5JsSLU0Fw9kWGw=;
        b=p5Clo6L8p00kL2prUsHooDATN4ovuHkp0ZDq0hIqF4Bk4785HBRX2iMqVu7d0SY+MJ
         n/mGFJ7aGyWFzvnIM14Vvy/T1+yO+FCpUCV6s0KfbNOtgtmR8ZFKNP4O53AfzzormP3n
         KWC0TArG2iquRQVbrjxKc6zoCQgxVIHa9VwZcXbjqFZn4gnSLDSbrIun5/a0Wgv3exLm
         j4pEe5uB6Ua3itbFk/X/qdVKrRxHy7nCdgDeQO+WcI3EU17h5+RHZY9rzG1lUFc1+aFZ
         UUGUaYIDBlswNPlD0HiAdBQgOvjtejj1WDRaoX1cxAK235tnOo+e+cO8Yah+kwPCNAoi
         Iihw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m10si1397728qta.362.2019.04.18.06.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:57:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 097C26696F;
	Thu, 18 Apr 2019 13:57:32 +0000 (UTC)
Received: from treble (ovpn-124-190.rdu2.redhat.com [10.10.124.190])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4F70A5C205;
	Thu, 18 Apr 2019 13:57:23 +0000 (UTC)
Date: Thu, 18 Apr 2019 08:57:21 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Daniel Vetter <daniel@ffwll.ch>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 01/29] tracing: Cleanup stack trace code
Message-ID: <20190418135721.5vwd6ngxagrrrrtt@treble>
References: <20190418084119.056416939@linutronix.de>
 <20190418084253.142712304@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190418084253.142712304@linutronix.de>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 18 Apr 2019 13:57:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:41:20AM +0200, Thomas Gleixner wrote:
> - Remove the extra array member of stack_dump_trace[]. It's not required as
>   the stack tracer stores at max array size - 1 entries so there is still
>   an empty slot.

What is the empty slot used for?

-- 
Josh

