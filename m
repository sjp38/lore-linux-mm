Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABECFC10F0A
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:50:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72E3A2087E
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:50:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72E3A2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02AF36B0006; Mon, 25 Mar 2019 10:50:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F41D66B0008; Mon, 25 Mar 2019 10:50:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0B4B6B000A; Mon, 25 Mar 2019 10:50:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9D46B0006
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:50:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m32so3946344edd.9
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:50:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LgB2gc+PW7bzoHCIRb7A2nfXSzD26V52wasM1SKGnyE=;
        b=elznEBm3ePWz344iPmxHKr0C1U+CvZqnWWAm8yXPP+aeQTcLAXNsrN3hNzwZa8yojF
         +Z///gx6nV87RjgoPCJyouy7Q9f7NFLDG2KhDA7ng7h5yoU9NAvHdUecseszzA8Om4DU
         ZKORJ8Euvazh2Dz2guOV0Nd2lM50fXc1fzxrR93r3hT3C9jZ3CgAQ45TVx/2Ok6U9nSC
         dkWeoLbAkIPUkBXMo95PKXaZeIh5uDzA4TntqKW84FPf4jxeTtc/877W1N527TtZBZdU
         vtMz2QKC1B3m92Jzqrsb3bE4u+7SweJ7bQpOAVdqiDh5L0ozvT3t78GqpbuO+fxfjuVI
         FoZA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXq/lYd2dpVOrD2ATxUQdFglYblYlZ6/IAqg9UiCsuAOfp+o8Pi
	LVXKgRnYSJYaea+Ud64qnebzXME+1BPNtiU2dfVzWjVPiroVb0DD5oSGn1UEhLSKB2lehTyecLj
	6EL+9lWO3NHRpjiEbDxS7LwU9nehCSz9FLgvhh19rYAC4Yi2b6B50TTn3Gtqs9Uw=
X-Received: by 2002:a50:a54b:: with SMTP id z11mr16874799edb.133.1553525426100;
        Mon, 25 Mar 2019 07:50:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwX+Cs4z7rVDnogPyNHqRn+Pe5xbvvZg3y7ZGG7HAuN2exRqlYrlpuzL6F+XUOMbbjuSNK
X-Received: by 2002:a50:a54b:: with SMTP id z11mr16874746edb.133.1553525425098;
        Mon, 25 Mar 2019 07:50:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553525425; cv=none;
        d=google.com; s=arc-20160816;
        b=WuWYBIwB6oEYphc4Mqs9i1oyNNA6xlq9VlkwNbkxcpadjTNJEe3a7kTlRfxz8K/H7w
         YJskMOzspg7408nIH6BqwCO5ABLineBWfErEIA+x82Zf0s5EZV20eSsJGg+SAd1N330x
         z45V2rGfc+aJGLZTxWO+LmtCJMr7sP24Fjf/tNybaUg7j+mz+Pvt+u5NcnTwExjTWpj/
         3I1Rtyrm43oJkydFhj2m0m7ZMvKFk4m91wVxP9lxrdcHv+uQ8/d3nR53QVdOynH/qm5S
         rUAgx9c2+KhpQHDLV70J5hSQtsM/1vo3+YX286IRkLiJ8ovyGTpYRymK4+DIxg3C2iXN
         98CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LgB2gc+PW7bzoHCIRb7A2nfXSzD26V52wasM1SKGnyE=;
        b=mxufpMvZt4AanH3TGx5gsSZ7a5sxDUXP3SVP3SGlR1xJXiIYw0Butp2zpihY7rhRRx
         3W8gei6j4/riP5sujRR25sTNeFmMFOr5aKZyibIbQOcis9sYHlSQS0NJpvn5uNfPQOuO
         DvX3M/iDSKT4AedRZGEfw1V1iVll/igebGjQMSP4QN5sNC8sqyHslmMw1bmbLtr2kVrX
         n18WNytPlFmIAZIq2ck/b9zbhW5u6snaF+oHVQVN4bFEsVmrpspCs10Cl7P69mLj2q6G
         onD/ldWMEz18G3E9Z2sf5U4k6+XaAgGzuGkYCQmTFwum8El6GVXf5VmSxOyU2QuC67jI
         aQOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si1259870edv.140.2019.03.25.07.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:50:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 058C5AF2F;
	Mon, 25 Mar 2019 14:50:23 +0000 (UTC)
Date: Mon, 25 Mar 2019 15:50:23 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Toshi Kani <toshi.kani@hpe.com>, Vlastimil Babka <vbabka@suse.cz>,
	stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
Message-ID: <20190325145023.GG9924@dhcp22.suse.cz>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz>
 <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
 <20190325101945.GD9924@dhcp22.suse.cz>
 <x494l7rdo5r.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x494l7rdo5r.fsf@segfault.boston.devel.redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 25-03-19 10:28:00, Jeff Moyer wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> >> > and I would like to know that you are
> >> > not just shifting the problem to a smaller unit and a new/creative HW
> >> > will force us to go even more complicated.
> >> 
> >> HW will not do this to us. It's software that has the problem.
> >> Namespace creation is unnecessarily constrained to 128MB alignment.
> >
> > And why is that a problem? A lack of documentation that this is a
> > requirement? Something will not work with a larger alignment? Someting
> > else?
> 
> See this email for one user-visible problem:
>   https://lore.kernel.org/lkml/x49imxbx22d.fsf@segfault.boston.devel.redhat.com/

: # ndctl create-namespace -m fsdax -s 128m
:   Error: '--size=' must align to interleave-width: 6 and alignment: 2097152
:   did you intend --size=132M?
: 
: failed to create namespace: Invalid argument

So the size is in section size units. So what prevents the userspace to
use a proper alignment? I am sorry if this is a stupid question but I am
not really familiar with ndctl nor the pmem side of it.
-- 
Michal Hocko
SUSE Labs

