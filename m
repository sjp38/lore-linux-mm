Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9D60C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F31B20643
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:59:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F31B20643
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F44A6B0006; Mon,  1 Apr 2019 03:59:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A41A6B0008; Mon,  1 Apr 2019 03:59:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE1DB6B000A; Mon,  1 Apr 2019 03:59:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B43976B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 03:59:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n24so3942143edd.21
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 00:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Y1J3nScVANShhjH9R5Pt23WybOhWygR0kQ24cloIkQ0=;
        b=L5aYpXWMCy6ru4JpU9TQyG03EqCZKG5U2zpy2Lf+AvQ3OEfqUwT5KucyHS/2Rd/WZN
         BSu0LER6024r1iXgzHlfIJpqD8AgOFfNxHKjc8rVqBRWfggERv8Bg7NcEV++BD4Vq05c
         AUZHmF88tWD1BHjthn0Tppdh3sWntv0WH1SloIZGOobRpCuzbD4Y1PoW+5OXr82MPmS0
         0Ei2XJHDS0+BPoJpjT4YV2uXF/JqtnDgcRWCZRUOK9Bv5+fagLf895NwBrhxDAxUkp3e
         P3z6TH5FqCFkQVi4XwUHXou5EbPuR0hMyGzlv8IhiT39o+ne34U7NQ3RKU0JZWZH3Arh
         VDrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUxGKUmdWER79AREE/AU2aGE+NbWL9iZ5doilwdVcQ5qcjDrOMF
	hAz3qu4EACuxCqQqB1HUHDLKMQ1kVHSIG1ZcKNaemh9tLCYlEvm4xZQ0Mxxv07Zq3a07jEMr/t0
	kF5eSTZyguqO0XEtA/RIaxzUsorcuGcYtFTjzdxJl0kc8SjpDI89gKbbk5DCDMyUIxw==
X-Received: by 2002:a50:ac44:: with SMTP id w4mr41718973edc.241.1554105578207;
        Mon, 01 Apr 2019 00:59:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm9v5emo3Gg71MYLvo9sdH7j1jvDvje21uSgaUt0JyV/XDtD40W20cGyP66lprTkaEL/Q6
X-Received: by 2002:a50:ac44:: with SMTP id w4mr41718936edc.241.1554105577441;
        Mon, 01 Apr 2019 00:59:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554105577; cv=none;
        d=google.com; s=arc-20160816;
        b=XGIAxtrQDLMcVwjjR/mE/lHXv3/39TFO4D8JdvDBJ89A3C2hG3TFJcj6V3wj5KpkUc
         YYInU51vrianQ5E0Vtmm3THs7jwIz9IoYDqM4AadVp6gbzYRuk7TWZ5+O/p8IHrA99A5
         nJ89rJCxBKggY7MHA82Y9oDuKMOJeQK0ivz+ACQUYTcKdA9unWCC6I4NzvALCyVyWlHR
         HnTzF6AVfYvCqPYgAa+Ohb5DhiHAAW0mfuhI/huI4PQJLQ4e2+rBz1dV5BALHTAssHz5
         XkMSppPI6fvrpXvi/rF9vAbKuxORR0iBOiUc7dCTpRjFSfXs66xn1qw/fidgugvd6NsT
         Zckw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Y1J3nScVANShhjH9R5Pt23WybOhWygR0kQ24cloIkQ0=;
        b=P+WUG939ayN6AShos+fxiohj2pPoBwVDUYt+T00DPF94M0DI6FUsivlMLQF6kG2r6j
         zFgg/pfuB/o9kCGhrQ77uBKh7Z1SZ4LdqgtC89WK7nUN3+jveH6XfIg0sukgfUhZ1hD1
         x2WvUNIabC1czG/pFc6kn3uA2qykMUAFnBC3CdVXqaUKBDp/EPLdJ7EBHFpUoE+n30+V
         m8y6rFF/rst3JJ5ewF8KQ4EUgEsh+vfYEmgAPRIayognP2QwALYbkYyYMAbr+7uE4590
         H1Pg+R3neQsKb8KNpM8hpCZQ4WohVTjoI0nf8JN9OPtWm/Ng6Hs5SSjvYEd8RG9CzF9r
         PG8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id e3si3939491edd.165.2019.04.01.00.59.37
        for <linux-mm@kvack.org>;
        Mon, 01 Apr 2019 00:59:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id CF946479F; Mon,  1 Apr 2019 09:59:36 +0200 (CEST)
Date: Mon, 1 Apr 2019 09:59:36 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329134243.GA30026@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 02:42:43PM +0100, Michal Hocko wrote:
> Having a larger contiguous area is definitely nice to have but you also
> have to consider the other side of the thing. If we have a movable
> memblock with unmovable memory then we are breaking the movable
> property. So there should be some flexibility for caller to tell whether
> to allocate on per device or per memblock. Or we need something to move
> memmaps during the hotremove.

By movable memblock you mean a memblock whose pages can be migrated over when
this memblock is offlined, right?

-- 
Oscar Salvador
SUSE L3

