Return-Path: <SRS0=a6Xk=P4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 019DAC7113D
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 16:16:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CB902087B
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 16:16:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CB902087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06CC58E0003; Sun, 20 Jan 2019 11:16:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01B798E0001; Sun, 20 Jan 2019 11:16:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E73A38E0003; Sun, 20 Jan 2019 11:16:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC3CD8E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 11:16:23 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id p131so8334597oia.21
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 08:16:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=vqq8xMl7K0vAPz7n9VQCf5cdbFyZR4ZOXMYdzAlyKWw=;
        b=iv9s6aN8IaWzeEGdt+QJLr+83XX4g+U2DE5+Q7nE+f52OVReVKEQQ/YMbVYiI4nwxG
         mwzMyjvUk4NC7o2DtbawNb7m6XktHDv4q6Iyvp7UKvgmOxDWlPzuvdRq0p1xD35Q8vv6
         ONtQ9jL2fWMBCdehGeaIvYo/pMDDA0vHPG9u1PmoCKHKL4sogINcewTZI+3pJfZGBG24
         ntXB6zbPzEfyZet4/s1IEwsxm+WCBXPMOGzUyIi5Ca6yNysqtCl2ff44wp+wOLMWnql6
         VAaO5WJd/nx6Yyr+Ei/8yeqquSOSPjibqwrhl6hqtzmdG2ysUU4Jv7FYzJB1FQJgfuXz
         YvSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdtuxrkCunFVMUHpM8v6OehfUBnzNf2gqsQRBTRBPaAnxS7QDy7
	iBcW/gDKb5w1kewFVP5T46flkw7924cjZ11b0UhR6hY6XGz461gpgSafkiL/Mwj3fKrn1R4ouH6
	g5uNeQtaTAUAhWSgm4mP8L8z2DqFn/fYd+KS7G4MmFoofUdGsbsCOmgTH2LH8Or89fAE9aQz8yD
	738fKuxSbsN4nMlyA71i/lL1pjPN+B+dWfxqXYugsWns3VmybsVNWbtuoz+1d42ONwiYWg/ha52
	KogJL/qUBweC/P7+hYtQULu+qG6aCmuqZW+GSb4Tv+y2lL1sdYKEiOUfuuXISBp4bLX89Pv+9r7
	RElbQktFp9XtaeT+h7LUUiprgpwaOGjapYD0RxGlCeg5WP5Ec2+grppsuxwwaKMKQ3Do3Lv9TQ=
	=
X-Received: by 2002:aca:e7c9:: with SMTP id e192mr3632743oih.155.1548000983479;
        Sun, 20 Jan 2019 08:16:23 -0800 (PST)
X-Received: by 2002:aca:e7c9:: with SMTP id e192mr3632709oih.155.1548000982426;
        Sun, 20 Jan 2019 08:16:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548000982; cv=none;
        d=google.com; s=arc-20160816;
        b=XECMFTDhL64jd/120Jz/zSdx3WEcZgMAVKmGhkOGScRHLrJJwUggvBHMn+8NKO8v4S
         o+AcV3xCEgTEnsa27aJUW812Ij0O9NPNeHgQZwntv/oujAfgrVaR4vbWoNfQjmGMVpwy
         cPURp0V/akvsnM0XAL3G6/KbIHGMaZJFz9rYA08G2YTCxvJrbwKjHrPbc/Sd2SVzBIAR
         LbCDFuUKge9KbTmExXsGhT6mL7sStws1w6BcXZwtiGJQMM11xILeL4CUP8wsGxXDfkIx
         ldhUpFj6QFOc2i6nfcQkdlcMUT5khcmNVPoi0Brb0irWRmVXoH6N047cR9wW6+3B3iUH
         83KQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=vqq8xMl7K0vAPz7n9VQCf5cdbFyZR4ZOXMYdzAlyKWw=;
        b=jNPO8RGRkYbNTAmSHZjcLimMkoIe7rwOzZ3yJd9gzkBLMNzfD3sqvsvxcw+uj9RCX+
         Jv8RCmS3MS+Y88ES5qIjn+lFo2hPNuN8qiTwzomrTz9wn0TgsQNh0dDi7s3CWiquRRzb
         aSS1BGipHPlnIGKjdsIEvxBwXsZnCWqPS0u1uC5E76wiWbtk893u1OwuK+QsVtfZF3hQ
         aTeTGFRZnY/HxhF4R5hMEgzdL3EIOOcowCIXvx0c98HN8KAHATL5tbQ0P1KAEY4jvZ5O
         hP0XhXsMWWjcpj8K3FlK8A2zJgE1MmxESPbRSxcLprStAFOl/Nw9NFidSM0QGLVPoZYZ
         o3UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x73sor2186117oia.98.2019.01.20.08.16.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 08:16:22 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN7VrgUhjumeH8KZNgH0lP3U5pjPHxVHl07vfY246EtGTaBwoElTJbCp2NHeWQX88AoBHdGVHOZ1lVdDkhq38ow=
X-Received: by 2002:aca:6c8b:: with SMTP id h133mr3561880oic.33.1548000981959;
 Sun, 20 Jan 2019 08:16:21 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
 <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com> <20190119090129.GC10836@kroah.com>
In-Reply-To: <20190119090129.GC10836@kroah.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Sun, 20 Jan 2019 17:16:05 +0100
Message-ID:
 <CAJZ5v0jxuLPUvwr-hYstgC-7BKDwqkJpep94rnnUFvFhKG4W3g@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190120161605._s3DVwAsyHEhqZQjv8ceXbNvEt1rLW6ORGqv5u6A1l8@z>

On Sat, Jan 19, 2019 at 10:01 AM Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> On Fri, Jan 18, 2019 at 01:08:02PM -0800, Dan Williams wrote:
> > On Thu, Jan 17, 2019 at 3:41 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
> > >
> > > On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> > > >
> > > > Add entries for memory initiator and target node class attributes.
> > > >
> > > > Signed-off-by: Keith Busch <keith.busch@intel.com>
> > >
> > > I would recommend combining this with the previous patch, as the way
> > > it is now I need to look at two patches at the time. :-)
> > >
> > > > ---
> > > >  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
> > > >  1 file changed, 24 insertions(+), 1 deletion(-)
> > > >
> > > > diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> > > > index 3e90e1f3bf0a..a9c47b4b0eee 100644
> > > > --- a/Documentation/ABI/stable/sysfs-devices-node
> > > > +++ b/Documentation/ABI/stable/sysfs-devices-node
> > > > @@ -90,4 +90,27 @@ Date:                December 2009
> > > >  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > >  Description:
> > > >                 The node's huge page size control/query attributes.
> > > > -               See Documentation/admin-guide/mm/hugetlbpage.rst
> > > > \ No newline at end of file
> > > > +               See Documentation/admin-guide/mm/hugetlbpage.rst
> > > > +
> > > > +What:          /sys/devices/system/node/nodeX/classY/
> > > > +Date:          December 2018
> > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > +Description:
> > > > +               The node's relationship to other nodes for access class "Y".
> > > > +
> > > > +What:          /sys/devices/system/node/nodeX/classY/initiator_nodelist
> > > > +Date:          December 2018
> > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > +Description:
> > > > +               The node list of memory initiators that have class "Y" access
> > > > +               to this node's memory. CPUs and other memory initiators in
> > > > +               nodes not in the list accessing this node's memory may have
> > > > +               different performance.
> > >
> > > This does not follow the general "one value per file" rule of sysfs (I
> > > know that there are other sysfs files with more than one value in
> > > them, but it is better to follow this rule as long as that makes
> > > sense).
> > >
> > > > +
> > > > +What:          /sys/devices/system/node/nodeX/classY/target_nodelist
> > > > +Date:          December 2018
> > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > +Description:
> > > > +               The node list of memory targets that this initiator node has
> > > > +               class "Y" access. Memory accesses from this node to nodes not
> > > > +               in this list may have differet performance.
> > > > --
> > >
> > > Same here.
> > >
> > > And if you follow the recommendation given in the previous message
> > > (add "initiators" and "targets" subdirs under "classX"), you won't
> > > even need the two files above.
> >
> > This recommendation is in conflict with Greg's feedback about kobject
> > usage. If these are just "vanity" subdirs I think it's better to have
> > a multi-value sysfs file. This "list" style is already commonplace for
> > the /sys/devices/system hierarchy.
>
> If you do a subdirectory "correctly" (i.e. a name for an attribute
> group), that's fine.

Yes, that's what I was thinking about: along the lines of the "power"
group under device kobjects.

Cheers,
Rafael

