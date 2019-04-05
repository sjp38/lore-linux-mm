Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6394BC10F00
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 10:30:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D03A20652
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 10:30:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D03A20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BC296B000C; Fri,  5 Apr 2019 06:30:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96AB86B000D; Fri,  5 Apr 2019 06:30:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 859646B000E; Fri,  5 Apr 2019 06:30:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 381526B000C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 06:30:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m32so3011142edd.9
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 03:30:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=d735EX/Mxcnh5Q/chLWM1Y+Ycd5hqPQADWgLn3zh720=;
        b=CD5ihOgG9jLgFCrKkyLgGx2ytuN15I/PT0LqtviaIr8mstqr/jaXORx9GagzJLNJA5
         FSMAOAze1+D5Q+B/O3oTQci3v7kfEh3vCRfBRIff2w8KzGX2rgcjyXOU1s/481dpy5aM
         yQxuEdQ421VEhWJTu3QFvPkjNAajFe8fsW36zmKJ25U5crNuiD6NIyCvHqFTS8akBJIX
         LUFa2CWFjhNVlsnH/ESpw+cobVfFiVKTEjXh4ZzR9bg1hq2h6/VAbKeG9ZkKrcfrjmJ9
         TFoxFp2GScWDnNUKCIUPAV6cYzNN9emopMcaUr/Y9mYdxJvXBca0L0f5Uwb8mEQyIkhe
         W4fw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXccnqOy7Ss85mDvmbndgPHGNAzFeFrpO657YMSEvZ7axHKpij3
	sPq8OGlxSbNPsV4XneM2E+Z9vaDfsg7c59e2hKHAhrVkeaxLoYyyIUCHxoQZNe5LQVpt+VoE+hm
	R2k5POxME0gJPqkXCzDJgqIfdw4M5ZXs/9WwNI0x4/XVu94bg1TsYAT+ig1GE5k0=
X-Received: by 2002:a17:906:b742:: with SMTP id fx2mr6856384ejb.6.1554460256749;
        Fri, 05 Apr 2019 03:30:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrMj4DfxW2qMlqgGea7hZhB4D3zeQgvRVJrQH99s1WX2/OtyeJl612cDLbNSelhhvm3DjE
X-Received: by 2002:a17:906:b742:: with SMTP id fx2mr6856342ejb.6.1554460255582;
        Fri, 05 Apr 2019 03:30:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554460255; cv=none;
        d=google.com; s=arc-20160816;
        b=JOi1IiCgcYq9gQyjfasBbRSI49hM7GMIhpD6Oc/yuFyxSNjnxh/Px9zK+p3VtqOcuL
         9UWBxI7s4oWysHoaSCcgmooGPtSl8bDiTlgAaHckoxsB68EwE0MvOC7i5goczq8atKRS
         TFfDRehFNl5GL50K22NZcYWLOv682TkFEl+kWw/SkpDhNACwXrXaSiaCyKGMh794q+3D
         rBHUOPWeD+3suQ8MQocD7pAVdhbvlMAEmC5ERiGZ3NrVy1cB+JX4sVJhA5aZqAuKn48e
         tmDVJ45zpNliJW6KomEsSUj3ijjTRSwKuo0jnjxmktfp1LQr46/7DsDkAo+s4mps1LAs
         eaLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=d735EX/Mxcnh5Q/chLWM1Y+Ycd5hqPQADWgLn3zh720=;
        b=DXET+SQEgiyNUQMlZfsWiDKord4cuYky1we85Djl7sK0GYGwjnCgDAbMzx79B7GjI+
         DQopA9HSs7G530dxNTnV0U/TGy1KJqfALy0n+k29jNLZ2HA1ZB/6S53efkxP1ZbU5hgD
         cTFcJLexndAIMK7Z91H/bYB08mGn6tr4Kg9qRwEE4Rv5rgxlLuhpg5Yz/BAI+WHfV5+l
         4KbAWtXOo3ovVUoqGLJNxFZpU+zOBPv2ugCMaj9IsZZxDXRynX+BC4Z+T2nwO2QZDTxL
         MFJQyaQCdlxGrx/y5nQlvM1ES/hZjUUHmZd56YZeY6fO8cLP+hAGlosmk/XHbuplyqdB
         zihg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si2982307edd.116.2019.04.05.03.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 03:30:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D67E3B07D;
	Fri,  5 Apr 2019 10:30:54 +0000 (UTC)
Date: Fri, 5 Apr 2019 12:30:53 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 2/2] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190405103053.GO12864@dhcp22.suse.cz>
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-3-osalvador@suse.de>
 <880c5d09-7d4e-2a97-e826-a8a6572216b2@redhat.com>
 <20190404180144.lgpf6qgnp67ib5s7@d104.suse.de>
 <5f735328-3451-ebd7-048e-e83e74e2c622@redhat.com>
 <20190405071418.GN12864@dhcp22.suse.cz>
 <a4230528-dc7e-e17c-c363-e3da7961dbf1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a4230528-dc7e-e17c-c363-e3da7961dbf1@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 05-04-19 10:05:09, David Hildenbrand wrote:
> On 05.04.19 09:14, Michal Hocko wrote:
> > On Thu 04-04-19 20:27:41, David Hildenbrand wrote:
> >> On 04.04.19 20:01, Oscar Salvador wrote:
> > [...]
> >>> But I am not really convinced by MHP_SYSTEM_RAM name, and I think we should stick
> >>> with MHP_MEMBLOCK_API because it represents __what__ is that flag about and its
> >>> function, e.g: create memory block devices.
> > 
> > Exactly
> 
> Fine with me for keeping what Oscar has.
> 
> > 
> >> This nicely aligns with the sub-section memory add support discussion.
> >>
> >> MHP_MEMBLOCK_API immediately implies that
> >>
> >> - memory is used as system ram. Memory can be onlined/offlined. Markers
> >>   at sections indicate if the section is online/offline.
> > 
> > No there is no implication like that. It means only that the onlined
> > memory has a sysfs interface. Nothing more, nothing less
> 
> As soon as there is a online/offline interface, you *can* (and user
> space usually *will*) online that memory. Onlining/offlining is only
> defined for memory to be added to the buddy - memory to be used as
> "system ram". Doing it for random device memory will not work / result
> in undefined behavior.

No, not really. We really do not care where the memory comes from. Is it
RAM, NVDIMM, $FOO_BAR_OF_A_FUTURE_BUZZ. We only do care that the memory
can be onlined - user triggered associated with a zone. The memory even
doesn't have to go to the page allocator.
-- 
Michal Hocko
SUSE Labs

