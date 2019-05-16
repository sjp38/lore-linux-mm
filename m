Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F759C46470
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B99E21726
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B99E21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FDE76B000C; Thu, 16 May 2019 05:42:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B1FF6B000D; Thu, 16 May 2019 05:42:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D11C6B000E; Thu, 16 May 2019 05:42:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4F9E6B000C
	for <linux-mm@kvack.org>; Thu, 16 May 2019 05:42:46 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id h8so819944wmf.1
        for <linux-mm@kvack.org>; Thu, 16 May 2019 02:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I6Qf9WePQnjM1qP5GnvXQ6iGQgDn7ErWaVxKlruplAs=;
        b=pvBoNHr6WvUqgJZwi29PNhnVcWn02DDkH0NfGbieeinKz2/dXF/lcPZta1hM9lTWfP
         dI6KCzoaLegqTrBYpOKAwkZcd7grgaB5UUyiCxBE4UllN4de0PSIMuPy0twlz9f8K7m2
         vabUbzZqvo3RDRMl8pnesDVl3RZUEGaEI3VJjbW31JMyqVo/vlP4WBTWB3x8PJKMw/Ee
         UdRwDEon5Ybl00Zl1/xUwMotr0wAvFPw11VLEwO82QZOWR1s4Uw1tTL7FwS84v5DV3To
         nGs0R3O6zFI8ewmBLtQpEJPNZve820qheSLtASWbY0aarMRsvnxBmGcoHjYKDorUfBvn
         073w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVrCDCBjGw3BrF0JSa4ON89UDMhqJqkM+0KEk2i0Wn6eB0ju9hl
	zNT7QfODtYfhCt6ypfHjWhqDDqE7W1cek/7fsK7xz6MAr3rWXlegQkQsLl0j13lz3qahvrAjTC2
	sLD+A5yvb7FAkcaMsIF/6MCY5/C5Ycpxx+fRTonZUkY/EsIh7+Kj5b+PlRPDCcx/Glg==
X-Received: by 2002:a1c:e144:: with SMTP id y65mr26100826wmg.147.1557999766268;
        Thu, 16 May 2019 02:42:46 -0700 (PDT)
X-Received: by 2002:a1c:e144:: with SMTP id y65mr26100775wmg.147.1557999765221;
        Thu, 16 May 2019 02:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557999765; cv=none;
        d=google.com; s=arc-20160816;
        b=tACdX6GLPmwDzOHGMennKf9w9g8QXEfvmV3xJ7by8MlmAV8IrnMsEXeJ8fd78or27K
         ZUgXoY4woSg8k7wOBOd0CREO0YpCU4DvBNo5DWTEi6yGxUgZZWMzrTImTdwCmQhg2FZV
         IiCGitbi6RpEP9LK80NFp/JVVrySMdms6T10V2lTSrusxtpdNk+e0tVY7pxPWedHYBnM
         ekXwVvkK5ki/EZ/0wElox9vYKOj0dqiF/L3CCO2gRcRZTPotdeh8lwwMekUpn3tRNRuE
         aDio1twqJ/BXT0oy4oFOz+9JL+w7uUkWXnqSj4cDmXTvVRhqr9sg5ELeVjOxbWKjs7ax
         yQMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=I6Qf9WePQnjM1qP5GnvXQ6iGQgDn7ErWaVxKlruplAs=;
        b=VKQEFpXuUD/6QNr3ywWhKROJ/XlOT1jqVfDSPXRyluldLzOqwMB6Q5D1lf7KRfAISQ
         bL0HerS88FDnc0g0t1Jk/ucKEAmlpTCVhpSWh/NF5SV+TO+r4GAM3vVgIlFBzM0y6TM1
         mu9Pm5nXfkcqPGs8enfKAabZ8fBsCG0QAXq71PhLzT05qRS7erq/1GQfjh7xfZykaIwu
         WIwm6ySIO7j9Pv+xsyHFgewZBnnAO6iXxHqgyKEj+mUrNvsdymM21puVsMmt015tGXsX
         lUPXCsECgXtnByF9Di5Fuea4hnZcxYSePM+A9iI1ClJg1ipPYaFhF6AsiUXEmlr19u2c
         1Jqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o3sor2007346wmo.17.2019.05.16.02.42.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 02:42:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwocKMkkFgpDNBPx7AOMP66gc9e2eLJvBHtDID7H77ayfvD2k23YyAA2hs51SHVNKxVSScv4w==
X-Received: by 2002:a1c:a695:: with SMTP id p143mr27260709wme.128.1557999764844;
        Thu, 16 May 2019 02:42:44 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id t15sm4635388wmt.2.2019.05.16.02.42.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 02:42:44 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH RFC 5/5] mm/ksm, proc: add remote madvise documentation
Date: Thu, 16 May 2019 11:42:34 +0200
Message-Id: <20190516094234.9116-6-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190516094234.9116-1-oleksandr@redhat.com>
References: <20190516094234.9116-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Document respective /proc/<pid>/madvise knob.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 Documentation/filesystems/proc.txt | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 66cad5c86171..17106e435bba 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -45,6 +45,7 @@ Table of Contents
   3.9   /proc/<pid>/map_files - Information about memory mapped files
   3.10  /proc/<pid>/timerslack_ns - Task timerslack value
   3.11	/proc/<pid>/patch_state - Livepatch patch operation state
+  3.12  /proc/<pid>/madvise - Remote madvise
 
   4	Configuring procfs
   4.1	Mount options
@@ -1948,6 +1949,18 @@ patched.  If the patch is being enabled, then the task has already been
 patched.  If the patch is being disabled, then the task hasn't been
 unpatched yet.
 
+3.12    /proc/<pid>/madvise - Remote madvise
+--------------------------------------------
+This write-only file allows executing madvise operation for another task.
+
+If CONFIG_KSM is enabled, the following actions are available:
+
+  * marking task's memory as mergeable:
+    # echo merge > /proc/<pid>/madvise
+
+  * unmerging all the task's memory:
+    # echo unmerge > /proc/<pid>/madvise
+
 
 ------------------------------------------------------------------------------
 Configuring procfs
-- 
2.21.0

