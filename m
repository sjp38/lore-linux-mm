Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92048C742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 18:07:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5545820863
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 18:07:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="tF3TLrAg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5545820863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E82618E00F2; Thu, 11 Jul 2019 14:07:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E33F48E00DB; Thu, 11 Jul 2019 14:07:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFACD8E00F2; Thu, 11 Jul 2019 14:07:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99D878E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 14:07:32 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n9so666015pgq.4
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:07:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HFqqVAf53kQZdQpKzWHw6YV0GKjGRqkuwN0W084Idiw=;
        b=nV8u7ndLo3aKa23axmsqsL0oMQwQCjg09in31z/b2Sv7DBCA4iexIomDa8XQW7sy5q
         RqaveDDYfoVRMB0BcEZ4DNxIK/3I4nhDS5bk0LI7/GhVn/msufa3fr0wxpG9xecF1urH
         1MvQu6iLcQ2mUG1Tbjk2CWNBxXLUwWDoQ3aC0P8azRcyJe3nV37A5cchb8STycuUWXsu
         AlVAgda3mFcyRCZ3IAm8RK6uG0TQpOOkDcJnLSAGuai3c1hIT6ai8EvSwXMLfN1QTlVZ
         HejslUQvRuwLSBSttRm21jQ+1+qjByZFoCBGQxign6oV+qYotq0LOv5aYgYFEUfe/fFj
         +Fnw==
X-Gm-Message-State: APjAAAUx5XxAC0GkixGk70pfjU9FSuDMbmUYHk5/yIQbFSO+bsJ61xAu
	MTd2nP+D9oS0kGJu1gks3Cs/XsC+2Cwqecsw/7OHyXe1F3v1EW8hoBM76Z5NlZmENp/5XcKu1VK
	VPbV01hcq6ANJhOMxoN0Kh3rFU4vozwzDPJU/bXWn1jiXe7hX8ewkuszaJmQWqG2quw==
X-Received: by 2002:a63:89c7:: with SMTP id v190mr5562038pgd.299.1562868452140;
        Thu, 11 Jul 2019 11:07:32 -0700 (PDT)
X-Received: by 2002:a63:89c7:: with SMTP id v190mr5561971pgd.299.1562868451300;
        Thu, 11 Jul 2019 11:07:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562868451; cv=none;
        d=google.com; s=arc-20160816;
        b=wKYOHTvVm5jU74Jhw7W5SG8V3D9fCPeSk+GRtYBmHrypw1ElcWcf4ZdKTu+v83+JMQ
         LFJl/+u6OryjVOT9pRyEd+Y+GuckcE0ByBwLkX1xr0dlhxyg+gznC1ve0g4XjXGnrnI4
         +PLuPTLdP5O/ilqgNXVY4Xq5qdsZQ33pzRd0Vzn21d0oG5BEqw0waCBu5P28GIOe8M5m
         qO8cpvFvjfW4EuXom9cc/s7XLgCWbXGN900sQmga8gNdqAe7X1L+XEGvx7ICfoEPHgnW
         U9uty8GBiftV75NQXFyNSpvL9L+nwScgXcvJD5REHGBqiRz6AyNFzX4jk0K2jrVYBZb8
         xcbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HFqqVAf53kQZdQpKzWHw6YV0GKjGRqkuwN0W084Idiw=;
        b=km1XhW2Y1PX1xVjFgc5naxsJAqwWVrsBhrZ5Xa2Pj+xBhqel1un4yEzNe2pxVbh38/
         F+AjLBO5LMoaARWuBZKMhyOiJnr7LAkCsS3qDSzeKHf+J3WOAzCFqYl38ia6eYsDjktQ
         P445Y288Yp1tyXWrJyAQhilLFCdzFVbPCuOSaVZ1cGUVTBULeCKPlVfP/45DDVyA1js7
         aagCr2pm0rXJ454d9lpo7exYPS0sY/2mnergGpRX6eml/Xe0/yNsiZY/EuMIetY7CKAd
         rh/LgUWKFdPOMXw2PbJDDXas6QWVshDGAgiBZBA5BiR04ApZnCj07ZAbCsVPJRlpTFDV
         n9dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=tF3TLrAg;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor7794034pln.13.2019.07.11.11.07.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 11:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=tF3TLrAg;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HFqqVAf53kQZdQpKzWHw6YV0GKjGRqkuwN0W084Idiw=;
        b=tF3TLrAgMwyyskndvYBbdeyeiTdA3ax3J7vfMGNXEegyPwcKqVxi0vW4QF8Sbo9L5W
         6OJUTIJAIWTZ6kDHn9Rv2qLS2xtqXEkdbqacOfgHYFg6HZzoRJ/Ai5gJZYJ5hAWMIZ1i
         UykxeqaETOYUXDlhn2iVJspR45SoeMH5gfP7RQBZC0w1ekRo0mYMhWilnnztwDL99w0v
         2SQcmkV3JGGe7XtnqSV6bNjtH65hfzDSJfN5lILS8DFbRrsh5tasseTAZgiZmLzPNgyg
         lZOSsTWjhmHGGU223CWsarbZthwmuT7ikTEsPom1WpjgEWZqxirlJhjcCi7DUoxUnQv9
         XTzw==
X-Google-Smtp-Source: APXvYqzMAQG40OUqLYdym3Kco+SvImeO5ZcrWpZB4aqsTh7miN748rzlQ4W0jLflNC0KF2SfAxfUFg==
X-Received: by 2002:a17:902:145:: with SMTP id 63mr6305306plb.55.1562868450408;
        Thu, 11 Jul 2019 11:07:30 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5385])
        by smtp.gmail.com with ESMTPSA id w2sm2686882pgc.32.2019.07.11.11.07.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 11:07:29 -0700 (PDT)
Date: Thu, 11 Jul 2019 14:07:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 3/4] mm: account nr_isolated_xxx in
 [isolate|putback]_lru_page
Message-ID: <20190711180727.GC20341@cmpxchg.org>
References: <20190711012528.176050-1-minchan@kernel.org>
 <20190711012528.176050-4-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190711012528.176050-4-minchan@kernel.org>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 10:25:27AM +0900, Minchan Kim wrote:
> The isolate counting is pecpu counter so it would be not huge gain
> to work them by batch. Rather than complicating to make them batch,
> let's make it more stright-foward via adding the counting logic
> into [isolate|putback]_lru_page API.
> 
> * v1
>  * fix accounting bug - Hillf
> 
> Link: http://lkml.kernel.org/r/20190531165927.GA20067@cmpxchg.org
> Acked-by: Michal Hocko <mhocko@suse.com>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

This is tricky to review, but fwiw it looks correct to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

