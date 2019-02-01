Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B363C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 23:57:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C35D21479
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 23:57:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C35D21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB1BE8E000D; Fri,  1 Feb 2019 18:57:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C61958E0001; Fri,  1 Feb 2019 18:57:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B505A8E000D; Fri,  1 Feb 2019 18:57:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8D88E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 18:57:43 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so10239654qtd.20
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 15:57:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1zfsjj5vBTBRHLFdxT+IiSqHEDo+xAlvYjfsHTgjjfw=;
        b=uPlUExXr3F9HJjoMMvp+fNZNIKHjuLuOzMcR9IlTEBsRG/SwiEaKprz2ydDn9DstTA
         8F40whdcDOZ671ZIqBOQ0DaA1BeOfSIlUxqliai2lPTTHhCIj3ws2Q6lQyRr9HQDm1JQ
         M+gfIlnNgWK84aaEfUJOGtjBVQ7kXngrysM0dyg4hQAq06DCKIoY0CMIhTUzFbs9eB9X
         jy+7cibIQDKBHsFUDtbB6dFLkcjg+9d30DDvUbx00v648CZj331103v4wbL9g5SfEG5X
         AAsFMfGknAbJrbrr3G38uWqFXu61YRbbkX3p7EbV4IhN/7emIaROH2KWtgLf6wbgN7Hj
         FwFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukd7mKP/iwORVhnKZHWW8Kc0I6+bfOrcw0tdrsZ1mJiN+/n43Utg
	G/09wuv7FcRS+/uXLmYexbW8fn7znUqI0DMK2H0gJvKBZxYf+dmQOho7sKnCYsiiJydtDCMAA0y
	x83RH3lmhBBqiJr2wrd6P+HvFgrDh0/SWE0MfHRB5o62A90zdtn8xLrFh5RCpPHR28w==
X-Received: by 2002:a37:ccc2:: with SMTP id n63mr36891113qkl.82.1549065463309;
        Fri, 01 Feb 2019 15:57:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5iQkPHvpLCkCViOTbFmOBBela1iv6k0aO32mLqPgchdmVvZMsRRnbE3MKErk8MJjjB663Z
X-Received: by 2002:a37:ccc2:: with SMTP id n63mr36891094qkl.82.1549065462643;
        Fri, 01 Feb 2019 15:57:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549065462; cv=none;
        d=google.com; s=arc-20160816;
        b=01rML2ObEgpTZa50SJ5quFGIPRiWd+rvkmDRCPOgR5yEbyieeAtHvAjAzf337fMppH
         /P+2HrLH7LXWYxmwJDDcbtdYLdPA6G/GHswJxNQ3r4O84rcAI8hfAH+pgY4Wn0wkvDL5
         wBvEKfLJSuqWMa5FDhwbZwnXYKau4gwg05x11T7aNLhgFWG2Yz7zEtW+UTjcXJJOeLBa
         BJFfYSp0gsu7TD+oDGhz3urJs8I6dd65GZbwNpdfMf265tvSwDwenL7l4IOxoJkOPU2B
         r2VkVhKgTchOXD34K0QEoWtp/CCK36TyJlDEwEkfMWhRYGKedFyhjbuqMDnlzDLqGXeG
         5GSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1zfsjj5vBTBRHLFdxT+IiSqHEDo+xAlvYjfsHTgjjfw=;
        b=xMAL9omlsHd50B2UQ6+13N0pf2qHXUtG22SnoRGRD45teBOOrzdOd/IOwBNf7zx5S7
         zTebO8LCiSLdOmXdPTLp5ZZClFK0tTPNwSf2W8IiWe8XSDvExxQdlpEwzaFJjTj3xGU1
         QLQxnLWDDjab0B1oRQLEa5tlJ44VRGVAtqMsjMf7a50u1IC4qalc7FlRi3r1kr4Kmpqk
         eMx4i5+9ouxuDRARz/vHoSX+b5xF0vc0Oo32SRCA9l0piiILaYs6Is9X1Sm+CBIKOVJh
         LBvCFf6McQgV/fOlUjQ0BYIEMkz691mYUA7iX+vgG1Y9sS7wmDV3tBwgoON64j+/xMIo
         sVng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k22si92100qtm.144.2019.02.01.15.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 15:57:42 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 72FE914404D;
	Fri,  1 Feb 2019 23:57:41 +0000 (UTC)
Received: from sky.random (ovpn-121-14.rdu2.redhat.com [10.10.121.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EC8236013F;
	Fri,  1 Feb 2019 23:57:38 +0000 (UTC)
Date: Fri, 1 Feb 2019 18:57:38 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] Restore change_pte optimization to its former
 glory
Message-ID: <20190201235738.GA12463@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190131183706.20980-1-jglisse@redhat.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 01 Feb 2019 23:57:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,

On Thu, Jan 31, 2019 at 01:37:02PM -0500, Jerome Glisse wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> This patchset is on top of my patchset to add context information to
> mmu notifier [1] you can find a branch with everything [2]. I have not
> tested it but i wanted to get the discussion started. I believe it is
> correct but i am not sure what kind of kvm test i can run to exercise
> this.
> 
> The idea is that since kvm will invalidate the secondary MMUs within
> invalidate_range callback then the change_pte() optimization is lost.
> With this patchset everytime core mm is using set_pte_at_notify() and
> thus change_pte() get calls then we can ignore the invalidate_range
> callback altogether and only rely on change_pte callback.
> 
> Note that this is only valid when either going from a read and write
> pte to a read only pte with same pfn, or from a read only pte to a
> read and write pte with different pfn. The other side of the story
> is that the primary mmu pte is clear with ptep_clear_flush_notify
> before the call to change_pte.

If it's cleared with ptep_clear_flush_notify, change_pte still won't
work. The above text needs updating with
"ptep_clear_flush". set_pte_at_notify is all about having
ptep_clear_flush only before it or it's the same as having a range
invalidate preceding it.

With regard to the code, wp_page_copy() needs
s/ptep_clear_flush_notify/ptep_clear_flush/ before set_pte_at_notify.

change_pte relies on the ptep_clear_flush preceding the
set_pte_at_notify that will make sure if the secondary MMU mapping
randomly disappears between ptep_clear_flush and set_pte_at_notify,
gup_fast will wait and block on the PT lock until after
set_pte_at_notify is completed before trying to re-establish a
secondary MMU mapping.

So then we've only to worry about what happens because we left the
secondary MMU mapping potentially intact despite we flushed the
primary MMU mapping with ptep_clear_flush (as opposed to
ptep_clear_flush_notify which would teardown the secondary MMU mapping
too).

In you wording above at least the "with a different pfn" is
superflous. I think it's ok if the protection changes from read-only
to read-write and the pfn remains the same. Like when we takeover a
page because it's not shared anymore (fork child quit).

It's also ok to change pfn if the mapping is read-only and remains
read-only, this is what KSM does in replace_page.

The read-write to read-only case must not change pfn to avoid losing
coherency from the secondary MMU point of view. This isn't so much
about change_pte itself, but the fact that the page-copy generally
happens well before the pte mangling starts. This case never presents
itself in the code because KSM is first write protecting the page and
only later merging it, regardless of change_pte or not.

The important thing is that the secondary MMU must be updated first
(unlike the invalidates) to be sure the secondary MMU already points
to the new page when the pfn changes and the protection changes from
read-only to read-write (COW fault). The primary MMU cannot read/write
to the page anyway while we update the secondary MMU because we did
ptep_clear_flush() before calling set_pte_at_notify(). So this
ordering of "ptep_clear_flush; change_pte; set_pte_at" ensures
whenever the CPU can access the memory, the access is synchronous
with the secondary MMUs because they've all been updated already.

If (in set_pte_at_notify) we were to call change_pte() after
set_pte_at() what would happen is that the CPU could write to the page
through a TLB fill without page fault while the secondary MMUs still
read the old memory in the old readonly page.

Thanks,
Andrea

