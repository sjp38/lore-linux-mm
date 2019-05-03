Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2450C04AA9
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 00:41:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D6A02087F
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 00:41:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="e1IXm1t3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D6A02087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6D056B0003; Thu,  2 May 2019 20:41:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1E146B0005; Thu,  2 May 2019 20:41:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E64A6B0007; Thu,  2 May 2019 20:41:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 751456B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 20:41:19 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id q15so1817908otl.8
        for <linux-mm@kvack.org>; Thu, 02 May 2019 17:41:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=SHIb7mMlQkdwyCNw9OmBZQRiEVvms1FbzqlKO0H0jyU=;
        b=Z6nAZ4pys000YiMrSBe4xyNOD1T9u8eLe72mO3FUym+WqjeLt5psKf/xzDU+2uESWs
         E8LN/WWf2o55tSjT/jYjiPuxt4InmmqeWO34gk3Bpdzl/fe+GnUCx+GVaHr2/g0taWe/
         XVgirnJAve4D9YY1GSCjg/3MOZIXN6S9AvBCmmvEC3kZw8HLxC+ub8DtemkGYYTXI9/O
         AnkmxYAnvqiPYC3qrnbhHsh9sO1Gr1SOul6euPe5oTr4y2WuTK9zhWBZTKB7ceMC50Na
         iDl3j8MRSAh8QuCnUX1I3WjfU/jEdgogcWLMr9arZS7Ir6eYUojToBvsC5MQcpOJMK8o
         BOHQ==
X-Gm-Message-State: APjAAAWOBbAkXEHRJMNMlf9HwVpoIyb3gU8tYddTjSpzJ55VT3MlaEF/
	/CbePdTb1ZnRUxSjZHQkAJAfOUOJVcbBR0TODHFzqAVVSlM2Yq0wZeWpYyXgRV6eTpx/1FXO4dZ
	47zlEiUBD/8P9HVmjg2KErDbGEPMdgVDuVSJadCYhrcmstbMvMlpJyWRsIcdmyLFOcg==
X-Received: by 2002:aca:240b:: with SMTP id n11mr1830142oic.143.1556844078829;
        Thu, 02 May 2019 17:41:18 -0700 (PDT)
X-Received: by 2002:aca:240b:: with SMTP id n11mr1830111oic.143.1556844077768;
        Thu, 02 May 2019 17:41:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556844077; cv=none;
        d=google.com; s=arc-20160816;
        b=wCiHR5/tmSAFAA48BqBWqgFeCizR4P3xQo0wYZrr+5fP7Cc+zrYXvSKrP+S40oSECw
         2b+hcca7rfVxdFP2RDCb4sEPirjfay7ykOccMvvUjKeDGyrGDgSXG1Ro//Qyfdf6uoyv
         LiAzvdgblawTkLMaBAmNjSCv02agIXjtC3L6zqvVjuMAYrQ6BPyiq7W3J+NZgFadKKAY
         CDkBwgsqatiUq4Wj0rIcaAkRoeR9D4DE8kCGzyP+hlYWPBhTLeL9Uj38sD/r+8G96Fr6
         MU1F3m87YXwC3w612WqMDOXnKRMlFcemngMcpgnb7f1LpIaHReHaWrTH8apI7DS2N6GD
         8NLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=SHIb7mMlQkdwyCNw9OmBZQRiEVvms1FbzqlKO0H0jyU=;
        b=eUm3Yj76jnUZqWj+fvO2xBoeGkUGwO27Yn9e3ateSdpRwQLFiLx9kJ6mSRFvIzU5XN
         tzB0ZbKiBmeNuuBxjWoWu6UWqxHgyRBNlco4v/7cESHuTYhGwCfnJph3E79LpwlLh8lD
         XQVxbJs/4nUjXnyP9cml62arfPkhdiK33jrMBzOnDt4ahM2FJfEGoXZ6aIAYHguxvau6
         VEk/JUDwQTYug0d5+2EKYKGhD7y21I2/E+uPsG0E6ZcbjVJQ7g6Lf4+gs6KbASYj1Uf0
         7cqJRE+U1Vc+wHNtIRnIeZNVuQ/HehHt5LxlhibjYbhgxyfU5xyGjWiT3p7vJbHRaSHx
         UYqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=e1IXm1t3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i22sor281344oii.111.2019.05.02.17.41.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 17:41:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=e1IXm1t3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=SHIb7mMlQkdwyCNw9OmBZQRiEVvms1FbzqlKO0H0jyU=;
        b=e1IXm1t3gKlTz2nFZZhNAzGsgTFDXyOgM3CFnu4chnqlechdZ7feD30cbyHmMI5HHL
         Mow0+iu80TVLHPyMx1LwR9PuBhoBHNdhmDP4ahBt00mnUknZ8tdK5CEfHgeOiftwVL0S
         F5KwPhWFCCeZpNAS0pz0EsQW4O3toomBI0UHHT5HsSM2H9gakq2uQPs8CTymYw5aTArB
         GAUHldWl2nCQQ5HdMNPl5hcpiP+LINUzdOtMtfIPK+9cTWWmQXy3Gd8fS1jVCKi3RMxF
         xmqYUQj3Rn2ZSQ+YTn8wmsjBK0VE8AS4n33Qkh/623T5y/inK3uqJblSvzvsWPFjELMJ
         yjNg==
X-Google-Smtp-Source: APXvYqyHWUCZG/bYwe3R1gmgamI4fU+xS8/lH0BFReBkq0nRMUCer+rB8GXaCig08T80kfmw9To4vMkmNRhGU8dh5W0=
X-Received: by 2002:aca:47c3:: with SMTP id u186mr4629092oia.105.1556844076989;
 Thu, 02 May 2019 17:41:16 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634586.2015392.2662168839054356692.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bCkqLc82G2MW+rYrKTi4KafC+tLCASkaT8zRfVJCCe8HQ@mail.gmail.com>
In-Reply-To: <CA+CK2bCkqLc82G2MW+rYrKTi4KafC+tLCASkaT8zRfVJCCe8HQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 2 May 2019 17:41:05 -0700
Message-ID: <CAPcyv4g+KNu=upejy7Xm=jWR0cdhygPAdSRbkfFGpJeHFGc4+w@mail.gmail.com>
Subject: Re: [PATCH v6 02/12] mm/sparsemem: Introduce common definitions for
 the size and mask of a section
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Robin Murphy <robin.murphy@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 7:53 AM Pavel Tatashin <pasha.tatashin@soleen.com> w=
rote:
>
> On Wed, Apr 17, 2019 at 2:52 PM Dan Williams <dan.j.williams@intel.com> w=
rote:
> >
> > Up-level the local section size and mask from kernel/memremap.c to
> > global definitions.  These will be used by the new sub-section hotplug
> > support.
> >
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Should be dropped from this series as it has been replaced by a very
> similar patch in the mainline:
>
> 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
>  mm/memremap: Rename and consolidate SECTION_SIZE

I saw that patch fly by and acked it, but I have not seen it picked up
anywhere. I grabbed latest -linus and -next, but don't see that
commit.

$ git show 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
fatal: bad object 7c697d7fb5cb14ef60e2b687333ba3efb74f73da

