Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04443C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 13:26:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E65A217F5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 13:26:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E65A217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECF1A6B0006; Fri, 29 Mar 2019 09:26:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7E4B6B000A; Fri, 29 Mar 2019 09:26:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6D4E6B0010; Fri, 29 Mar 2019 09:26:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA2966B0006
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 09:26:24 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id b188so1733424qkg.15
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 06:26:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition;
        bh=6tZ3FsToy/uGhRDMKBuu0T5a7ZQTYi3c4gG8cjj/IR4=;
        b=HOYgd5eMGmMu877UhR/LojNsL9HcsBXxYh0aU7unZVPQO/xd//oP5cFHCxjP3m/RYT
         qnWumOzCvrSCU0BmA3PZ4ypJR2h/aOCtsodgdlxgANdUzaXy7FomfrW/bBjjFW6V43D1
         h/n/eYdkt0MgDHlid7xPo7flzbMX3aNHaYCnlMlJ54AhX/nFZmmlxXZXRqAiodkJSlxI
         Aq5oUHLMpMcIn70DHK1SwJudawWstbY9Y00A7D/Tlow8G41zbzlgNBxYQMKaW9eUx0nV
         /VRQY0+LlNKWICJYmnp6tBC0SVsOLo15gcWL9cF7vDQnSWhdg5JvvwOkjDNrtWwk2o+C
         msVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVZRhUMFD9xDOVrFuFeYNGAsclneytK+pu/hL8Jb9+nllIG+DwT
	2PdJX4eb4OmEvHBdGWyScwijE+qXADloS9wZe/DU56wwGCw8oDZ76CNyZfSGCVvQNLrMeL3gY2L
	SeKgkJr5qgYAzkMlUVT8RXZb54m3sGnsVWaAJ3lxFiDVKKR5DXH9KDJw+pYgkhfEzvQ==
X-Received: by 2002:aed:3bc3:: with SMTP id s3mr16676471qte.313.1553865984491;
        Fri, 29 Mar 2019 06:26:24 -0700 (PDT)
X-Received: by 2002:aed:3bc3:: with SMTP id s3mr16676414qte.313.1553865983750;
        Fri, 29 Mar 2019 06:26:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553865983; cv=none;
        d=google.com; s=arc-20160816;
        b=kQUw0EAU8I/Eq4SCDMRsIkocoCnRtMoCN2uhiqUGUuekpgGEgov9UQfa2WD4PC1BpP
         CsJ7pgsCORFPwMrdxFTApZkZ/BKXzVIYWkpM85kyvYQlHsfmwlB2KPejDezgoRG68Jpp
         YdWoF+3EXh8TVnLS3oIbF1MzshUqnW4T9Fvu5a9ALKIDwpdiVjs2In3V71/lC69Tir8i
         KXSRVv2kDiuW3SE6pnPRJZfX/Az+Bv1V8javJJxC7aB7Hu69hoXA0ooTWdz0VTToyrx0
         m6lyn5ZfTsq6czFfViJ7YH01Ixb4XPB0Rt6v8gH8MGxAQuyv1wcsigxZVIWfi++GWd+5
         JMcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date;
        bh=6tZ3FsToy/uGhRDMKBuu0T5a7ZQTYi3c4gG8cjj/IR4=;
        b=lE9QFfLIP6OF8HbkL9qigqJY23Am4VYsqdio6ESAhBaR+FUjCbD90T0hjdz+FAQdZR
         8AvAfg0dFkBVW+8tr0fCkzXg4x2ihsJmU+cJETzWPMM6KRyC4zRuPpNj9c0+nV3cgOT2
         W2l8uB1GT0d9oMEUgsVh2oHb02B5PFj6Tlh4oa9AHpkP1EFh1S2l42Ruh7vtxWEN33mU
         E9OZNXSc0/6SZ+usqSuRj1SXQy4aaMsoKKuri8nEIo1c4CWM50xCm3V6q8S+/XD+sfSm
         P9u3zD4mGFiqEy0vhH2+fzhHjtjzIGy/6gGOGxx8WQQkofV6nWHjtDGt7LVk8NtlW1Ik
         dJ6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y26sor2529233qtf.12.2019.03.29.06.26.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 06:26:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqz9t/fOoWybrlhU5qTUKqQb8Vg0MsizWKV62BSCAnVK0lqtO0/FYFYgcKbqvUoCo7B+Vt0rPg==
X-Received: by 2002:aed:3c0f:: with SMTP id t15mr21216042qte.282.1553865983383;
        Fri, 29 Mar 2019 06:26:23 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id y6sm1102459qka.69.2019.03.29.06.26.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 06:26:22 -0700 (PDT)
Date: Fri, 29 Mar 2019 09:26:19 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
	dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Subject: On guest free page hinting and OOM
Message-ID: <20190329084058-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000022, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrote:
> The following patch-set proposes an efficient mechanism for handing freed memory between the guest and the host. It enables the guests with no page cache to rapidly free and reclaims memory to and from the host respectively.

Sorry about breaking the thread: the original subject was
	KVM: Guest Free Page Hinting
but the following isn't in a response to a specific patch
so I thought it's reasonable to start a new one.

What bothers both me (and others) with both Nitesh's asynchronous approach
to hinting and the hinting that is already supported in the balloon
driver right now is that it seems to have the potential to create a fake OOM situation:
the page that is in the process of being hinted can not be used.  How
likely that is would depend on the workload so is hard to predict.

Alex's patches do not have this problem as they block the
VCPUs from attempting to get new pages during hinting. Solves the fake OOM
issue but adds blocking which most of the time is not necessary.

With both approaches there's a tradeoff: hinting is more efficient if it
hints about large sized chunks of memory at a time, but as that size
increases, chances of being able to hold on to that much memory at a
time decrease. One can claim that this is a regular performance/memory
tradeoff however there is a difference here: normally
guest performance is traded off for host memory (which host
knows how much there is of), this trades guest performance
for guest memory, but the benefit is on the host, not on
the guest. Thus this is harder to manage.

I have an idea: how about allocating extra guest memory on the host?  An
extra hinting buffer would be appended to guest memory, with the
understanding that it is destined specifically to improve page hinting.
Balloon device would get an extra parameter specifying the
hinting buffer size - e.g. in the config space of the driver.
At driver startup, it would get hold of the amount of
memory specified by host as the hinting buffer size, and keep it around in a
buffer list - if no action is taken - forever.  Whenever balloon would
want to get hold of a page of memory and send it to host for hinting, it
would release a page of the same size from the buffer into the free
list: a new page swaps places with a page in the buffer.

In this way the amount of useful free memory stays constant.

Once hinting is done page can be swapped back - or just stay
in the hinting buffer until the next hint.

Clearly this is a memory/performance tradeoff: the more memory host can
allocate for the hinting buffer, the more batching we'll get so hints
become cheaper. One notes that:
- if guest memory isn't pinned, this memory is virtual and can
  be reclaimed by host. In partucular guest can hint about the
  memory within the hinting buffer at startup.
- guest performance/host memory tradeoffs are reasonably well understood, and
  so it's easier to manage: host knows how much memory it can
  sacrifice to gain the benefit of hinting.

Thoughts?

-- 
MST

