Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15BEBC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:54:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D27B22083D
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:54:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D27B22083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62B6E6B0008; Thu, 18 Apr 2019 09:54:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DB7C6B000C; Thu, 18 Apr 2019 09:54:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CBAD6B000D; Thu, 18 Apr 2019 09:54:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE4E16B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:54:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y7so1288105eds.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:54:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AJ7bby9VAajq7vqzR0Jw1b4xJOwIPaTVWeDX6FwqVCM=;
        b=IoToZNgAN81uS/b3vhuJmMT1MRCPh9ywo06BShQcI8X3oHmwVqYJB8WLGpgxxJZv5u
         TS9cXnMh6O9kvfZ5sPrqd1XfXRZv604ja6wLF4SQB9zQJzRokBzpWSb12nwaDNkfm/Vy
         P0ZMKNi7RMxYBoj8gNPgdYuVY3/5L6rPQ84MK0Vt3YISjO4zW/KelEtVg7CaRotxuRi4
         znwsjTaj2s2sg/rZybw3lewbuUl2wACcP7cBomafvrImQnwieZqYsBGtJHmGvobTzlEb
         DvwBKFiGstunG/OzC22Fo99goO4C7/kokpIDyeSJxW6Ob46mplo0Kjgk/WXS/Rcqifxs
         PWYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVyRJTcW3Oe/mhUg02NU3fo0qrMXKnHySF9fvAuJNk71BsOZbgD
	62UzvsSnpA5ElDr/Xy9Sz73tQQgVAw4WtS4D6OuScpBPduNhXwjrfVNGGKCB1pOl0QkE62GE70W
	/kRBoXePc5S+8/8rXqaItOQpaa/0kcLdRU0yo4kvkcfaS+zMa1kur2Dt7npB3HX6/FQ==
X-Received: by 2002:a17:906:69d3:: with SMTP id g19mr30232903ejs.212.1555595695440;
        Thu, 18 Apr 2019 06:54:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPSDk7Futtmn6zE/DpWoif4HYeC7SODkdX2mC5RsRaznCe5+CzKY4buKFQpZnj3zZA6U34
X-Received: by 2002:a17:906:69d3:: with SMTP id g19mr30232860ejs.212.1555595694432;
        Thu, 18 Apr 2019 06:54:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555595694; cv=none;
        d=google.com; s=arc-20160816;
        b=KCdQW+QGbYyN9RNE1CY2hi4ebtGTbO619/ijR4uPoSGS3s9uDW6O/VkK+iUCSn90s8
         stEKxMem21jdlGlNLO+JicdzN7cRl9FrpgXgMvw6is24sKYtic18zkEkQNGcp+pmMPsP
         yanGjdlpXyDGteH9exlrL1PXS9RnS5lO5heXI+WfZbmQm6CIx1wQ3FVIXx6UHdeSznt+
         b0mee9Z/c5baA7Xq1yRrri0sduR+HDtyzuyaNn8ixHBkXmlWvikmwgV2N01MPQfNiARS
         y4lW/RYOed12boP7WnpHiaQ4vEtdRSw8nHEjvgf3ZlrkUu5k8hx02iuoj6gnvFWkrjMp
         8ZrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AJ7bby9VAajq7vqzR0Jw1b4xJOwIPaTVWeDX6FwqVCM=;
        b=M6j7sQD7P7HVc6N6WOIW3vHElHFsC5FSj6xmYc8FxWuzrgtdeaArMQoVMSsALeT5mj
         C4F3hrks+sRIbzE05ADUlZn3Sad/WGF5Hhs3o3/ePjRIXMvE5YosEh/lylbGsLs/9cLN
         DLlZJge4QK+DMGjvx35lntveaYMWs0Rg0FtlrpBoZuNV7jgDdhJ5V9i/yLEjN2MIT+hw
         Dbrdtq/Qcp/BEPch5p2W9qqL9l4ztN8mOBJo3MCP1+L7rqqgk07N6Ph2+JG5NIY8UgzI
         skw2W0jkUVvuvsBKRGJJF3Yni2P0VHoRYLb5S35eSLjas3VxIvwMcruZ2FKiqk80Uk7x
         yHIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp21.blacknight.com (outbound-smtp21.blacknight.com. [81.17.249.41])
        by mx.google.com with ESMTPS id x2si949213eda.390.2019.04.18.06.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:54:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) client-ip=81.17.249.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp21.blacknight.com (Postfix) with ESMTPS id 09B26B89A8
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:54:53 +0100 (IST)
Received: (qmail 5440 invoked from network); 18 Apr 2019 13:54:53 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 18 Apr 2019 13:54:53 -0000
Date: Thu, 18 Apr 2019 14:54:52 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Li Wang <liwang@redhat.com>, Minchan Kim <minchan@kernel.org>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: v5.1-rc5 s390x WARNING
Message-ID: <20190418135452.GF18914@techsingularity.net>
References: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
 <73fbe83d-97d8-c05f-38fa-5e1a0eec3c10@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <73fbe83d-97d8-c05f-38fa-5e1a0eec3c10@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 10:54:38AM +0200, Vlastimil Babka wrote:
> On 4/17/19 10:35 AM, Li Wang wrote:
> > Hi there,
> > 
> > I catched this warning on v5.1-rc5(s390x). It was trggiered in fork & malloc & memset stress test, but the reproduced rate is very low. I'm working on find a stable reproducer for it. 
> > 
> > Anyone can have a look first?
> > 
> > [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190
> 
> This means compaction was either skipped or deferred, yet it captured a
> page. We have some registers with value 1 and 2, which is
> COMPACT_SKIPPED and COMPACT_DEFERRED, so it could be one of those.
> Probably COMPACT_SKIPPED. I think a race is possible:
> 
> - compact_zone_order() sets up current->capture_control
> - compact_zone() calls compaction_suitable() which returns
> COMPACT_SKIPPED, so it also returns
> - interrupt comes and its processing happens to free a page that forms
> high-order page, since 'current' isn't changed during interrupt (IIRC?)
> the capture_control is still active and the page is captured
> - compact_zone_order() does *capture = capc.page
> 
> What do you think, Mel, does it look plausible?

It's plausible, just extremely unlikely. I think the most likely result
was that a page filled the per-cpu lists and a bunch of pages got freed
in a batch from interrupt context.

> Not sure whether we want
> to try avoiding this scenario, or just remove the warning and be
> grateful for the successful capture :)
> 

Avoiding the scenario is pointless because it's not wrong. The check was
initially meant to catch serious programming errors such as using a
stale page pointer so I think the right patch is below. Li Wang, how
reproducible is this and would you be willing to test it?

---8<---
mm, page_alloc: Always use a captured page regardless of compaction result

During the development of commit 5e1f0f098b46 ("mm, compaction: capture
a page under direct compaction"), a paranoid check was added to ensure
that if a captured page was available after compaction that it was
consistent with the final state of compaction. The intent was to catch
serious programming bugs such as using a stale page pointer and causing
corruption problems.

However, it is possible to get a captured page even if compaction was
unsuccessful if an interrupt triggered and happened to free pages in
interrupt context that got merged into a suitable high-order page. It's
highly unlikely but Li Wang did report the following warning on s390

[ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190
[ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver
 nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_s390
 des_generic sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs
 libcrc32c dasd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm
 ccwgroup fsm dm_mirror dm_region_hash dm_log dm_mod
[ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted 5.1.0-rc 5 #1

This patch simply removes the check entirely instead of trying to be
clever about pages freed from interrupt context. If a serious programming
error was introduced, it is highly likely to be caught by prep_new_page()
instead.

Fixes: 5e1f0f098b46 ("mm, compaction: capture a page under direct compaction")
Reported-by: Li Wang <liwang@redhat.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..cfaba3889fa2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3773,11 +3773,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	memalloc_noreclaim_restore(noreclaim_flag);
 	psi_memstall_leave(&pflags);
 
-	if (*compact_result <= COMPACT_INACTIVE) {
-		WARN_ON_ONCE(page);
-		return NULL;
-	}
-
 	/*
 	 * At least in one zone compaction wasn't deferred or skipped, so let's
 	 * count a compaction stall

