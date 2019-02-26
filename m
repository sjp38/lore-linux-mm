Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ADF1C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:19:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16458217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:19:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16458217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8C958E0003; Tue, 26 Feb 2019 10:18:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3C198E0001; Tue, 26 Feb 2019 10:18:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2CAD8E0003; Tue, 26 Feb 2019 10:18:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 609988E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:18:59 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i22so5587134eds.20
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:18:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E4MiummIsEE1YGegSpOnKlBAnyoDMiTgwf6og2xdTF8=;
        b=Zhv5UwqJEMy8qQ5kUVtqjfaLCqrzfgQkqwAsvoCJ82notW4qrHG9JaWAOhrpxbSKP9
         hdocOCY+/8mVrApHVydG7TuHgL2txFLnyblQmNDF3YWqUkUvxxfftkvtfYmi8lwP/wwv
         4Pvpf1JodWm+idV6LwyWfxGx+aAgQZCCqDqffns8KNPGz73F1iiV9X5QUFcskf/Fs8sM
         OjU0Wi1mo+Fvle61tMw0QBTB6yaf6EeBO3j+1W35qP8GBp15r3PCCwdwTd+htIBuEjZd
         hK5H/De+OcSY6ypx19O/+DFKor3dqSBcL3zOKIaZHUvb23V6/na9pj5WMAF04lEJwkXZ
         nGWg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYiiffCj+uNVzExAnC3PZJOZ+mD97ot59rypPZ45F9xzHzEfv5A
	kyv43cGkQ7M6O432OXakCYC1pKCRkcQaYifEbJ6wWMZwiNM78zy/pxEd5z002/hdmKuNmW3/y4G
	iNUkr/jJAXli6kX/3S8+Vd+6C1lhLnuGFte8+7xWgfMNZxtNPHVk8VHrZLqmbnfo=
X-Received: by 2002:a17:906:2a86:: with SMTP id l6mr16044901eje.186.1551194338935;
        Tue, 26 Feb 2019 07:18:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbZBkJtpdibvgApVjl975+7WE74pq45MQJUKwo7a3kmwkZwkGqcEpy8hlGbRq2CC4gy7xAs
X-Received: by 2002:a17:906:2a86:: with SMTP id l6mr16044857eje.186.1551194338102;
        Tue, 26 Feb 2019 07:18:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551194338; cv=none;
        d=google.com; s=arc-20160816;
        b=pIJkJrCYHZ7tMpDlWwcu7XaWKSpmgX0ybT/hJpdMBBk8+HmNWNWwqb1aqmtIrDzeyX
         3FF65xeD7Wq9p4TSfz6adlf4xG125vRTQMxreBPqHARNRoa3e3Z51iv1F+88E4FQGy/N
         NtJnUNfCNnyFR4anotNvnVzj/XbhBM2wsGlvEG9nqJwzbGRzTW3ZYg/UNSKyQ9AvkyBV
         Rv3qg/c0bXe9r3DOyckh7wJtQuTYeeFQyPpLqvXfzHhuT4iQ+SXMOV2Q7lBj9NoHox49
         q/74j/GwTOlD2RNgn6pZhCaSNuB1gEN267Pm6tvjw/5iOkJsRxZ3KpqGnNeB66yhh04f
         cOBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=E4MiummIsEE1YGegSpOnKlBAnyoDMiTgwf6og2xdTF8=;
        b=ifXmUzPsQftWl92v9NQ996WV9+e79jOSVzyGQ0Ps++WWA9HFrseZjv/xzyXEEDXha6
         Gk+q09F5abzOQEN9S7/nyXhZJkTN0ex1Gk3v+UQQx6REmBdDH2ySrJv4HSt9C/iHDENF
         8aCYigSd4ob+8NRSnp8+9ueFgYNSbwCg7C7l1YhzMV4EiVzw/2SzBkCZQs5F4B7f+XYd
         C03NEMPYK7SaAJJSuaodO6LD2b0mgBs9NDMCTb3RFRrD5i85L0sjPrEO88SAI+dQsONc
         cSCr2gq4/YrxhIbxsd58ek4emaEOV0aaDKlE6/HUCT5+AdrCXlxvzIUZ1Q/zL8Rgcj0X
         6O3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z40si1402805edz.338.2019.02.26.07.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 07:18:58 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 51C31AE83;
	Tue, 26 Feb 2019 15:18:57 +0000 (UTC)
Date: Tue, 26 Feb 2019 16:18:56 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	rafael@kernel.org, akpm@linux-foundation.org, osalvador@suse.de
Subject: Re: [PATCH v2] mm/memory-hotplug: Add sysfs hot-remove trigger
Message-ID: <20190226151856.GE10588@dhcp22.suse.cz>
References: <49ef5e6c12f5ede189419d4dcced5dc04957c34d.1549906631.git.robin.murphy@arm.com>
 <20190212083310.GM15609@dhcp22.suse.cz>
 <faca65d7-6d4b-7e4f-5b36-4fdf3710b0e3@arm.com>
 <20190212151146.GA15609@dhcp22.suse.cz>
 <1ea6a40d-be86-6ccc-c728-fa8effbd5a8e@redhat.com>
 <8793f49d-756f-960d-9b26-7eaedfccd90e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8793f49d-756f-960d-9b26-7eaedfccd90e@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 15:12:40, Robin Murphy wrote:
[...]
> The back of my mind is still ticking over trying to think up a really nice
> design for a self-contained debugfs or module-parameter interface completely
> independent of ARCH_MEMORY_PROBE - I'll probably keep using this hack
> locally to finish off the arm64 hot-remove stuff, but once that's done (or
> if inspiration strikes in the meantime) then I'll try to come back with a
> prototype of the developer interface that I'd find most useful.

Would it make more sense to add a module to the testing machinery?

-- 
Michal Hocko
SUSE Labs

