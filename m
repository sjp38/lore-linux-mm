Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46471C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 09:09:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DC0B2173B
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 09:09:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DC0B2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F3506B0006; Fri, 19 Jul 2019 05:09:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A4F88E0003; Fri, 19 Jul 2019 05:09:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B9F18E0001; Fri, 19 Jul 2019 05:09:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 400176B0006
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 05:09:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so21632291edr.13
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:09:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/cZLJMgOyXJoONutM7J3PQbctfT71JeLJvPhbAg7PME=;
        b=rX2ImkleXdW23Kmm7oGKnYX0+RgmfV//JXsvOPhITyB+3zUm37QxdoXUNJQg3NpX2q
         5FIDKTZYydJTU1UJyt2BfkZlU8lIyztrWObcdyG56Zl6MElEpJua441a81YPpqoe+dcF
         VeYrdeBWfSN8Z4pdP8CNkrlhV1yljBv5PAroHsPPU6qbh1gkDKV/tUP3FSdX7ZmcvoMV
         X9lklzTIIukNYMca9Z0gtYVWNATXFnD3Pm+HZo0b/NshSPTlcfPc2bAaiXosozTB7Mey
         fBzMCxnJBTDPJ0/zVfg9U8UO2SOxTaHlLXlwL0ENdKY/+cG/0MiPgTjWftpxKz5iTFwl
         kxZw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXq5TDPh8ioJU6E6EeTBsPEOYd3MahlG7yvRFGSKCBDRwLhi1jG
	yYmps3UTNHYjPurDzwaD5XhPy2HqGeZom7oaMfF0XvQGeezMtyQiMxU3hxqD4JdCrYrv6jEvMJB
	VGLtYzQXtJz0ROhSItBZQsApKlwD2AId+/fL2tZO61BX6GEGSUX2XEfuBDNWkxbk=
X-Received: by 2002:a17:906:2101:: with SMTP id 1mr39356139ejt.182.1563527384816;
        Fri, 19 Jul 2019 02:09:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzz52fgDu5z6lxHjG/3nuiGLGtDKccZo/bAa/D7avU+fzC0qomWDTq6RfCEqiMCdY0HWann
X-Received: by 2002:a17:906:2101:: with SMTP id 1mr39356109ejt.182.1563527384147;
        Fri, 19 Jul 2019 02:09:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563527384; cv=none;
        d=google.com; s=arc-20160816;
        b=J2GIUvVqVBW0hONENvoFpmeP++/9OoOGIabVUn8UvrIhpOq7WPA030cx06d4Xgao9C
         6Ir2+Y7ZdMvHx7fPC4cLwpIpkUH+ArPNGmdm64kfSTydLjAF6aplvmP6/PE37RAHLmab
         P114hQsUbGdB/T7k4S/qdVwoOHWQ+IK/V/H+3QjdY3OoS2ZvoQBDOpQYrH/w3ZqzTvqf
         +cNrCGC+4elVwBpgF04/neKSpaeB58RuPIBqkdD1YAmdpkdanyJqKfY0MlFsyirdbZSg
         KUXvcr84Lx+O/zXsBhGo9PALAlsKdh168NNIWWetSdKk618bL1uyAmUTI3OplVKWcwy3
         ZuTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/cZLJMgOyXJoONutM7J3PQbctfT71JeLJvPhbAg7PME=;
        b=nJr6FzI4wwW7uyEVQmXO0Fo6aM6Cekg87OCNU/MBCasoE5WkoR4ddjUuf2DQQq/gD4
         L3kZH1rAFhElRnwIe+mANnRSSsCqelVb/sfp3onAoHLxiXrA3v16nbcCNcgvZ2OE/Zd2
         REaxkzgtfwiEYBmVRsqAruh8jc0DNiQU5QMwAbLxE4Ycc52R0y4SbWU3jKz8KedjosLS
         QXai/f00oscrR6vsVWi3LNp1GSDzZGEb3J9rj0gz8iiZJTMpMj6RvKXGu+kyPiDLSGDx
         D4pxUII8cB8yV8bo817AYxSVccvDbywQatpbxteLJgG/wRdZHC4oz8XunpvvET4Mi+lv
         BTyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k20si838822ejq.383.2019.07.19.02.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 02:09:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A89D6AF61;
	Fri, 19 Jul 2019 09:09:43 +0000 (UTC)
Date: Fri, 19 Jul 2019 11:09:42 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()
Message-ID: <20190719090942.GQ30461@dhcp22.suse.cz>
References: <20190718142239.7205-1-david@redhat.com>
 <20190719084239.GO30461@dhcp22.suse.cz>
 <4eefc51b-4cda-0ede-72d1-0f1c33d87ce8@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4eefc51b-4cda-0ede-72d1-0f1c33d87ce8@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 19-07-19 10:48:19, David Hildenbrand wrote:
> On 19.07.19 10:42, Michal Hocko wrote:
> > On Thu 18-07-19 16:22:39, David Hildenbrand wrote:
> >> We don't allow to offline memory block devices that belong to multiple
> >> numa nodes. Therefore, such devices can never get removed. It is
> >> sufficient to process a single node when removing the memory block.
> >>
> >> Remember for each memory block if it belongs to no, a single, or mixed
> >> nodes, so we can use that information to skip unregistering or print a
> >> warning (essentially a safety net to catch BUGs).
> > 
> > I do not really like NUMA_NO_NODE - 1 thing. This is yet another invalid
> > node that is magic. Why should we even care? In other words why is this
> > patch an improvement?
> 
> I mean we can of course go ahead and drop the "NUMA_NO_NODE - 1" thingy
> from the patch. A memory block with multiple nodes would (as of now)
> only indicate one of the nodes.

Yes and that seemed to work reasonably well so far. Sure there is a
potential confusion but platforms with interleaved nodes are rare enough
to somebody to even notice so far.

> Then there is simply no way to WARN_ON_ONCE() in case unexpected things
> would happen. (I mean it really shouldn't happen or we have a BUG
> somewhere else)

I do not really see much point to warn here. What can user potentially
do?

> Alternative: Add "bool mixed_nids;" to "struct memory block".

That would be certainly possible but do we actually care?
-- 
Michal Hocko
SUSE Labs

