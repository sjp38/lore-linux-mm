Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id l6KKUaum021763
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 21:30:36 +0100
Received: from an-out-0708.google.com (anab21.prod.google.com [10.100.53.21])
	by zps18.corp.google.com with ESMTP id l6KKUQt5022938
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 13:30:26 -0700
Received: by an-out-0708.google.com with SMTP id b21so208572ana
        for <linux-mm@kvack.org>; Fri, 20 Jul 2007 13:30:26 -0700 (PDT)
Message-ID: <6599ad830707201330t419458f2tba2d7a31d3b9701e@mail.gmail.com>
Date: Fri, 20 Jul 2007 13:30:26 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm PATCH 2/8] Memory controller containers setup (v3)
In-Reply-To: <20070720082416.20752.92946.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	 <20070720082416.20752.92946.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dave Hansen <haveblue@us.ibm.com>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

On 7/20/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> +config CONTAINER_MEM_CONT
> +       bool "Memory controller for containers"
> +       select CONTAINERS

Andrew asked me to not use "select" in Kconfig files due to some
unspecified problems seen in the past, so my latest patchset makes the
subsystems depend on containers rather than selecting them; I prefer
the select approach over the dependency approach, but if select does
have problems then we should be consistent.

> +static struct cftype mem_container_usage = {
> +       .name = "mem_usage",
> +       .private = RES_USAGE,

For V11, the .name field should just be called something like 'usage';
the subsystem name is automatically prefixed.

> +
> +static int mem_container_create(struct container_subsys *ss,
> +                               struct container *cont)
> +{
> +       struct mem_container *mem;
> +
> +       mem = kzalloc(sizeof(struct mem_container), GFP_KERNEL);
> +       if (!mem)
> +               return -ENOMEM;
> +
> +       res_counter_init(&mem->res);
> +       cont->subsys[mem_container_subsys_id] = &mem->css;
> +       mem->css.container = cont;
> +       return 0;

For the V11 patchset, you'll want to replace these three lines with just

  return &mem->css;

> +static int mem_container_populate(struct container_subsys *ss,
> +                               struct container *cont)
> +{
> +       int rc = 0;
> +
> +       rc = container_add_file(cont, &mem_container_usage);
> +       if (rc < 0)
> +               goto err;
> +
> +       rc = container_add_file(cont, &mem_container_limit);
> +       if (rc < 0)
> +               goto err;
> +
> +       rc = container_add_file(cont, &mem_container_failcnt);
> +       if (rc < 0)
> +               goto err;

There's a container_add_files() API in V10 and above that lets you
register an array of files in one go.

> +
> +err:
> +       return rc;
> +}
> +
> +struct container_subsys mem_container_subsys = {
> +       .name = "mem_container",

Maybe just "memory" or "pages" for the container name?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
