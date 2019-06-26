Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8080C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:14:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 704242084B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:14:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="l+5kJ6to"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 704242084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE2FC8E0019; Wed, 26 Jun 2019 12:14:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6B0C8E0002; Wed, 26 Jun 2019 12:14:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C327A8E0019; Wed, 26 Jun 2019 12:14:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 994D78E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:14:44 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id l7so1232218otj.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:14:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=XK0CaHJOVcsS/u0euQkBQYUAFEHomal+V6KfwmFuG+U=;
        b=Gmrui7K7ZvqGQ5nxBdgZB++pKuUUwsFD1xee2jKY73bGf8G8kkO82KfBz3EV2BMLHS
         aTwY1UMTYSFrnMM7JwgCCbjGyh8azRDPyncoSaQJ+9faLBrFJSdfcTJyioNuPw+s1KPE
         j3Q/YhdzrtQIkjKu0fV5hxmPixL7kRbhAGazaxpcgC3obSEah1KEymyTVptwGOYLEWFZ
         l7YmE4+uVoQ0+LMIGyEJ2rLhv5aF90qjuNWCIoaQ3Iy9wXMUfpK+fZwE5AsmP3LozIZ/
         THZ7f0GCI+lrEDw9Kr1cSPeWByopP7q4Eejik5xN/qpZh7kzKSNC28YzALYB4H2vDKWu
         HFZQ==
X-Gm-Message-State: APjAAAWVzQUpzN/Q+sH4mXf0PkIG3dBiNYTItDxG8fxIAuD1f7DY0vPr
	9QrimypNIMydUWTDR3AcdbRHvN3gVd89RW2kjOEoeo3om6SkFZVa7fSHvFrsBEZbhdyCSj7csg7
	0AW7QvYK6s1cPUJPIgkZIAsyYxL5t/NV/SRzEjyPS/70Gpd71KMdarlbx5zxKduIBxA==
X-Received: by 2002:a9d:711e:: with SMTP id n30mr3704166otj.97.1561565684161;
        Wed, 26 Jun 2019 09:14:44 -0700 (PDT)
X-Received: by 2002:a9d:711e:: with SMTP id n30mr3704135otj.97.1561565683598;
        Wed, 26 Jun 2019 09:14:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561565683; cv=none;
        d=google.com; s=arc-20160816;
        b=fv51FvRI2PlkAVlKyLCmZJIr2uJ0fOLrLeUYgLwMZ2Q7WGYq3Y5QAEU6Tyfyrfp1uM
         QTt/X0e3V+sd1FoZjIbfSXLmg3WkUJQ/ZRZdFO/Ijt1PGTu+KuQ8+oDFSTIn7zjPbApI
         yD4FJ2Qd6xkXSFGUHg2u/dlhiM2thu/z/8sXhf+YR3/uSzjzwYRPv+4Vl+2+Ow+3dwwZ
         8FgbzDrkQZuyjP4aJk2fyfwK2cv4ZnQy734IBPPqY7tHgmnRkc+YmR9MxA8F30xwWA9f
         YnUUHGsbQqmQkPt9sY5DGl4+Zyw1ka4jovPvEQDd0X3C5leaTKIall3HgAI1QC1r0Kar
         F80w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=XK0CaHJOVcsS/u0euQkBQYUAFEHomal+V6KfwmFuG+U=;
        b=rM+eYNUiBF9tH8GivboOY2nJ6Vd2WQjOkLvdE4KGowznPH02TocOlfuIvdxie8+rsN
         6NWUyzc+85JmxpYQaC2gILDU4y4WAUqO3ObY7V1Q9eHIOXKfRtdZiXCzn1x0Zb7hkMI5
         TVqsg6JfsaK/jXzsEJgU89HxnuSEEGD4aZpUuvqd9J4sUwYqPE9+ePHGfDzNxVj+JvKQ
         s7UeBAbyG6D4vliO96DvvFevGHW8OgvrjNk8v0WHlVi4T66aUiOjbdCCgR5tx+xvOhUp
         G44VFON7skY2V/eHx/PtODpJUtVzcVddW8TrsiJ1eNHzUaj128OlJHjWVA23SHWuOII/
         0Azg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=l+5kJ6to;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10sor9891587ote.136.2019.06.26.09.14.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 09:14:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=l+5kJ6to;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=XK0CaHJOVcsS/u0euQkBQYUAFEHomal+V6KfwmFuG+U=;
        b=l+5kJ6tokPJ98bH2NME9M/AQ27NvFMKuOsXn1/Bb6bOBzelrSngvtDZJXmVwZKzpKi
         qjSD/BPNZzWpZiBQzbopXZ4t+Owe9yGEnJZxcLTPAlrrPvnYO2K7gCbSAaaiJHFcBp4k
         rxUq8p1DHnLMI0fRDu2WCtVRP/OHmPtRFurCHJX0OhgjoUZQUqGECtXD/hiUSR9PPelH
         MnkCXYqaYmm4WKtHJZYWuY7L6Kj9qhni0KNGsJokbTzfJurnEEHErfJ69HKEvmfEeo+E
         N7IwPwAkdbg4plX6eEOz52RHtcXnuvonc5/m143W02YNIvHsz5xJAtpZFJ8Hrcf91kdm
         NShw==
X-Google-Smtp-Source: APXvYqxlK4A4nPLhfNez6panLCe0oG2uZ68rpjoeO+K9OBDO45YdiJCTPi2DLYKpN0RI7gOpjzzUX8DJkFMKIZ4j7YA=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr1155884otn.71.1561565683159;
 Wed, 26 Jun 2019 09:14:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-6-hch@lst.de>
 <20190620191733.GH12083@dhcp22.suse.cz> <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
 <20190625072317.GC30350@lst.de> <20190625150053.GJ11400@dhcp22.suse.cz>
 <CAPcyv4j1e5dbBHnc+wmtsNUyFbMK_98WxHNwuD_Vxo4dX9Ce=Q@mail.gmail.com>
 <20190625190038.GK11400@dhcp22.suse.cz> <CAPcyv4hU13v7dSQpF0WTQTxQM3L3UsHMUhsFMVz7i4UGLoM89g@mail.gmail.com>
 <20190626054645.GB17798@dhcp22.suse.cz>
In-Reply-To: <20190626054645.GB17798@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 26 Jun 2019 09:14:32 -0700
Message-ID: <CAPcyv4jLK2F2UHqbwp4bCEiB7tL8sVsr775egKMmJvfZG+W+NQ@mail.gmail.com>
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 10:46 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 25-06-19 12:52:18, Dan Williams wrote:
> [...]
> > > Documentation/process/stable-api-nonsense.rst
> >
> > That document has failed to preclude symbol export fights in the past
> > and there is a reasonable argument to try not to retract functionality
> > that had been previously exported regardless of that document.
>
> Can you point me to any specific example where this would be the case
> for the core kernel symbols please?

The most recent example that comes to mind was the thrash around
__kernel_fpu_{begin,end} [1]. I referenced that when debating _GPL
symbol policy with J=C3=A9r=C3=B4me [2].

[1]: https://lore.kernel.org/lkml/20190522100959.GA15390@kroah.com/
[2]: https://lore.kernel.org/lkml/CAPcyv4gb+r=3D=3DriKFXkVZ7gGdnKe62yBmZ7xO=
a4uBBByhnK9Tzg@mail.gmail.com/

