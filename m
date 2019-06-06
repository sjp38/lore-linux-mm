Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40872C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 21:46:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 050A8208C0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 21:46:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="dfZnA3Lo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 050A8208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71C3F6B02E9; Thu,  6 Jun 2019 17:46:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CB9F6B02EA; Thu,  6 Jun 2019 17:46:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56CD96B02EB; Thu,  6 Jun 2019 17:46:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8FA6B02E9
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 17:46:47 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id y81so1157972oig.19
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 14:46:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=z+anmWmudWvyw9xqAYjMHpOuv0JofI8BMS77rTcp5uo=;
        b=UVsMti6soU2QUQyn7fZhRsff187U96gHS307v3eeeiAQCAxmutx05yjmJJ/SfEVg7h
         tNA8+6jJOr6ULaUWZ2ZxsEmcPJIrdPSR50B/rpEtdC7GUM3e6dpicjMujpjzaYTzCRWm
         Z69cuZyoOux72R3xhIJPSNbkrfZ6mLbIb9+f900LqasEs2yhLhxEz0jRzikkmcXNH83e
         TLxTYoT+vQ18EiLFXRW9M8Y+BYqSOfOr0ZSAAGp5w+P8veTqVhIV4zadABBbUJ1HtYyf
         wpuLWWdGHgKfbEFjr2OF+Ud3GJraYfgmLXX1axkmwcLNMDSh8i4iDOiveyvCamA9zkiL
         w2Qw==
X-Gm-Message-State: APjAAAWWY9XK3YvkK/0DhpYy/rqzwLk87RtnVELU2XqS3yNL+C4ycFFh
	vY5VdxgvQC1R5ecA3JNVW3PZHnVvtmjlzirFOGHUCJAMW7TsNcvxOAEHFmTp9HEuC5s2bqF8Aih
	BTKX6Lhcwow7VWcdviYnUwBCvxJ+92Lm25QBVqVkGWwkPDzemE2jKeu6eilVpLtOL3g==
X-Received: by 2002:a63:1119:: with SMTP id g25mr585929pgl.380.1559857605866;
        Thu, 06 Jun 2019 14:46:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGArKlxWVEOCrBGW5jo4VVEtm8A8FgaUkIbvLtD7oXB70SD9hVlSEr1AgfotDxkHz4Tmuy
X-Received: by 2002:a63:1119:: with SMTP id g25mr585873pgl.380.1559857604919;
        Thu, 06 Jun 2019 14:46:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559857604; cv=none;
        d=google.com; s=arc-20160816;
        b=ZANDRRf7IOXBBJIPCT2rzJbqND9JEuQ5VHVZepjN4T49B9rcuF8ItoJU8sOs8KNS8a
         zhiAMnkKcUZz50G57q8EJipLwtYIe3YYOJAPkz9P2AfVVmTyBOLf+WBbBY9r2KGNcdFa
         1hQTyeZSYCFnrCdeqMB+AC3cU3h5FoM3R7VECD0T6foJDT2uceBn8TFZ68J8LFasaRmU
         Q6x9TVmNq7o+DMW/8SDuBGyuAzWaomHUaf/iNKitSTixokcMrtePwmftvYjaXETtfrAe
         yu/5iQ0AddZk/CMAkJtoQb3w0yRYSIS5VISYBg0tPkezjwN2ioB3Wx5kMErKqs5xKTZ3
         +9kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=z+anmWmudWvyw9xqAYjMHpOuv0JofI8BMS77rTcp5uo=;
        b=yl65AItbS59IOhBn9CUx2VfM/ulHmT/tTkUaICg99IrfB5CyZDUrqqU/Lwvs5Wvk5L
         TSAtTz3qylEnn74DQ1xSjuc3m3iNh2MNgH7PDMloHLSBiMGVuD3agHxhDfcr3jU3sEqV
         mWR+2sZsTfIMn+fLFkgoS7NxF5g+vRl0T+xfvzP2t5SMB0EH1AS19KK7kpPwQ6U8R5lq
         o0Dv5bAR9CkSDRUraH6r34gEqBPgKnG14Q4+52+p5O8cVSOhBh5KEvI1dkzRkf2njT96
         kjsmBwMdvjZMJH0KcPjt47UWYCd5qDcpiscelS4vtICZnVvrEBxVVlZPMaqNgq+X+C+9
         w9yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dfZnA3Lo;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l13si144250pjq.69.2019.06.06.14.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 14:46:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dfZnA3Lo;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 309C320673;
	Thu,  6 Jun 2019 21:46:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559857604;
	bh=e8zSxF2YstjZdXDoPM2QroSTxqWSMLpjdXaDzNM/bHM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=dfZnA3LoZI3kcekTvMdg7vm4wyUFToyxp29Scm6Cs7omCJytnHlzwlMXFqlGds2ht
	 tKZ/OehCLO9EzgtHqjvJGedCRwMgeIGQKU+kGulTg4LF9TrwyYbFy3R+yo1Vi1wg+x
	 L5CEq0PQe3DdZ/43QWfXSG4GV8UOuKXGuJHoNWd0=
Date: Thu, 6 Jun 2019 14:46:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: stable@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org, osalvador@suse.de, mhocko@suse.com
Subject: Re: [PATCH v9 11/12] libnvdimm/pfn: Fix fsdax-mode namespace
 info-block zero-fields
Message-Id: <20190606144643.4f3363db9499ebbf8f76e62e@linux-foundation.org>
In-Reply-To: <155977193862.2443951.10284714500308539570.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
	<155977193862.2443951.10284714500308539570.stgit@dwillia2-desk3.amr.corp.intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 05 Jun 2019 14:58:58 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> At namespace creation time there is the potential for the "expected to
> be zero" fields of a 'pfn' info-block to be filled with indeterminate
> data. While the kernel buffer is zeroed on allocation it is immediately
> overwritten by nd_pfn_validate() filling it with the current contents of
> the on-media info-block location. For fields like, 'flags' and the
> 'padding' it potentially means that future implementations can not rely
> on those fields being zero.
> 
> In preparation to stop using the 'start_pad' and 'end_trunc' fields for
> section alignment, arrange for fields that are not explicitly
> initialized to be guaranteed zero. Bump the minor version to indicate it
> is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
> corruption is expected to benign since all other critical fields are
> explicitly initialized.
> 
> Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

The cc:stable in [11/12] seems odd.  Is this independent of the other
patches?  If so, shouldn't it be a standalone thing which can be
prioritized?

