Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E74FCC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 08:14:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAC7520879
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 08:14:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAC7520879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FCB86B0007; Mon, 25 Mar 2019 04:14:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 382B86B0008; Mon, 25 Mar 2019 04:14:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24CBC6B000A; Mon, 25 Mar 2019 04:14:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFEAE6B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 04:14:50 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d2so1143139edo.23
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 01:14:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YBjwwHR3n2pbCyj5iBuBxdRnYsBIMonuA4XuqhvPW20=;
        b=Biul2LeAp/qaT5LG7ezPnl25I5+lrz1eaFK/DyBVltfBVVFnZb7JhGQ4PgxGNwAVz7
         0qrIz6uiw7tdHvYGUm2sdX23QkUEss3buD2JTDeQd9dPb72AMmerocRzNVtLMyhI3NyJ
         oIsMD4nNzCC1xbUF3L8VtvjhM5hijoI/CIFTX/ECsewaxyS4HQwKSB6DSrx23xJoksj4
         7CnAoVKoFAayW0QkUXj9JyqiaINVWeyLYfaPku6ea/OPWa4yW/aNJTLG2bSKOmhmj0Hq
         +ycAl3PESCdc4zJpZ/mu7QC5CQgnZm50QgTwtftBPPa8eaemolI1H6ND3Z2f+pxh+jg7
         X01w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAX5czpuT5GGiNYDRVPtdd1+R7GBjMG8JsEmf7yOzUPdZuY6iRjW
	WsCNsPS0m8WSjQVJ9Tid9Y1SvrA5kW74G+V5GcQcItDtfyRLVw/aO/CtcNHkhnh/bl/WB2l5ch7
	waJV1+Hg0XNPrFXDHlFRRnpigPPGy3Z5pZxkDBPrROQv0xC65ob+avIYMlGMQ3Qc=
X-Received: by 2002:a50:ca41:: with SMTP id e1mr15498346edi.73.1553501690434;
        Mon, 25 Mar 2019 01:14:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzx9HnC+eDiTMXj9oNYinuKTCrs57b6Y6BgA+/L4QzUO/Tp/1iarkh8h29dgjATRiaAAybl
X-Received: by 2002:a50:ca41:: with SMTP id e1mr15498304edi.73.1553501689670;
        Mon, 25 Mar 2019 01:14:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553501689; cv=none;
        d=google.com; s=arc-20160816;
        b=VtxsYhCudQh8ZNsE/eD6MgZweiHyKbmymflgqB3cAp0sPvN4jM97SeEONoZmqKlTpW
         aGFUxi8IhbT0RqezjsCrn6OyS0q5/PC3Xieuk7rqkuusdsZKW9O0GKiJlrUHMr9AiotK
         mOLaB9X9jtEAxa/4q1h9XGkhk7FeTPyCzMkTQFXGwB2uqNHjTf/cYr66cdtIy4Buftvt
         R19UlYyDFN4D5v9tXt7pAy8wxvqjz2jUqnFYcu0/bqq4GQdxOqwdWcJQEPdn080kWKxS
         YKzBZdAc637v9b/v0Jci5NzGYwWG+lAPzHXYZ+W42WKjRMaH7EWFC2c8cNl1GXeeV3eh
         +RMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YBjwwHR3n2pbCyj5iBuBxdRnYsBIMonuA4XuqhvPW20=;
        b=KFQSrXs/NsQVkjyMNioMJGraWat4ST21A5B5Nh2fFuWkXXPWrBncR7KHHNyYd6TSs1
         3pXydemS0LICLVG0bjCUTVLqdm69zYyIrjdrG4n6OR/Vk6agOeYJ+mIk7WaSdTnIJw8J
         /ZDLnErcOhn45u3Bt8JGvqDanEHKZmlJfdFfXT9yluR3KqootftSQHDChUEv+G5KDutH
         4m9zKDCTDOgtB6h9a7ebyo2RsKSXIUD2GlPK04MquzlZRznYi3+KuZffpkMP+IQAmRWg
         lu/pDY7etTnJuuMz10s1uWIYmgwfEWjAHJvQWp+Fjsp0Zpcr4LwUo1XAIaqaj56hLpBE
         Sk9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id f2si1983845edb.413.2019.03.25.01.14.49
        for <linux-mm@kvack.org>;
        Mon, 25 Mar 2019 01:14:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 0528446C8; Mon, 25 Mar 2019 09:14:48 +0100 (CET)
Date: Mon, 25 Mar 2019 09:14:48 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	akpm@linux-foundation.org, dan.j.williams@intel.com,
	pavel.tatashin@microsoft.com, jglisse@redhat.com,
	Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com,
	linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>
Subject: Re: [PATCH v2 4/5] mm, memory-hotplug: Rework
 unregister_mem_sect_under_nodes
Message-ID: <20190325081445.64qmxwzpuqafhfsd@d104.suse.de>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-5-osalvador@suse.de>
 <45d6b6ed-ae84-f2d5-0d57-dc2e28938ce0@arm.com>
 <20190325074027.vhybenecc6hk7kxs@d104.suse.de>
 <20190325080453.GB9924@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325080453.GB9924@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 09:04:53AM +0100, Michal Hocko wrote:
> No, unfortunately two nodes might share the same section indeed. Have a
> look at 4aa9fc2a435abe95a1e8d7f8c7b3d6356514b37a

Heh, I see, I guess one cannot assume anything when it comes to HW.
Well, at least we know that for real now.

I always thought that this was merely a kind of hardcoded assumption that we
just made in an attempt to avoid breaking things.

-- 
Oscar Salvador
SUSE L3

