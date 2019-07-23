Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AF53C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:07:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D4692238C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:07:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="krorYgFC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D4692238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 070AC6B000C; Tue, 23 Jul 2019 17:07:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 048F66B000D; Tue, 23 Jul 2019 17:07:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E79C98E0002; Tue, 23 Jul 2019 17:07:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3BE76B000C
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:07:48 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so22667161pls.17
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:07:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=eXdJyX/5y1/FGa+5JWyiUL+IHdXyD6YsS6A0RC/riP0=;
        b=sRVsqG2WL0icjFSVNVcrz5uizmsF0bp0yqxtrE71WXJ/nlt42K0cRE8pXr/WKUMrCL
         2pbcw+zijBSK3tJky5SogzG5R0DU3nNMoNVjSvR7rs016LDF1nemFo/pt2Z486wuDNhu
         nVAN7sRzwEzC0dH0hr588AyMIU5Dre1x+OyNNLIBdhsA7VVCBoG1fq+UFnnEWtrWGjXL
         2ztpc1CGdcRGqoLJNQOz6QmCCQ58WY5XLX4pZwqPRSQHGaTdf5zAxVyCMyW8ONqXfs/z
         EFgQYUo1Exuqcgs5ykU0qKHkQwAJ4ZyV7h9sFJZcXHXayWnBZs6CLdpw0+ivMwMjFdyO
         sjmg==
X-Gm-Message-State: APjAAAWyFGM1oYhiEoQxS9F5lOGRpqjlGvaC55YzY8dfIT1ilLceNmYZ
	tmq0UbStsvNv7oJ444EPPQqMBulcmWxjYAeSKNbImtXqGenVp8GpZo1KJK+CpYCK8lXGpfrtQUb
	qHEoAJy7GwlvCtSZaUFxjCpSQkvK6fFjtQcP0It6Y1+1dKMQtPDP/+f+vNRk5S+rABA==
X-Received: by 2002:a17:90a:1b4c:: with SMTP id q70mr81786939pjq.69.1563916068422;
        Tue, 23 Jul 2019 14:07:48 -0700 (PDT)
X-Received: by 2002:a17:90a:1b4c:: with SMTP id q70mr81786888pjq.69.1563916067585;
        Tue, 23 Jul 2019 14:07:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563916067; cv=none;
        d=google.com; s=arc-20160816;
        b=rLSihJ/VoGaxqtCHf+H6+ZSI8XSH6Q8LIjNS4kw5geQBsXdvMwO35eBA4bXlsHuvxC
         Uq/mff7T4dFiy0775iUKYUeapZvOCLKKpYtEzdE+z+zNsCk0PR3evG3raYZSt49zbwvK
         tywsMrqgnzXbvgeBsFUvgs7Yo8zkD4vX9Xy4B+bDNOgpi6+RDiHq0EgF2PQmb+CdMe7H
         K0Kx5NKDcLsc95/cYn0VZMqLgdHPU4+3J2SDeZZnbYc57ySc2NweEGX5dObv7tzgAoZ5
         PfuraWXY2YEKp6eAuniYk7Us2kHXJp3EjUDbOMy/GQgGqOXaRXG3d+e3S+I836e+iuXP
         Hn1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=eXdJyX/5y1/FGa+5JWyiUL+IHdXyD6YsS6A0RC/riP0=;
        b=XpR18DNlIksSDII+O6dR5NF9ICQxsHwEp0sbk/m8T9BkVwaLzXL5e+akjHgqxjKV8Z
         3qRm2MBOyYuOL4zLjU6OjoISBWFVMpxV7fuMgSpc7TbyyQ5dezzSWjUXeXNMnLRi67Mb
         x49OCH3uliODbiGIHITAuH587z35LQ4YJocvY25LQZyaxm3tH0U4K/mRobKVAdtkwhk5
         Gf9cbSh2gjqrjYsrkRBR/i9JeHVym9C70LXAwicLv2JS9Jn7jI2tkJHmV5/9nxujIzb7
         Ea32yNpcekSZBEwM0a8x/NMFqTDaZNdzHTBy+guhXpZTD+MpcR5KGDkFSrIaL+FZJeFS
         ldzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=krorYgFC;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f16sor24116960pgn.77.2019.07.23.14.07.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 14:07:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=krorYgFC;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=eXdJyX/5y1/FGa+5JWyiUL+IHdXyD6YsS6A0RC/riP0=;
        b=krorYgFC8c4EEHktVPMM8Uc7p10JFe0m3Uh5Z7ygeHlBHaZoO9KsDsqrGfKaOQ5n45
         Uu4t0n4z/SGQkouCaz5dv002xNN8r2wM56rDbp6+ZTVvamypB6MVSsqNBUzlCunbD8JI
         DmdBacuJcpJxjt2ybAFvHIpYgMHnUYIG12DWQ=
X-Google-Smtp-Source: APXvYqx+RlfYYF9BsUFYetL+eK6XXW+0RaA14tPNlGA5LsYqVrZUzX7sAKiZK0j2exSKPYRkMQRd9Q==
X-Received: by 2002:a63:c008:: with SMTP id h8mr75676650pgg.427.1563916066868;
        Tue, 23 Jul 2019 14:07:46 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:48f4])
        by smtp.gmail.com with ESMTPSA id l31sm69890987pgm.63.2019.07.23.14.07.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 14:07:46 -0700 (PDT)
Date: Tue, 23 Jul 2019 17:07:37 -0400
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH] cgroup: kselftest: Relax fs_spec checks
Message-ID: <20190723210737.GA487@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On my laptop most memcg kselftests were being skipped because it claimed
cgroup v2 hierarchy wasn't mounted, but this isn't correct. Instead, it
seems current systemd HEAD mounts it with the name "cgroup2" instead of
"cgroup":

    % grep cgroup /proc/mounts
    cgroup2 /sys/fs/cgroup cgroup2 rw,nosuid,nodev,noexec,relatime,nsdelegate 0 0

I can't think of a reason to need to check fs_spec explicitly
since it's arbitrary, so we can just rely on fs_vfstype.

After these changes, `make TARGETS=cgroup kselftest` actually runs the
cgroup v2 tests in more cases.

Signed-off-by: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 tools/testing/selftests/cgroup/cgroup_util.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/tools/testing/selftests/cgroup/cgroup_util.c b/tools/testing/selftests/cgroup/cgroup_util.c
index 4c223266299a..bdb69599c4bd 100644
--- a/tools/testing/selftests/cgroup/cgroup_util.c
+++ b/tools/testing/selftests/cgroup/cgroup_util.c
@@ -191,8 +191,7 @@ int cg_find_unified_root(char *root, size_t len)
 		strtok(NULL, delim);
 		strtok(NULL, delim);
 
-		if (strcmp(fs, "cgroup") == 0 &&
-		    strcmp(type, "cgroup2") == 0) {
+		if (strcmp(type, "cgroup2") == 0) {
 			strncpy(root, mount, len);
 			return 0;
 		}
-- 
2.22.0

