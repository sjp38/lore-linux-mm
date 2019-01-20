Return-Path: <SRS0=a6Xk=P4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8F38C7113C
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 16:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C5C92087B
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 16:20:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C5C92087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06A638E0004; Sun, 20 Jan 2019 11:20:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F34FB8E0001; Sun, 20 Jan 2019 11:20:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFC4F8E0004; Sun, 20 Jan 2019 11:20:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5D098E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 11:20:13 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id v184so8354213oie.6
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 08:20:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=87E/+3zx0weqSrGfJzPSvhyyNU7cB2w5xkBG7edYcBc=;
        b=TSs+xcGyLmO0lvhnZdla8jegZiI++kf6Rc7hlINnxeuphszeLAtIPmbxJ62nwMGAy9
         pqxWLeK+Xyre8E/x6d8gpYcu+LYWtm1LkonLBR+hHnTjf2j++VYbu2ChPHsU/4rKApOj
         YMWyW1/HH/6r0xXpCEymR88IatMf8fdgAQDJ0sN5zWCE0qd/dzBQkUTBr3RKBuyhKR52
         M3zk4yrjcA41gmMHG65M6ml0bbkOhXm93/GiIZ5XMBf/NN60mE0JT+TZtJh+YA3VFm/M
         xQEGsgUgJjP4J9n8GCXGy0aIGDfshDcEGLgERf8V/03Dnt9TwXWJ1YN0lHP52o7WTurc
         adbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeRGGGr5i+KsY9fz/T2e7l9kG+qZMueP5eQNxrhDeC1ZsbWHJLv
	DCOETAUAVLi/4IEerEJIOxS9hcddlBskvXP7zlx9MWIVS1rKKQLmmbOuPvBIYAPSMPnsH6xZHVJ
	sRGf80PoylIffRcvnYOudMUipWakZen6s5WsFIlQPq4d2SXoKC2SPiS725LXdgxyaZSKDpIK81p
	7pAqfkwkeuBvgvgLAhXSG81Oqs0xT+YbiRhMiDU3Vt3ZN1uYQGLB24L1aTSDeVwYhclHtZ/VoE4
	WPom6rDfezW7NfG8AXehp4Mw7O6wlziBVc6poL4ZASF8kgnv8RnZpZifWnQi9pDHPd9Q/ZL8yRc
	L/rOn2Po52eoXnHivvvCwlXANr/3Gx/npCvpqnUNH6gOF+294kTCB90isagTQcESanIUTbdr1Q=
	=
X-Received: by 2002:aca:31cb:: with SMTP id x194mr3427745oix.213.1548001213493;
        Sun, 20 Jan 2019 08:20:13 -0800 (PST)
X-Received: by 2002:aca:31cb:: with SMTP id x194mr3427708oix.213.1548001212715;
        Sun, 20 Jan 2019 08:20:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548001212; cv=none;
        d=google.com; s=arc-20160816;
        b=ViU7tX1JX2X6ZLaxcGv603VSuOS7f4GJcbIXaHhpPihUC4020Kx1O6MyuqyiZs1FIQ
         oQf2eMpSYgtHdRSJKc2Yo7Zc04sJ0KCkj2vFmqX2cAf+YH1lLqkokEdi0+4dbA8pi63w
         wuxFB95C8IWNHKj2USfz0d062hXf20PpIZrsq+1Ta3/bVSFX9oGz9Woi+rCV92r+swgZ
         Wt7JQT/wjT0oETIxFvmzTV1ceoPeP7+tNqVRRA18yDaLdkkYDUtXh37hJzXmuhQhSH/e
         VJNRHT0Fjoqr5JF+wqSXOCLIKV6ONiZRPUmHDu94O0R6BxKcgFqdmSqImHAVc2fGUuT7
         yVOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=87E/+3zx0weqSrGfJzPSvhyyNU7cB2w5xkBG7edYcBc=;
        b=0MQFjaSgtHLeQwmuLi4ifogSXAm1zBNTZWYGM4PvlMuCMGQu9YwWU+x7hw3M5oDfKB
         o3AygglKEKtf1Ycr/rawWa67YJvCIfxFrNywUWuT2E7o7PH0IsR0+6Ecod/BRFP/3ZTd
         J4kqGxpQ/4sff5RM7K9CqsUIAHsJZUq5m/1AcA2N64Gyz/h22zCfgGSrre/67SK8t1m7
         ZmLRsId+LEGls8YcCkStUGCaE6Gdms/w6KWgVUDsEmFVkt22xxpYV4To91st7emUZAIQ
         7yG19lEeqhMaEhUrlpiwOGWh8i0MvC8q2drc6qHvzJpobo2Xq+WaLDJagzBkbWsVHe+p
         w9gA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s189sor1938095ois.146.2019.01.20.08.20.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 08:20:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN5NqABJ18wP8P6IhKoam3VQS7fk8Gs/RE1Yj7JHEHhV4UN+uNm+x//910014kfRV+Ut4sCX8NiXUchri5bNe+M=
X-Received: by 2002:aca:e715:: with SMTP id e21mr3625067oih.76.1548001212260;
 Sun, 20 Jan 2019 08:20:12 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
 <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com>
 <20190119090129.GC10836@kroah.com> <CAPcyv4jijnkW6E=0gpT3-qy5uOgTV-D7AN+CAu7mmdrRKGHvFg@mail.gmail.com>
In-Reply-To: <CAPcyv4jijnkW6E=0gpT3-qy5uOgTV-D7AN+CAu7mmdrRKGHvFg@mail.gmail.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Sun, 20 Jan 2019 17:19:56 +0100
Message-ID:
 <CAJZ5v0hS8Mb-BZuzztTt9D0Rd0TPzMcod48Ev-8HCZg07BP6fw@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
To: Dan Williams <dan.j.williams@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
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
Message-ID: <20190120161956.TcvjwSys_LudPXQQNY59zaFV7PGMFSf3MV-PMt7RmzQ@z>

On Sat, Jan 19, 2019 at 5:56 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Sat, Jan 19, 2019 at 1:01 AM Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
> >
> > On Fri, Jan 18, 2019 at 01:08:02PM -0800, Dan Williams wrote:
> > > On Thu, Jan 17, 2019 at 3:41 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
> > > >
> > > > On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> > > > >
> > > > > Add entries for memory initiator and target node class attributes.
> > > > >
> > > > > Signed-off-by: Keith Busch <keith.busch@intel.com>
> > > >
> > > > I would recommend combining this with the previous patch, as the way
> > > > it is now I need to look at two patches at the time. :-)
> > > >
> > > > > ---
> > > > >  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
> > > > >  1 file changed, 24 insertions(+), 1 deletion(-)
> > > > >
> > > > > diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> > > > > index 3e90e1f3bf0a..a9c47b4b0eee 100644
> > > > > --- a/Documentation/ABI/stable/sysfs-devices-node
> > > > > +++ b/Documentation/ABI/stable/sysfs-devices-node
> > > > > @@ -90,4 +90,27 @@ Date:                December 2009
> > > > >  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > > >  Description:
> > > > >                 The node's huge page size control/query attributes.
> > > > > -               See Documentation/admin-guide/mm/hugetlbpage.rst
> > > > > \ No newline at end of file
> > > > > +               See Documentation/admin-guide/mm/hugetlbpage.rst
> > > > > +
> > > > > +What:          /sys/devices/system/node/nodeX/classY/
> > > > > +Date:          December 2018
> > > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > > +Description:
> > > > > +               The node's relationship to other nodes for access class "Y".
> > > > > +
> > > > > +What:          /sys/devices/system/node/nodeX/classY/initiator_nodelist
> > > > > +Date:          December 2018
> > > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > > +Description:
> > > > > +               The node list of memory initiators that have class "Y" access
> > > > > +               to this node's memory. CPUs and other memory initiators in
> > > > > +               nodes not in the list accessing this node's memory may have
> > > > > +               different performance.
> > > >
> > > > This does not follow the general "one value per file" rule of sysfs (I
> > > > know that there are other sysfs files with more than one value in
> > > > them, but it is better to follow this rule as long as that makes
> > > > sense).
> > > >
> > > > > +
> > > > > +What:          /sys/devices/system/node/nodeX/classY/target_nodelist
> > > > > +Date:          December 2018
> > > > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > > > +Description:
> > > > > +               The node list of memory targets that this initiator node has
> > > > > +               class "Y" access. Memory accesses from this node to nodes not
> > > > > +               in this list may have differet performance.
> > > > > --
> > > >
> > > > Same here.
> > > >
> > > > And if you follow the recommendation given in the previous message
> > > > (add "initiators" and "targets" subdirs under "classX"), you won't
> > > > even need the two files above.
> > >
> > > This recommendation is in conflict with Greg's feedback about kobject
> > > usage. If these are just "vanity" subdirs I think it's better to have
> > > a multi-value sysfs file. This "list" style is already commonplace for
> > > the /sys/devices/system hierarchy.
> >
> > If you do a subdirectory "correctly" (i.e. a name for an attribute
> > group), that's fine.  Just do not ever create a kobject just for a
> > subdir, that will mess up userspace.
> >
> > And I hate the "multi-value" sysfs files, where at all possible, please
> > do not copy past bad mistakes there.  If you can make them individual
> > files, please do that, it makes it easier to maintain and code the
> > kernel for.
>
> I agree in general about multi-value sysfs, but in this case we're
> talking about a mask. Masks are a single value. That said I can get on
> board with calling what 'cpulist' does a design mistake (human
> readable mask), but otherwise switching to one file per item in the
> mask is a mess for userspace to consume.

Can you please refer to my response to Keith?

If you have "initiators" and "targets" under "classX" and a list of
symlinks in each of them, I don't see any kind of a mess here.

