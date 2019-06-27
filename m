Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65708C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:13:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23A672084B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:13:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23A672084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B42618E000B; Thu, 27 Jun 2019 09:13:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF3C08E0002; Thu, 27 Jun 2019 09:13:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BB7A8E000B; Thu, 27 Jun 2019 09:13:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6178A8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:13:39 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b195so1143130pfb.3
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:13:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=7JGQHgxBXAYkEpi2uHdRRYGF7LLTgCJ1fUThGvY0lzo=;
        b=uNeo5456CU2US901WJE7z/UzursDPK32IC6eENMqslmA+HfAXKX2dSrgQuzhZRiSTC
         RWjk1KMIJeXKXbxMsNMYbVcwvNf3gka+o9KmQqxIkLZ5EguQIdlRlvRQcsvqgy9ZUqxy
         2mJWNI0rHhXMfJMsgSWf7dWAc+zHQWfhBhNrslhR552wlfHk4vmqVJsvJixeFEEZQpYt
         mfCBbsbaBy2zTJU896MIHzI/uEEBIJ7Kr9L2xV0cZrGVn0NmqIJxPTbQK83GoL+grdS4
         b4JwZz9eRNM+w2lKy6c+fnLsDCOnTxVAQyOpV/OQ4/DsKYpQ0uuEt281peAvKzvi616S
         tv4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV+1BscHjNEc3gTl8T2f0I5HSNZ9f4Vhhr2gTWPjf6HM914TXFr
	7qTdlS5ZVbTrIgx9C7oPEt36Gk/b7YSwhOD+FMXCwrbE+v1ort5yUfXRSRktPCFwUCl5pk2p+So
	RZ4qkONB3oIyz0d8BUGyctcAG26/88VIyctfQg05wJF2eIZjOrmj00ahEplkOueyVCw==
X-Received: by 2002:a63:6b0a:: with SMTP id g10mr3680663pgc.295.1561641218854;
        Thu, 27 Jun 2019 06:13:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRSlxGPGAIcMvc34ktCvFc6IHgqRtRS2srvnkVnlJgDn/urJCkeuJyAH14hBQ93WdsOU2Q
X-Received: by 2002:a63:6b0a:: with SMTP id g10mr3680600pgc.295.1561641218039;
        Thu, 27 Jun 2019 06:13:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561641218; cv=none;
        d=google.com; s=arc-20160816;
        b=hgLOqdygavhOVCtJoRMC03cdRbo+fffHp0aaMX91j7gU2T5n+GqfEJngeNdjS7N/4h
         zwxFlew5CCui4rPAyfxY1d2HNHcXNd8H/do5HqneHEl+mb1PS3Vg66dASwsZHrqQKv6O
         hxq3HoRJuD1byIXHtphi2aYc7Fo6svk8ZmUyY1OuQZ+LXsLBcvq2sjsds6ATqhR3MMT7
         qgg7Co28fSoRXGNUT5+EPHiAJ8/uERAjoTe86KgtYz7Jc+Drfw8qxdDJdo9hDf+GU84P
         E3tuvOcM4sChy/taD+OYH8gPAl2lJTQsI/DsMJngEQvX1NpWuG/ADzQyB+aJg10NyQrD
         y57Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=7JGQHgxBXAYkEpi2uHdRRYGF7LLTgCJ1fUThGvY0lzo=;
        b=LnYtF5aTg8fJ6M2jawXZLI4oSbRJOPHDZ3lwNXZgHXfrIzGYlubehauBLtjrAn4xu4
         ltGYV+lnJC4IqRcNyMQ1wzFIBFd5CZ1DbJE4OU64H1JTtI3YiMIQaqkNY4f4KDJBLbZo
         KasNCd8xWoXq4imtqEAHKmF7PVri1SLsYDt5T9ycldRby57peDKbLZMdRhQmPpI3EzPG
         fQz/QBjWKkXCvqAxXUDlO4h0tJQcWtwib1ygMsKs4IFvLVkHJh3PlIwU0pGX+5oRSJUw
         opVfralkoLrJ7uXIG8/8oSwbqptRllMA+5zuYMGHk2WhUG5Xr4mZJ6GCdHsuAd+4rq5p
         rcpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id d132si2675129pfd.102.2019.06.27.06.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 06:13:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Jun 2019 06:13:37 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,423,1557212400"; 
   d="scan'208";a="170416999"
Received: from jrschiff-mobl.amr.corp.intel.com (HELO [10.251.13.147]) ([10.251.13.147])
  by FMSMGA003.fm.intel.com with ESMTP; 27 Jun 2019 06:13:36 -0700
Subject: Re: [PATCH v3 1/5] mm: introduce MADV_COLD
To: Minchan Kim <minchan@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>,
 Joel Fernandes <joel@joelfernandes.org>,
 Suren Baghdasaryan <surenb@google.com>, Daniel Colascione
 <dancol@google.com>, Shakeel Butt <shakeelb@google.com>,
 Sonny Rao <sonnyrao@google.com>, oleksandr@redhat.com, hdanton@sina.com,
 lizeb@google.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-2-minchan@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
Date: Thu, 27 Jun 2019 06:13:36 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190627115405.255259-2-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/27/19 4:54 AM, Minchan Kim wrote:
> This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> MADV_COLD can be used by a process to mark a memory range as not expected
> to be used in the near future. The hint can help kernel in deciding which
> pages to evict early during memory pressure.
> 
> It works for every LRU pages like MADV_[DONTNEED|FREE]. IOW, It moves
> 
> 	active file page -> inactive file LRU
> 	active anon page -> inacdtive anon LRU

Is the LRU behavior part of the interface or the implementation?

I ask because we've got something in between tossing something down the
LRU and swapping it: page migration.  Specifically, on a system with
slower memory media (like persistent memory) we just migrate a page
instead of discarding it at reclaim:

> https://lore.kernel.org/linux-mm/20190321200157.29678-4-keith.busch@intel.com/

So let's say I have a page I want to evict from DRAM to the next slower
tier of memory.  Do I use MADV_COLD or MADV_PAGEOUT?  If the LRU
behavior is part of the interface itself, then MADV_COLD doesn't work.

Do you think we'll need a third MADV_ flag for our automatic migration
behavior?  MADV_REALLYCOLD?  MADV_MIGRATEOUT?

