Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F79DC31E44
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 02:52:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27589206BA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 02:52:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="fw4Q74Ba"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27589206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6CC56B0005; Tue, 11 Jun 2019 22:52:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1E086B0008; Tue, 11 Jun 2019 22:52:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0C316B000E; Tue, 11 Jun 2019 22:52:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 671E06B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 22:52:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r21so13956186edp.11
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:52:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lTSsRBqCkV01tyi99VGZwhMHPEHI5mgEc1RD90UNjyg=;
        b=TfNdrF8A+sh0yvs90j0e9pnBOUZ/kgTWWSTXacNS5d6zVMzXHDyIfJIMNm599Mil+1
         4h7Q+3luVABHUz6JocGNHJREXVmtDqFsZe6t5F/3UwdcgIeTgDT/k8ZpQrKB4SiMV8fz
         PZudw/iYOwhaeCfPaNsI/rWZrVYyp8jaxzeQRhlzwg4BPJIPQTfN9JgUAajg1Cbyn/L3
         hntghCA9lLu1mozfdP7YiBCR0i0Ty0zwbJEPS0l+MzL7g91TpwlG8BpQOoa7cr+//G3u
         5QoWgP7KpQ14kys9fPdOtcF2rtBMJF6S7hwiJrWnX57Db6roHqQAsWFOlupcSVr6jV5I
         g8UQ==
X-Gm-Message-State: APjAAAUtCMxXWPR7j/Fao54TTTPwWFOpXS14TS9ikx43UDpFODtXVDvU
	/GXOk30gYlqED20lgOOPEoCHqOh5kZRV4Gst/pZHqYnsNg/yK8YfpJ+zUIZoSGHW2Rj6FOcK3+j
	XakAYDlfIsAcp72GL57+f5wwP7vwxdLlKmTN19o3PK2AvjfTpwyo8LNJsGR+iVE4lfw==
X-Received: by 2002:a50:fa83:: with SMTP id w3mr6973419edr.47.1560307978001;
        Tue, 11 Jun 2019 19:52:58 -0700 (PDT)
X-Received: by 2002:a50:fa83:: with SMTP id w3mr6973385edr.47.1560307977401;
        Tue, 11 Jun 2019 19:52:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560307977; cv=none;
        d=google.com; s=arc-20160816;
        b=Nom6WB9G2Qv+DpltbEazso7OZac9Vxb1abDeWoixivCoHqy+yLV2GXoWu6yF4l9scL
         42Bf9JEdFUFK+k/D4OooeEPauTMOgaBlIM+32u6LtH8L7YIPfSvAUtE2qeEAIvUtY+pQ
         fe8c35efiVMs6gmKqcjODlkbh96tGt76BvF/OFxNYh3GZWUxalwvHOjtfFHza2AeJ49v
         5ZwCgIJLXy14yiqcegN8WhfidatA1Uj5ogUfEzM9tjRr8HZCGxYoZ1i/wg5XoOP1arLG
         OcL1dXb0pxL2SLUsqsQhG0ikrARgmn7ml/oCUNu+0mdtNOut3mqEoxuqq01+DjJLtCIO
         JOSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lTSsRBqCkV01tyi99VGZwhMHPEHI5mgEc1RD90UNjyg=;
        b=gKiVsFBwrhXc9D+7mGgbUjBm54gYBxQ7cs+y8uh8Bq9g4imzcwk3ROfcVSIJQWvr26
         Zm25NOrgFiD+XYNJdtqAJG+9o7b+EWAidaR/o2rNJfGIoH3cDRS4wMzEHrJaIljTCSZX
         u5y/ERmg9SyGpbRnCrk+4YcW0j7P1i5yAV+oqEP7/Ulx9/Wr/7R/XUbUmElAKsVbSIdc
         WamxKVOHpN0EDRCxdxaCDzpkIjZ78BIxBA7SO1IIt3urK4Okj3rEKk9rchvjZO/Avd5P
         /BGJ0XxtlZgN5PCqD4Ueo4cbMe7BE6ZzPtG4x62gPY+dYcMeBgpnj4CY8U0UnjUpjsD9
         HayA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=fw4Q74Ba;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1sor2989065ejs.27.2019.06.11.19.52.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 19:52:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=fw4Q74Ba;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lTSsRBqCkV01tyi99VGZwhMHPEHI5mgEc1RD90UNjyg=;
        b=fw4Q74Ba1btatZL0a2YpiRpBrSxcKAXumIpAR0gE8oNWSDYZ83TELkQamlGVpC9PcO
         0HqHzzhxCVU6HkPE38P/AWAFRnYuv0FdhzPRumcorq5U4AwW71pM9i6oa3y4Dhh+LajO
         VrBmdg8q3xP860V1auFmiSrwn/ulafeuZba2kalmeIx3OCqwea3dNN5kAhNRVyRasRqU
         pm8eLz+8IBRUI5NQWvEsObpHzJ2ITP39NptQiwOUuybbiJieu9qVCkDW3QFRUiuXc6lT
         tU7wLG2yIFK3Jw/Y+5zeaasWKVasi6tO2VImYEOeSBh0oakk8FTZva4XQZ16RtNJUJGJ
         2fsA==
X-Google-Smtp-Source: APXvYqwhPUYZ7NcTbUtoLkSK379H17VO3ocGiSwvUcxrlIx/jQ0N2GugFDy7c6sGViaRmAcsB8xXKg==
X-Received: by 2002:a17:906:300b:: with SMTP id 11mr48124392ejz.291.1560307977066;
        Tue, 11 Jun 2019 19:52:57 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id z22sm604246edz.6.2019.06.11.19.52.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 19:52:56 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 146C9102306; Wed, 12 Jun 2019 05:52:57 +0300 (+03)
Date: Wed, 12 Jun 2019 05:52:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com,
	shakeelb@google.com, rientjes@google.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/4] mm: shrinker: make shrinker not depend on memcg kmem
Message-ID: <20190612025257.7fv55qmx6p45hz7o@box>
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-5-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559887659-23121-5-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 02:07:39PM +0800, Yang Shi wrote:
> Currently shrinker is just allocated and can work when memcg kmem is
> enabled.  But, THP deferred split shrinker is not slab shrinker, it
> doesn't make too much sense to have such shrinker depend on memcg kmem.
> It should be able to reclaim THP even though memcg kmem is disabled.
> 
> Introduce a new shrinker flag, SHRINKER_NONSLAB, for non-slab shrinker,
> i.e. THP deferred split shrinker.  When memcg kmem is disabled, just
> such shrinkers can be called in shrinking memcg slab.

Looks like it breaks bisectability. It has to be done before makeing
shrinker memcg-aware, hasn't it?

-- 
 Kirill A. Shutemov

