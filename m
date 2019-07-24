Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E156C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:56:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8EF1206A2
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:56:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8EF1206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9439C8E0005; Wed, 24 Jul 2019 14:56:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F4128E0003; Wed, 24 Jul 2019 14:56:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E37B8E0005; Wed, 24 Jul 2019 14:56:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF878E0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:56:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so30724972eds.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:56:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CVABItEjrIyVmB9btaRD3WPI7cDvO5eT+Hf0E+A7URA=;
        b=RPTipm3jjnYblekK1qaqkLFU+ZA9+/pUsBez5C3lxULIg6aRUYdcTDlk8jqXebDz4R
         W2n75Je6w/I+9XfoiTp03z0o0ZPBcMhaLwTqgkvMOYEKR8z8b7Id2zaHI6ph/NdXNekz
         iTgC05HWZydC6mneAlbitTNhUJErSKwBdn7v4jP/3RY+ujn4fTdu/i+I+MhCE0JLrn1C
         +ibeC72go7sG0k7yWRbu0ddQ0M/qRQ4qJJAQaJ1RSu6bHDTbtVgHZWoelFoL61shNfmC
         +x9Vhjk3kxuzQ3IjVyWjDZKIC+xY43MqPWX8VXtNbGujVNDAvuikrBJKNBLVGxLm0VxK
         gmgA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXIP2c4EqI6TmivvZoUl20BFNE0e7Pu2veNDKeOkQuc6nm4tNv4
	9QvEhUvC24neDvq4mPbHheXKn2dU3wzEtu64wrQMXsIODr5FJM9YztJuPrahDQCHApRgz7qOfnp
	ZPAyc2cDc3APRU4YRzPDn+a758sqFgVC/LsDBzye87Hkvby08vrtQ98rELV5LqQQ=
X-Received: by 2002:a17:906:46da:: with SMTP id k26mr64174685ejs.269.1563994581723;
        Wed, 24 Jul 2019 11:56:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlBj1/2Ini2Vde3UNzPB7VlDF0VHHuFzQ7qeqFvTK80p4VI5jnME2uD4ZV0unMevDS+BrK
X-Received: by 2002:a17:906:46da:: with SMTP id k26mr64174642ejs.269.1563994581004;
        Wed, 24 Jul 2019 11:56:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563994580; cv=none;
        d=google.com; s=arc-20160816;
        b=jGTAVTutgHZQEAtBbU7uQppWSkRjrVTbfqkLQY7As+n4lI3AyEW6T1v63nvIxSo8vk
         QN9XlvEs8fuhJJEFdPRAVJJP0zcnl7jlLkkspLtKctmF647QN4w8WRNdDsn3aOsJV1oJ
         OAQ3FHagcLM+vmqBCzG8ner513/csmsROkDnGwg8MZKAix/SxCnq88jeDuIeZv51l/b6
         eNaJoerkY6tfnAQvgcujXM+lT5j3JeYUfyoPqtlmVzwimw2kuHt2bfmKG+xf5f/idRpy
         ts5emPG3nOvtALYXMpAe6fRmYSgVVZVz6d6BWeN5taoLI7Vnn1U/vUlSa28SZTpAkHym
         ZaZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CVABItEjrIyVmB9btaRD3WPI7cDvO5eT+Hf0E+A7URA=;
        b=M1Ak1dxJO5FmkMey/Xb9NOR0ucneiBl97porIdfGILfPb0fJ2dFBqzQzF1SH6/0VyO
         sXYdcVfzaQQKsFicS0017QA6NagPsZrlhK+NUQmemRabugoLFsciSfW1YakNJgT2cG0w
         o3QPVvtDHS1OtS1iuTq1h7M/qgFcx4H2/3Dy7Hc408sDbX6NFrI+f7dAPFpePVHCPS/i
         Ti4i/FZi3Rt4zRIPMr2oe5wTkPpK41AR4+k7FvFogNO6QUQCD3cfDadyZ/LieX+Bb7gU
         IbdYG58CvVLFhWPGb2Wfzq1AvVifO9m5O4DkYIYpJ4cw4JOEz871L6vpWhPOn2i6XFuG
         YkIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t54si9075252edd.313.2019.07.24.11.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 11:56:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 377DCAE1B;
	Wed, 24 Jul 2019 18:56:20 +0000 (UTC)
Date: Wed, 24 Jul 2019 20:56:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724185617.GE6410@dhcp22.suse.cz>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
 <20190724152858.GB28493@ziepe.ca>
 <20190724175858.GC6410@dhcp22.suse.cz>
 <20190724180837.GF28493@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724180837.GF28493@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-07-19 15:08:37, Jason Gunthorpe wrote:
> On Wed, Jul 24, 2019 at 07:58:58PM +0200, Michal Hocko wrote:
[...]
> > Maybe new users have started relying on a new semantic in the meantime,
> > back then, none of the notifier has even started any action in blocking
> > mode on a EAGAIN bailout. Most of them simply did trylock early in the
> > process and bailed out so there was nothing to do for the range_end
> > callback.
> 
> Single notifiers are not the problem. I tried to make this clear in
> the commit message, but lets be more explicit.
> 
> We have *two* notifiers registered to the mm, A and B:
> 
> A invalidate_range_start: (has no blocking)
>     spin_lock()
>     counter++
>     spin_unlock()
> 
> A invalidate_range_end:
>     spin_lock()
>     counter--
>     spin_unlock()
> 
> And this one:
> 
> B invalidate_range_start: (has blocking)
>     if (!try_mutex_lock())
>         return -EAGAIN;
>     counter++
>     mutex_unlock()
> 
> B invalidate_range_end:
>     spin_lock()
>     counter--
>     spin_unlock()
> 
> So now the oom path does:
> 
> invalidate_range_start_non_blocking:
>  for each mn:
>    a->invalidate_range_start
>    b->invalidate_range_start
>    rc = EAGAIN
> 
> Now we SKIP A's invalidate_range_end even though A had no idea this
> would happen has state that needs to be unwound. A is broken.
> 
> B survived just fine.
> 
> A and B *alone* work fine, combined they fail.

But that requires that they share some state, right?

> When the commit was landed you can use KVM as an example of A and RDMA
> ODP as an example of B

Could you point me where those two share the state please? KVM seems to
be using kvm->mmu_notifier_count but I do not know where to look for the
RDMA...
-- 
Michal Hocko
SUSE Labs

