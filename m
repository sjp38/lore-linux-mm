Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24660C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 12:52:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7E7D2089E
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 12:52:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7E7D2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 284946B0003; Thu,  2 May 2019 08:52:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 235CA6B0006; Thu,  2 May 2019 08:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 123656B0007; Thu,  2 May 2019 08:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD4336B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 08:52:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g36so1009469edg.8
        for <linux-mm@kvack.org>; Thu, 02 May 2019 05:52:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IUBMaIemPZgl+D4zOsC4haMjnlTeGL60MvB6fSw68e4=;
        b=AqMb0DFw6GjOO0UtkeFzigBylvcHI7t9JW61auGfUOAZrybHM1QyxlEEAu1Ds/uf3b
         AEqDVP/uUIWqVvGM/D0Xs9/rWXFSWFsE8JndJpSvGWize7261W5znP4aYQLfJMj3EFan
         39/RccSrg/tlKZaUsRYbnXaNL61xov0doPAzoqa0aCwVy+8aXICZJRHMk3Z9Cc+jCbc9
         EUkZBzbJn9fGs1O+0kuIaYmKitiFs8m4S+4sJmSexwvqzprVagAKh2fISDwLf7XQmC0T
         KXdVhHiLXehs3JdMckc7DvqNHc9JlaZ878bLvOGX3rUfJyfzSnzKm0fz6TZMdO12bOug
         K/FA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAWrAJ56YaiHDeSfeCH5g5YyPywJ57IU2Mn390gx5nIylDQk4awH
	yZttmzL7lPZQ8IvOhZ5JPSJNT940w27UNUYyzbufVy1MtCV8UZN51r3H4YlwZgDzmjFb0JWM19R
	uy9/j0K9m8LaC/nPuvE8kIICoqAFPtmBk3HPxvZQE5S8hQVHqR2A+dJX6HkMmBl4gGg==
X-Received: by 2002:a50:8877:: with SMTP id c52mr3253edc.253.1556801536318;
        Thu, 02 May 2019 05:52:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpx+l/qkMkMhNnl2O2Li+0UO50+v3QAeVQrnN0qLPFqjcYK1mqjY2rtquMnkucZuUTbKfg
X-Received: by 2002:a50:8877:: with SMTP id c52mr3173edc.253.1556801534835;
        Thu, 02 May 2019 05:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556801534; cv=none;
        d=google.com; s=arc-20160816;
        b=DtGEqHXRRJnc2hMLmOPrjtAHCrg0D5qY+9pLv45aUP0sbGDR30Ti70xGOiSZP1Ytmz
         Qc8eFBY0l4EftdgmEFsTkRmmAbo6WErrtekCm0anwkeqo+j9ulLifEPi174Y1O6M0UeQ
         fu2Ky4k/oz3lOq8WQqMZGKirzboOppncWbD7GW6wLY7Yd1GH+2Cq4O+hsHUjWKX4Kb+6
         FOG5munPTRK3RNgaw3SbiX7ePRgl/IOcHydZUxH68CpTQ90vKRXPtNFRi+CLsJPo72KX
         rsZDgadGC6sS0EA77tnmiF6nXfZxTIIBEPVaZSPdox+0hBv3cd+QfHIXT9z0JVhFoaQM
         d24g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IUBMaIemPZgl+D4zOsC4haMjnlTeGL60MvB6fSw68e4=;
        b=slWqr7r23BVdVppv0dYUK/0eY463yPQcGSPwh7R9e6AJRwUQeQcX3+Uuw2mbFEtiZn
         uHHjHGI6ofVttlcy4hSEGFEEnR2XbHRMwXD/b5e47W2dojX8RsUn78PoAqYzLk83tKu7
         bfWDEiumRI2kKtHXN+B4nvqIZAuwO77tNx6eFXq1PW61vwSD0wDvHr6YddU7WYuUUeXQ
         tBgAII9QREzv+kDLu0vs5IWW6f1JxIaP8HQ7vbWW7D7DBBFddPMw8SiHw6kcjhvgcE5+
         Mk3IrME6LjcnW8LNkhzG9j5eMT2y3ErbEsKHTPTOZoZA5xQ3v50iYzwGIb7CRwlRy+7W
         beSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si3414860edh.202.2019.05.02.05.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 05:52:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E2D22ADE0;
	Thu,  2 May 2019 12:52:13 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: gorcunov@gmail.com
Cc: akpm@linux-foundation.org,
	arunks@codeaurora.org,
	brgl@bgdev.pl,
	geert+renesas@glider.be,
	ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	mguzik@redhat.com,
	mhocko@kernel.org,
	mkoutny@suse.com,
	rppt@linux.ibm.com,
	vbabka@suse.cz,
	ktkhai@virtuozzo.com
Subject: [PATCH v3 0/2] Reduce mmap_sem usage for args manipulation
Date: Thu,  2 May 2019 14:52:01 +0200
Message-Id: <20190502125203.24014-1-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
References: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

Just merged the two dicussed patches and fixed an overlooked warning.

v2
- insert a patch refactoring validate_prctl_map
- move find_vma out of the arg_lock critical section

v3
- squash get_cmdline and prctl_set_mm patches (to keep locking
  consistency)
- validate_prctl_map_addr: remove unused variable mm

Michal Koutný (2):
  prctl_set_mm: Refactor checks from validate_prctl_map
  prctl_set_mm: downgrade mmap_sem to read lock

 kernel/sys.c | 56 ++++++++++++++++++++++++++++----------------------------
 mm/util.c    |  4 ++--
 2 files changed, 30 insertions(+), 30 deletions(-)

-- 
2.16.4

