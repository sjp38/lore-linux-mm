Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74EC5C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 11:26:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 267582054F
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 11:26:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 267582054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B30C98E0004; Thu, 17 Jan 2019 06:26:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE0198E0002; Thu, 17 Jan 2019 06:26:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CFD18E0004; Thu, 17 Jan 2019 06:26:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 716208E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:26:29 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id q11so4683001otl.23
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:26:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=+Lw2WQMOYvQqN57P2A8zIzSFAHgU0oFB/MCvtZM0Klw=;
        b=k5xnsXTHwPPJIDEP8MCjInAruTMt59sH4DzpQJHvPfFMKuZSnXCWgOTJzUPHtFDm7b
         GHDtYqU60ZqOrtW2LucLjivInBQa6uVr1jSemNLP0VNyJcHMMoVCqNEcgxJU4VhYyTAS
         mQVlZWOrsOgUCmxQHITIbawCXmKG1p6u5EgAhZ0wFG6szgexuibLrTP9sdEDnergqxUR
         fG1tBUwTZ4iJq4WzPh4DDd2o7Et9k5413ZPULORFLcaE1oB0oDICebjZ6Q3xHDDUfu+4
         IRSjQur1eu8rGYfMysKwFUoHMyc6fAUh8gN6VaBA9rSH1vmy9iDugtWiaw1fxgIdEJY0
         WsNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcWg+uvfZde40XwZ4YGY5CD98G2o9z/xdNelfudft/wTqlimOka
	vS9l2h9xwLoYz2YqHcUmGWiCOGzk9VYvMA7r/EEUqHM5jprbstdiwbkO6VsuaZPel2YhXDx4Nyo
	FXH4GiQJb8tRN+ejMYWC1CVrHH/6oEDxf+qs4KNJtS6uzlnaKhiPLKqIkBnYA70l59F8g8uOiGa
	B8M/XCC9v5mD8WwbdCLeXLVI6AyRaAqVOyqwFo8aQ3R0f/JtqvjWPhu8HHSxvFzb9oP4eZLHOaQ
	CxF66gfLi+zjlUMokYeaRzaQQqWWQAwPl3/I65Ox7nAE1g8AjZAHJiGb7uhV4uobMi1e5j9JYFi
	0AnNkYutT1DqZgD4dL4BwHlwZ+QCYAQfaIJpfN8PnLp0atSpZb5LQatVdecb6pzkqNaNUIm/Xw=
	=
X-Received: by 2002:a05:6830:14ca:: with SMTP id t10mr8845047otq.112.1547724389117;
        Thu, 17 Jan 2019 03:26:29 -0800 (PST)
X-Received: by 2002:a05:6830:14ca:: with SMTP id t10mr8845019otq.112.1547724388310;
        Thu, 17 Jan 2019 03:26:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547724388; cv=none;
        d=google.com; s=arc-20160816;
        b=GLMnfMHKveno6XjlqQnY79X91qfgWmaxRom3GJKgYsISBwLqdPxPZSlmF7oOrltG7U
         msdYmUxhZodgrZgR9pkF8eOlKJUHDneBRSpYueT2sSa3dRgC18u+zYXyahzNxXp3NV1X
         T7SCPbtz7NQDcZ6qSgCVwHKTstp3gcTqCCPP8SCUukn7IOv0Tw7SP8ThtkW3QfYbYvwT
         +mIzEwDZtZIhoAhsydXX+bC4YA2bhqtsDEXwfRl3Pz9dbHt0EeDrvl/lpdecS3/Dm9jM
         OJrIQjpT3XFErg3LpWbNM0+gWwIY6nYa0xLxaocLu5DLXFI7vZp1Jy1f1GhG1Skq1qRu
         J59g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=+Lw2WQMOYvQqN57P2A8zIzSFAHgU0oFB/MCvtZM0Klw=;
        b=lpdEOhsr0TormVvdzHPn4oMsSpPblxMWaWOFCduBwHnIKuRL/04MNWOkB5b2K3N8V2
         in2nNBybLfhqCL1bM5HFmJTyELI3DHH0OYuTYYT4kJnrsemoyembkdqLaLJdrp/umy2g
         6jw+nbz25pvdArvOiWtXIPDpt9wDPEBrw1c63aKaiIQpLygspVHj/WJSKE7fB8QPF7vC
         CLs/aU2LAPLKnPicMdnLD5cVAfsyDUdXsbLH02CYO0GC0RSP3PAmKKgYaNRCC8d6iSnQ
         tVybGwbCwGDQlprhlO1suZtnq6Ydm/vaHL0mT2N2kyCNUASlgLA2Qm5lk2J6xVKo9qm4
         96mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10sor618523oia.59.2019.01.17.03.26.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 03:26:28 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN7OnPsrfMexTY9aSwF/wMm/Ex9BtZEcTv78k21GLZ0mIxjGP11ug0klf7kXK9JusdS6afirRpHR8irgcT8oupk=
X-Received: by 2002:aca:195:: with SMTP id 143mr4767332oib.322.1547724387887;
 Thu, 17 Jan 2019 03:26:27 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-5-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-5-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 12:26:16 +0100
Message-ID:
 <CAJZ5v0hRsW037B1uPMYj=UO6TWDX9CWVyhYYjVjnvKQ=4ZaU5w@mail.gmail.com>
Subject: Re: [PATCHv4 04/13] node: Link memory nodes to their compute nodes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117112616.DUXZunpcdplnBCCGLoQe6ySHNClstZ00GDT5JuR_QTQ@z>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Systems may be constructed with various specialized nodes. Some nodes
> may provide memory, some provide compute devices that access and use
> that memory, and others may provide both. Nodes that provide memory are
> referred to as memory targets, and nodes that can initiate memory access
> are referred to as memory initiators.
>
> Memory targets will often have varying access characteristics from
> different initiators, and platforms may have ways to express those
> relationships. In preparation for these systems, provide interfaces
> for the kernel to export the memory relationship among different nodes
> memory targets and their initiators with symlinks to each other's nodes,
> and export node lists showing the same relationship.
>
> If a system provides access locality for each initiator-target pair, nodes
> may be grouped into ranked access classes relative to other nodes. The new
> interface allows a subsystem to register relationships of varying classes
> if available and desired to be exported. A lower class number indicates
> a higher performing tier, with 0 being the best performing class.
>
> A memory initiator may have multiple memory targets in the same access
> class. The initiator's memory targets in given class indicate the node's
> access characteristics perform better relative to other initiator nodes
> either unreported or in lower class numbers. The targets within an
> initiator's class, though, do not necessarily perform the same as each
> other.
>
> A memory target node may have multiple memory initiators. All linked
> initiators in a target's class have the same access characteristics to
> that target.
>
> The following example show the nodes' new sysfs hierarchy for a memory
> target node 'Y' with class 0 access from initiator node 'X':
>
>   # symlinks -v /sys/devices/system/node/nodeX/class0/
>   relative: /sys/devices/system/node/nodeX/class0/targetY -> ../../nodeY

If you added one more directory level and had "targets" and
"initiators" under "class0", the names of the symlinks could be the
same as the names of the nodes themselves, that is

/sys/devices/system/node/nodeX/class0/targets/nodeY -> ../../../nodeY

and the whole "nodelist" part wouldn't be necessary any more.

Also, it looks like "class0" is just a name at this point, but it will
represent an access class going forward.  Maybe it would be better to
use the word "access" in the directory name to indicate that (so there
would be "access0" instead of "class0").

>
>   # symlinks -v /sys/devices/system/node/nodeY/class0/
>   relative: /sys/devices/system/node/nodeY/class0/initiatorX -> ../../nodeX
>
> And the same information is reflected in the nodelist:
>
>   # cat /sys/devices/system/node/nodeX/class0/target_nodelist
>   Y
>
>   # cat /sys/devices/system/node/nodeY/class0/initiator_nodelist
>   X
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/base/node.c  | 127 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/node.h |   6 ++-
>  2 files changed, 131 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 86d6cd92ce3d..1da5072116ab 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -17,6 +17,7 @@
>  #include <linux/nodemask.h>
>  #include <linux/cpu.h>
>  #include <linux/device.h>
> +#include <linux/pm_runtime.h>
>  #include <linux/swap.h>
>  #include <linux/slab.h>
>
> @@ -59,6 +60,91 @@ static inline ssize_t node_read_cpulist(struct device *dev,
>  static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
>  static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
>

A kerneldoc describing the struct type, please.

> +struct node_class_nodes {
> +       struct device           dev;
> +       struct list_head        list_node;
> +       unsigned                class;
> +       nodemask_t              initiator_nodes;
> +       nodemask_t              target_nodes;
> +};
> +#define to_class_nodes(dev) container_of(dev, struct node_class_nodes, dev)
> +

Generally speaking, your code is devoid of comments.

To a minimum, there should be kerneldoc comments for non-static
functions to explain what they are for.

