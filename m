Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F233C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 12:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEA312083B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 12:33:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEA312083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28E4A8E0086; Tue,  5 Feb 2019 07:33:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23CC98E0083; Tue,  5 Feb 2019 07:33:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 153208E0086; Tue,  5 Feb 2019 07:33:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB2138E0083
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 07:33:40 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id d5so2781183otl.21
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 04:33:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=eVrCyOOX4Q8m/xrzM46I1JOcym+IuQeWWMfSDki7Qig=;
        b=srHYgbX/PpkHO7Lqcu3gxreHAnz3ObZobALPZj+Z8aevMXfDkb+9J8tMw1DmiJsaXi
         BAjSHeoTqhb9rRxImLw/ZSn2sbyzRB5u5mzql1yUpFN56RyyXwTrrJ2Z4GA3Juvej9jc
         oaNbRt54F/+T9bkPfRmHjfjTsghwnYVGhkbnsrsZ36w4hGdMihLH5+WQJ3072/zSQ4JI
         j4PkQSooswhaXFAYiSV38pebQR96dklcnT4ZQJla2Cj7vO+iht8uqFHmZ4Ue7ziUzn44
         t9mr6f8HP5gWCXk2/9RHxjAHMUA6QN8zZnKsrZgtIKz3x4zb5D2cUGERb/On2BMeUw1i
         m6Ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZgqYSh+zv5OSb6rz0NbamKBFcZ2Mqh2rHFP3nGQT29j3wJLnd+
	Kq6hfAFDM+mjAVxFErUJCpQsrAiGxB5kMMdCidZUIt3FXkmfMSqqH4ooV5b3eldTLcZAEAjrLy6
	BwqceVCAePkPEEet9LnqI8pc6sjjFM3ZgujO/X0VnlRf8uwOgD6xFDLMg9376AvTknWTccflwgz
	glFrEKfuaizxhmlBrn8a1E0kXqMahG0MO5YvSaY+NF6NZ+ImXdwKwQSnCBXfIsIC6sbkvbjqiWu
	RtYXfoaK0kerilaIsvPt+bk14b7+iWYmtgqxKCPaeDytPzpkr+sjALMyyJ2KQC4BOWzVMbxxSWC
	oE6FTZANOrvAuODgXhT8TrlKwbA/p5Ir1Z53opKh/uOCX0f2mUmYCA0hSQsAjMjG2bcet2WRfQ=
	=
X-Received: by 2002:a9d:282:: with SMTP id 2mr2442282otl.287.1549370020451;
        Tue, 05 Feb 2019 04:33:40 -0800 (PST)
X-Received: by 2002:a9d:282:: with SMTP id 2mr2442258otl.287.1549370019650;
        Tue, 05 Feb 2019 04:33:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549370019; cv=none;
        d=google.com; s=arc-20160816;
        b=VH8F+eitC8UrAECwl9GC75ucp7SrV4AmXati7OBP7CR7rZeZDZS/OR++PxHQ0PS87C
         ruEyGfyNAH4wkvFHtqyXGw1/4NSIgZo+40wZBMxyhAGwSTrfDtxRvqoCfMQwxLB3VxNz
         UPrXhmBXL5BawyJCoqMaXukIu5QFmahNrskJeORXs8f1/+VZq9+RH3OfCzXFeLWDF6Zo
         KhRHp0qBmetUukjvZeJsJzL8ZMhhhaCwWXKoGNubT3t8RTrJZsB21Ln3ff6Z3bMyQWJo
         wRINKQ0R9l4QT+V66ialvdRNvFl827GkoC+W1EGTHAMHncHvIvncbTODJWq5yjUR8iFS
         I43w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=eVrCyOOX4Q8m/xrzM46I1JOcym+IuQeWWMfSDki7Qig=;
        b=ukyinrA9lE9PoCcmZJc3JJjubw+1uiMWx5CYZ5q/ftGAb3GQ+OYEr2KYjNzOVlMPcR
         DzU7lJxYn8VxKCTWX0CjlZBpx08sLlX6wHhW5f+t8w8uCPoHDRJvw2qauDBhCy8p+LTK
         Kh2JyFwIy/lCAWzk7M1jk/SYsrDasrC9RJKOve9KpG9NTh12OPuxgqRbqBM/qAQnQgMs
         Op7kiT7rS2wrVYZVUjgJ75PiMmD2ITafbsEgXOHMCopK/FHlv1GA5q8VRAqF/GiIjITH
         a14Kk0/qx3KC1L7DfTxdOPgG+4oK1HQCsJGCPV8b96e7fEE6fZ9MuJkjtNVeorlUAdX+
         nu9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w23sor12030991otm.189.2019.02.05.04.33.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 04:33:39 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IYCwcYKxGHdjA4ZbtdNSvSA3Rhy71UX5Xe+VSg/3jqY88xImlg7ycMF6LOpcL7FrZWbhKUYevjf/Ey6eW7qoGI=
X-Received: by 2002:a9d:63c1:: with SMTP id e1mr2334981otl.119.1549370019045;
 Tue, 05 Feb 2019 04:33:39 -0800 (PST)
MIME-Version: 1.0
References: <20190124230724.10022-1-keith.busch@intel.com> <20190124230724.10022-5-keith.busch@intel.com>
In-Reply-To: <20190124230724.10022-5-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 5 Feb 2019 13:33:27 +0100
Message-ID: <CAJZ5v0jE_gRT5WgpQYwZQmx6N5G+axymbSySb2Nk8Q0OGeNt9A@mail.gmail.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
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

On Fri, Jan 25, 2019 at 12:08 AM Keith Busch <keith.busch@intel.com> wrote:
>
> Systems may be constructed with various specialized nodes. Some nodes
> may provide memory, some provide compute devices that access and use
> that memory, and others may provide both. Nodes that provide memory are
> referred to as memory targets, and nodes that can initiate memory access
> are referred to as memory initiators.
>
> Memory targets will often have varying access characteristics from
> different initiators, and platforms may have ways to express those
> relationships. In preparation for these systems, provide interfaces for
> the kernel to export the memory relationship among different nodes memory
> targets and their initiators with symlinks to each other.
>
> If a system provides access locality for each initiator-target pair, nodes
> may be grouped into ranked access classes relative to other nodes. The
> new interface allows a subsystem to register relationships of varying
> classes if available and desired to be exported.
>
> A memory initiator may have multiple memory targets in the same access
> class. The target memory's initiators in a given class indicate the
> nodes access characteristics share the same performance relative to other
> linked initiator nodes. Each target within an initiator's access class,
> though, do not necessarily perform the same as each other.
>
> A memory target node may have multiple memory initiators. All linked
> initiators in a target's class have the same access characteristics to
> that target.
>
> The following example show the nodes' new sysfs hierarchy for a memory
> target node 'Y' with access class 0 from initiator node 'X':
>
>   # symlinks -v /sys/devices/system/node/nodeX/access0/
>   relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY
>
>   # symlinks -v /sys/devices/system/node/nodeY/access0/
>   relative: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX
>
> The new attributes are added to the sysfs stable documentation.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node |  25 ++++-
>  drivers/base/node.c                         | 142 +++++++++++++++++++++++++++-
>  include/linux/node.h                        |   7 +-
>  3 files changed, 171 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 3e90e1f3bf0a..fb843222a281 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -90,4 +90,27 @@ Date:                December 2009
>  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
>  Description:
>                 The node's huge page size control/query attributes.
> -               See Documentation/admin-guide/mm/hugetlbpage.rst
> \ No newline at end of file
> +               See Documentation/admin-guide/mm/hugetlbpage.rst
> +
> +What:          /sys/devices/system/node/nodeX/accessY/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The node's relationship to other nodes for access class "Y".
> +
> +What:          /sys/devices/system/node/nodeX/accessY/initiators/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The directory containing symlinks to memory initiator
> +               nodes that have class "Y" access to this target node's
> +               memory. CPUs and other memory initiators in nodes not in
> +               the list accessing this node's memory may have different
> +               performance.
> +
> +What:          /sys/devices/system/node/nodeX/classY/targets/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The directory containing symlinks to memory targets that
> +               this initiator node has class "Y" access.
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 86d6cd92ce3d..6f4097680580 100644
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
> @@ -59,6 +60,94 @@ static inline ssize_t node_read_cpulist(struct device *dev,
>  static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
>  static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
>
> +/**
> + * struct node_access_nodes - Access class device to hold user visible
> + *                           relationships to other nodes.
> + * @dev:       Device for this memory access class
> + * @list_node: List element in the node's access list
> + * @access:    The access class rank
> + */
> +struct node_access_nodes {
> +       struct device           dev;

I'm not sure if the entire struct device is needed here.

It looks like what you need is the kobject part of it only and you can
use a kobject directly here:

struct kobject        kobj;

Then, you can register that under the node's kobject using
kobject_init_and_add() and you can create attr groups under a kobject
using sysfs_create_groups(), which is exactly what device_add_groups()
does.

That would allow you to avoid allocating extra memory to hold the
entire device structure and the extra empty "power" subdirectory added
by device registration would not be there.

> +       struct list_head        list_node;
> +       unsigned                access;
> +};

Apart from the above, the patch looks good to me.

