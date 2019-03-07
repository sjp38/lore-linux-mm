Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32B7FC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 21:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC20720851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 21:27:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC20720851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 424E38E0003; Thu,  7 Mar 2019 16:27:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D4968E0002; Thu,  7 Mar 2019 16:27:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29D428E0003; Thu,  7 Mar 2019 16:27:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0DF08E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 16:27:24 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b40so16683805qte.1
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 13:27:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=D0PD1+EYzYfRGlnZDHVmHB/39F4kvkgFTrgUgG9bXsU=;
        b=YERas65uz9q9nQ9arWpxnzvXiKZq1383gar+KN3GY46BXEoPmpKVPH5l7FtKM0GIji
         NsZCcX4cq4ymK5IwfgZO3C+DxFoZ/5/DYgUc5RtX9CndfFNTg/DGQqxgIkcYaUkVLK6x
         cnUy39KgKco/GuoMp9AMVURZwlvJF/bmFN27hSEOkiDJ6+0trDl7lZsjz6FMWE5JRewJ
         zoK611MbtNf6CjnQU+x2QuqUjrcPA/UhW1g6hel6mGlUzo+RvlMUSQdThBoCq2gThJUd
         z+DqOPbSAW7/I5Svw8LCXP4CBbWILrwk0WOlo2tk9vd6/oZmcrG87IY1bP8ETK+KiC4n
         4MFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUusaRd2QbToSoNxF0wO7EIDk+ash3zPhrpHGYbmiotyeqzO6T7
	WJ/K9oAsn825AKgP7L2QMkXikmyNpldZBHNqvaGBEcv6rctu2eZvB+itJQbnV0s9qw7mAeNyMsj
	aE5bAHLeW0pfb4Cc4qDoiiTOnBugaX7MRD46mbaloy4NQ5GOCw14v0YAwMTEPpy3TyQ==
X-Received: by 2002:ac8:313b:: with SMTP id g56mr11820113qtb.216.1551994044686;
        Thu, 07 Mar 2019 13:27:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqxl68XQjlUIl11z2XKq4bpFWyEgoZcKQ+JhD+M8X7FZOk3jj6qrykHQ11klVUee4S0bb1kD
X-Received: by 2002:ac8:313b:: with SMTP id g56mr11820061qtb.216.1551994043771;
        Thu, 07 Mar 2019 13:27:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551994043; cv=none;
        d=google.com; s=arc-20160816;
        b=P224MMUDHwmoOgl7KWGMZYEUFw+RLdlb2IK02Os04cZF6ZaYSosW/JdEG+JX1lGKlL
         4FPcAzCMQpDW9ZeG2ywjmLVHJ/p8+QsytliATVybk+iYSvJtR8H+vIiySAHTvhJSim4G
         aluNAedhve4IgBZX1QirWk0MTudHb7x+LNzRkKg3/F8GpLJsu6DrrVG6dWUxTwEjw6s8
         7t0NZDbIV5HqWZex5oDiZae1CcOvplk5RbsvB7KoQlnN6qx+hmEcjXYyzXq/lyCrmZpb
         dc/p7CtA43840XogYmn+12ktgx08HuICV+k/wc7ILnvvmcAQtar8fh/ZDeBjmGSGIwZo
         2miQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=D0PD1+EYzYfRGlnZDHVmHB/39F4kvkgFTrgUgG9bXsU=;
        b=aO5jJ7sK7mjhMm5HlYVdU2mRyvUiSblkgjqNMCl9vh2zVmBDVG6M+CJwgFKM08qST7
         rhOUsYQNQ8WvGjcAxzrGdlyAom1qdukVD8pLOMfec2NAzKqS4dHMvY75N1cf8svJ4UsR
         7wM+fQt5oF218jFuka+fGVrVbORvDNdUGRXwEbj/diDo816TmXg4XrUcwJPvGEYz82HR
         +MpfNHfaRS48P2g6gxRoIhPO7gBqnlHGtdBd8TSepM1+m8B4P/ip0VzkzPK83n1BOgtO
         F3P65P7quJzL95GaQtHLanB6st/Y6DbN998qKwU/RgpWFS2xQIycGrDC1Vww2NCJx3Wb
         h1VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l4si1868864qvl.131.2019.03.07.13.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 13:27:23 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BD4F6307CDC7;
	Thu,  7 Mar 2019 21:27:22 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BFA3E60BE5;
	Thu,  7 Mar 2019 21:27:17 +0000 (UTC)
Date: Thu, 7 Mar 2019 16:27:17 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org, Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307212717.GS23850@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
 <20190307101708-mutt-send-email-mst@kernel.org>
 <20190307190910.GE3835@redhat.com>
 <20190307193838.GQ23850@redhat.com>
 <20190307201722.GG3835@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307201722.GG3835@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 07 Mar 2019 21:27:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Jerome,

On Thu, Mar 07, 2019 at 03:17:22PM -0500, Jerome Glisse wrote:
> So for the above the easiest thing is to call set_page_dirty() from
> the mmu notifier callback. It is always safe to use the non locking
> variant from such callback. Well it is safe only if the page was
> map with write permission prior to the callback so here i assume
> nothing stupid is going on and that you only vmap page with write
> if they have a CPU pte with write and if not then you force a write
> page fault.

So if the GUP doesn't set FOLL_WRITE, set_page_dirty simply shouldn't
be called in such case. It only ever makes sense if the pte is
writable.

On a side note, the reason the write bit on the pte enabled avoids the
need of the _lock suffix is because of the stable page writeback
guarantees?

> Basicly from mmu notifier callback you have the same right as zap
> pte has.

Good point.

Related to this I already was wondering why the set_page_dirty is not
done in the invalidate. Reading the patch it looks like the dirty is
marked dirty when the ring wraps around, not in the invalidate, Jeson
can tell if I misread something there.

For transient data passing through the ring, nobody should care if
it's lost. It's not user-journaled anyway so it could hit the disk in
any order. The only reason to flush it to do disk is if there's memory
pressure (to pageout like a swapout) and in such case it's enough to
mark it dirty only in the mmu notifier invalidate like you pointed out
(and only if GUP was called with FOLL_WRITE).

> O_DIRECT can suffer from the same issue but the race window for that
> is small enough that it is unlikely it ever happened. But for device

Ok that clarifies things.

> driver that GUP page for hours/days/weeks/months ... obviously the
> race window is big enough here. It affects many fs (ext4, xfs, ...)
> in different ways. I think ext4 is the most obvious because of the
> kernel log trace it leaves behind.
> 
> Bottom line is for set_page_dirty to be safe you need the following:
>     lock_page()
>     page_mkwrite()
>     set_pte_with_write()
>     unlock_page()

I also wondered why ext4 writepage doesn't recreate the bh if they got
dropped by the VM and page->private is 0. I mean, page->index and
page->mapping are still there, that's enough info for writepage itself
to take a slow path and calls page_mkwrite to find where to write the
page on disk.

> Now when loosing the write permission on the pte you will first get
> a mmu notifier callback so anyone that abide by mmu notifier is fine
> as long as they only write to the page if they found a pte with
> write as it means the above sequence did happen and page is write-
> able until the mmu notifier callback happens.
>
> When you lookup a page into the page cache you still need to call
> page_mkwrite() before installing a write-able pte.
> 
> Here for this vmap thing all you need is that the original user
> pte had the write flag. If you only allow write in the vmap when
> the original pte had write and you abide by mmu notifier then it
> is ok to call set_page_dirty from the mmu notifier (but not after).
> 
> Hence why my suggestion is a special vunmap that call set_page_dirty
> on the page from the mmu notifier.

Agreed, that will solve all issues in vhost context with regard to
set_page_dirty, including the case the memory is backed by VM_SHARED ext4.

Thanks!
Andrea

