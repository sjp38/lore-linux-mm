Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48C92C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 15:03:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0309220851
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 15:03:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0309220851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F3C48E0008; Thu, 17 Jan 2019 10:03:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A2C18E0002; Thu, 17 Jan 2019 10:03:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6937D8E0008; Thu, 17 Jan 2019 10:03:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB188E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:03:56 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id o13so4987250otl.20
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:03:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=ImmjeuQSWzKdTrfcGU94mMd1ytB0FuoOXUAqrxnIWfY=;
        b=OOfxyLJSl7YUfGVEtaYe9OLyvB1LM40d4ZWpJPydCWeu4W93RSetohOYjrVgPlI89y
         RCxjoLfLwoTs9MDBbktnJz43qimRPUE3CmB7rHD7o8yMRJ6M0Qyw4C4ikD0nxuD4Zivw
         QkNo9TSYnT0e07rORzRNjz1o9PtovskyBVOgNllM1e92cOnoy2wZgogZRAvhsORdEQ30
         9xmurg1J4TxEPRyBAJjyWVjt4NyE4BcOcE604+fE6IQsMTTIQgLizdrSYKO027U6tFgr
         uNgnJqCLFOHBoVfe99W4xqNH7+NEYXsYKBMOJdAe2SUAiH1jsUbdeePh0YE5oAcS/0Q/
         q70w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfZcF8eXOU3MvKTFp9EL4qp4R4PiF2Gd6jLhiVK2J7rIjaSjdUx
	YZeUzlM7nx52v+56n9XvoKcUIPwgK4aA8R59rTZkZXSAiWSHmBsSPmER32Ml+tBCYrK+heQpYWn
	Y7uM5U1Ns6gJ5XCxwv8pCOAREwNBPfxYOK5F9pXyyZ/NvLnUX/6kBUhwRQS18Dh6kSrTWQCRtPx
	qIgDia5MkTA6ygeZui53RRMhgo3cWm1GaigUU00V/Mrkt/xY4+fj2fBejiqbGw6Yn9VV4ihIR0Y
	URrVK4sL+BEm+6nXUxoXesJa1VLluWOPGzn7GMmRFHpm0CrpGxmlJA69vTLR+Y/2UxSKYN5cWov
	YJXPzkdA70mM9wFcfJYcfIJWWL/FZ1n7E4wJKJQU0cN/QxZEf8tOJ6lrZJJaNXiSgbnVm9ah0g=
	=
X-Received: by 2002:a9d:7749:: with SMTP id t9mr9442208otl.342.1547737435957;
        Thu, 17 Jan 2019 07:03:55 -0800 (PST)
X-Received: by 2002:a9d:7749:: with SMTP id t9mr9442160otl.342.1547737435004;
        Thu, 17 Jan 2019 07:03:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547737434; cv=none;
        d=google.com; s=arc-20160816;
        b=Nx10WrFFxExlVuBydp4j3ZaYaEY2g5v2Iu1Obs5ClBrEI8PdQ79ZrljwIwki5lWfOw
         +Gp7p9y9bLv3OgS4Sze1sIkhpDB3YWTDCvNcVVkZ0ktNUBEKoxQTrrRtx0wx1Vit+NAP
         V8z/AFrhlAHuXJRG3oA12Uhb7r2XABpXzfuPOK04nZbCORFVXZoz+KvlBx0hDQNzysMd
         y4QLmB4yzlRe8LR2eA9Qh7xl2oqaFLa/OA+Re8ajQGhxMeRZ40i/6QIeCH4+5MpwyiFc
         SDGSQxmodEGjuMgPfWOMJlYoiBQmW4qS84tPJW6kApU6BZR7Bc0eAdf2yoYxQ7y5Q+rj
         8HZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=ImmjeuQSWzKdTrfcGU94mMd1ytB0FuoOXUAqrxnIWfY=;
        b=u06hl/HSIRvaVSvyJnxbWiLJ7r/TLqLuf9NfaYk5D5kgcJlSp/R+3ILtdRB3ai7RCe
         UV0uXG7STtZnNZJPlrn2ss4m/SLn73Ade0lH06x0quYfi6RrGrMyKRLTgJ/VRFF0AuK7
         Ok27zk7PhAX1WflOqnirhyHgeIRslbk0V+79u0nGSAnKx9dJYjPI97m/NDGHpAjq21+9
         RSBhZrjXSxKS4eisK4rgERVYjbLsa2hH2vrKl9tjYArEFggm/UK9EUCoPEZRk3KzxEho
         O1prI/Mqb2HoeeQItUmNxSLqwzUiahi8yNSb7X5ztmmLEH2ILqgRIv5cLeWvTe4E3Ion
         t4tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor877304otc.45.2019.01.17.07.03.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 07:03:54 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN7jX+BTJkN1ysdHmVzQW7RKZo2FZagZv6x6ZHHs+gWAiSY+25vg/U1G/qnPbjaDmUiAb1Vv7VmVgXiiStYD2Jo=
X-Received: by 2002:a9d:5f06:: with SMTP id f6mr9284156oti.258.1547737434324;
 Thu, 17 Jan 2019 07:03:54 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-8-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-8-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 16:03:42 +0100
Message-ID:
 <CAJZ5v0jCEdhKndgZgJ=SdHgFBM1Bcxusm_crYzAOTZDx3s=PdQ@mail.gmail.com>
Subject: Re: [PATCHv4 07/13] node: Add heterogenous memory access attributes
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
Message-ID: <20190117150342.8ydwm-Xdyiz5hZAiLO_3VM6vzg8gfmRw_yyaCbAlmOg@z>

 On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Heterogeneous memory systems provide memory nodes with different latency
> and bandwidth performance attributes. Provide a new kernel interface for
> subsystems to register the attributes under the memory target node's
> initiator access class. If the system provides this information, applications
> may query these attributes when deciding which node to request memory.
>
> The following example shows the new sysfs hierarchy for a node exporting
> performance attributes:
>
>   # tree -P "read*|write*" /sys/devices/system/node/nodeY/classZ/
>   /sys/devices/system/node/nodeY/classZ/
>   |-- read_bandwidth
>   |-- read_latency
>   |-- write_bandwidth
>   `-- write_latency
>
> The bandwidth is exported as MB/s and latency is reported in nanoseconds.
> Memory accesses from an initiator node that is not one of the memory's
> class "Z" initiator nodes may encounter different performance than
> reported here. When a subsystem makes use of this interface, initiators
> of a lower class number, "Z", have better performance relative to higher
> class numbers. When provided, class 0 is the highest performing access
> class.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/base/Kconfig |  8 ++++++++
>  drivers/base/node.c  | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/node.h | 25 +++++++++++++++++++++++++
>  3 files changed, 81 insertions(+)
>
> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index 3e63a900b330..6014980238e8 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
>           unusable. You should say N here unless you are explicitly looking to
>           test this functionality.
>
> +config HMEM_REPORTING
> +       bool
> +       default y
> +       depends on NUMA
> +       help
> +         Enable reporting for heterogenous memory access attributes under
> +         their non-uniform memory nodes.

Why would anyone ever want to say "no" to this?

Distros will set it anyway.

> +
>  source "drivers/base/test/Kconfig"
>
>  config SYS_HYPERVISOR
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 1da5072116ab..1e909f61e8b1 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -66,6 +66,9 @@ struct node_class_nodes {
>         unsigned                class;
>         nodemask_t              initiator_nodes;
>         nodemask_t              target_nodes;
> +#ifdef CONFIG_HMEM_REPORTING
> +       struct node_hmem_attrs  hmem_attrs;
> +#endif
>  };
>  #define to_class_nodes(dev) container_of(dev, struct node_class_nodes, dev)
>
> @@ -145,6 +148,51 @@ static struct node_class_nodes *node_init_node_class(struct device *parent,
>         return NULL;
>  }
>
> +#ifdef CONFIG_HMEM_REPORTING
> +#define ACCESS_ATTR(name)                                                 \
> +static ssize_t name##_show(struct device *dev,                            \
> +                          struct device_attribute *attr,                  \
> +                          char *buf)                                      \
> +{                                                                         \
> +       return sprintf(buf, "%u\n", to_class_nodes(dev)->hmem_attrs.name); \
> +}                                                                         \
> +static DEVICE_ATTR_RO(name);
> +
> +ACCESS_ATTR(read_bandwidth)
> +ACCESS_ATTR(read_latency)
> +ACCESS_ATTR(write_bandwidth)
> +ACCESS_ATTR(write_latency)
> +
> +static struct attribute *access_attrs[] = {
> +       &dev_attr_read_bandwidth.attr,
> +       &dev_attr_read_latency.attr,
> +       &dev_attr_write_bandwidth.attr,
> +       &dev_attr_write_latency.attr,
> +       NULL,
> +};
> +ATTRIBUTE_GROUPS(access);
> +

Kerneldoc?

And who is going to call this?

> +void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
> +                        unsigned class)
> +{
> +       struct node_class_nodes *c;
> +       struct node *node;
> +
> +       if (WARN_ON_ONCE(!node_online(nid)))
> +               return;
> +
> +       node = node_devices[nid];
> +       c = node_init_node_class(&node->dev, &node->class_list, class);
> +       if (!c)
> +               return;
> +
> +       c->hmem_attrs = *hmem_attrs;
> +       if (sysfs_create_groups(&c->dev.kobj, access_groups))
> +               pr_info("failed to add performance attribute group to node %d\n",
> +                       nid);
> +}
> +#endif
> +
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  static ssize_t node_read_meminfo(struct device *dev,
>                         struct device_attribute *attr, char *buf)
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 8e3666c12ef2..e22940a593c2 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -20,6 +20,31 @@
>  #include <linux/list.h>
>  #include <linux/workqueue.h>
>
> +#ifdef CONFIG_HMEM_REPORTING
> +/**
> + * struct node_hmem_attrs - heterogeneous memory performance attributes
> + *
> + * @read_bandwidth:    Read bandwidth in MB/s
> + * @write_bandwidth:   Write bandwidth in MB/s
> + * @read_latency:      Read latency in nanoseconds
> + * @write_latency:     Write latency in nanoseconds
> + */
> +struct node_hmem_attrs {
> +       unsigned int read_bandwidth;
> +       unsigned int write_bandwidth;
> +       unsigned int read_latency;
> +       unsigned int write_latency;
> +};
> +void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
> +                        unsigned class);
> +#else
> +static inline void node_set_perf_attrs(unsigned int nid,
> +                                      struct node_hmem_attrs *hmem_attrs,
> +                                      unsigned class)
> +{
> +}

Have you tried to compile this with CONFIG_HMEM_REPORTING unset?

> +#endif
> +
>  struct node {
>         struct device   dev;
>         struct list_head class_list;
> --

