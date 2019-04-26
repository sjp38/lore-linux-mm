Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C0EEC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:20:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF89B2089E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:20:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF89B2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E6716B0005; Fri, 26 Apr 2019 01:20:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 496BA6B0006; Fri, 26 Apr 2019 01:20:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35F946B000D; Fri, 26 Apr 2019 01:20:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 007C76B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:20:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r8so890721edd.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:20:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=++qLLXfiTTHSMy274h/6F4O+DzwCmbRzJ5tSU/KVi8E=;
        b=FcauTQEP1XNX3YSFrubEU71d3WH/GmuiGVg207rhVVsVT4yk2rjUT+GeKIFUWjWxcK
         wvHLvhVzYAYinj2usUE9XBKwtyJDfvXnDpUhphpm5uZ4hkQOezUVttYQxrIgx9UuS596
         6lxABZGXLgzl2xzRFSsbRJTxV5y2rzYjsdNbB7voASL6FOKNl6IKfTx31qGwA8JZ3EQZ
         AxzqyQJS5TGlPHoMItxPzsdCU68PsZYbuypMdXRq7bFt8WNsQkCcLp5A02jCETTflnOF
         UcFOW+S9WUwH1qQ6SyoAZP/RQM0FI7q6o0JZF2T/VyKwh3gMEb5ON+0Ww7Hd46U4We61
         Y4jg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW9NRXc8OwvMpELvdRCRjSNZI+oJtcFSuMxeBAiHI8TMSac5aIM
	TusMwBW18mHCG262ALtKUDvGyIv+20RJeyfUleEiTxZWFWwI5egwYvwHvSjSXk6Y+8V+X9otnsG
	pRskVpw0VaDwd8dHG4ahRQZLuyBsxE/En5PIZrwKtFz2v26VlUlI67YXlaDNV2LY=
X-Received: by 2002:a17:906:1910:: with SMTP id a16mr6951063eje.132.1556256016444;
        Thu, 25 Apr 2019 22:20:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBXbQ3B6NgNnVAJdiy6NSRVZ9XnBCyQcy3EznsLnCpjGOYRlAbGMrtU7P7Kv3g40tcws5l
X-Received: by 2002:a17:906:1910:: with SMTP id a16mr6951033eje.132.1556256015531;
        Thu, 25 Apr 2019 22:20:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556256015; cv=none;
        d=google.com; s=arc-20160816;
        b=D96ms9+UroU8NQt3l+Z3pwbA3hEfkUdZ/Bj/ciqzkIXZViV4PBFHPfsacoL9B5c2VB
         7rTbG84WqQxB3tDXDToP+1O8LyrMJfuHDb7pxBdRU63Ffzr/D4FP3lHp13SdcQIN0Sb0
         8Y/QarE6bw7CbRUVXuUWUOWoSV6QrWNnFsmhcLI4HXNjb0gUFz71jUrFQ4oplDeFkK4D
         lX+fM8ok6//YpfGyiIUhrZAuU/6gN5VuQqaVyL4iy6as+pM4AQJR2hIo3lXLNcZKI34J
         N+MYpxFKNnCk8HlMnJcO8csofO8LVlO17sB1aBMOta9w+YsIvnRZ3key7P2Trw2SbaJo
         gupw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=++qLLXfiTTHSMy274h/6F4O+DzwCmbRzJ5tSU/KVi8E=;
        b=lQ3oZ5KEEutXvxmrDuOek7JC/m9lplevbpq3RR9XaENs/+QV4ZGMxxEDoGcYEfjMRG
         SBuKWWMgFTaIy83HXGs7c67yV0o8Oc/m9MYi5V8vgEvd9HtRMoQ+QswdTgP01wXNtqXK
         L1AuKHE4tMf84NWJbed3Vzb/jayQ0DsuBDmB/gdAy77kyUfx5eiiJC+o3WRk2SPBYY00
         UFPAl6QncASUqRjfj6eiGGRDiyXNBLF/kwYSPjeY65eGBYF4lzLwqN63GFdeuLFhBebQ
         WKxsb7RmXsJN9rDV5KXrZ8MHaS1C0hpwyJRnqWB+lJ2gBcG0fp6W3Ntv60pIQsIbzM9+
         sy2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l26si337945edc.170.2019.04.25.22.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 22:20:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A8130AD2B;
	Fri, 26 Apr 2019 05:20:14 +0000 (UTC)
Date: Fri, 26 Apr 2019 07:20:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Jens Axboe <axboe@kernel.dk>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Lightning round?
Message-ID: <20190426052013.GA12337@dhcp22.suse.cz>
References: <20190425200012.GA6391@redhat.com>
 <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
 <20190425211906.GH4739@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425211906.GH4739@mit.edu>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 17:19:06, Theodore Ts'o wrote:
> On Thu, Apr 25, 2019 at 02:03:34PM -0600, Jens Axboe wrote:
> > 
> > which also includes a link to the schedule. Here it is:
> > 
> > https://docs.google.com/spreadsheets/d/1Z1pDL-XeUT1ZwMWrBL8T8q3vtSqZpLPgF3Bzu_jejfk
> 
> It looks like there are still quite a few open slots on Thursday?

Please note that the agenda is still not finalized. I do not know about
other tracks but MM is not complete.

> Could we perhaps schedule a session for lightning talks?

I am pretty sure there will be some room for that as well.
-- 
Michal Hocko
SUSE Labs

