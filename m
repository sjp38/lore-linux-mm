Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 52EDD6B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 12:33:19 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id wm15so2693876obc.33
        for <linux-mm@kvack.org>; Thu, 18 Apr 2013 09:33:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <516FA0B9.8080308@jp.fujitsu.com>
References: <516FA0B9.8080308@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 18 Apr 2013 09:32:58 -0700
Message-ID: <CAHGf_=qcV=R_O5fpjpRQh5Tu9=nz1jVR9r=55fYODds8TQm7vw@mail.gmail.com>
Subject: Re: [Bug fix PATCH] numa, cpu hotplug: Change links of CPU and node
 when changing node number by onlining CPU
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

>  #ifdef CONFIG_HOTPLUG_CPU
> +static void change_cpu_under_node(struct cpu *cpu,
> +                       unsigned int from_nid, unsigned int to_nid)
> +{
> +       int cpuid = cpu->dev.id;
> +       unregister_cpu_under_node(cpuid, from_nid);
> +       register_cpu_under_node(cpuid, to_nid);
> +       cpu->node_id = to_nid;
> +}
> +

Where is stub for !CONFIG_HOTPLUG_CPU?


>  static ssize_t show_online(struct device *dev,
>                            struct device_attribute *attr,
>                            char *buf)
> @@ -39,17 +48,23 @@ static ssize_t __ref store_online(struct device *dev,
>                                   const char *buf, size_t count)
>  {
>         struct cpu *cpu = container_of(dev, struct cpu, dev);
> +       int num = cpu->dev.id;

"num" is wrong name. cpuid may be better.


> +       int from_nid, to_nid;
>         ssize_t ret;
>
>         cpu_hotplug_driver_lock();
>         switch (buf[0]) {
>         case '0':
> -               ret = cpu_down(cpu->dev.id);
> +               ret = cpu_down(num);
>                 if (!ret)
>                         kobject_uevent(&dev->kobj, KOBJ_OFFLINE);
>                 break;
>         case '1':
> -               ret = cpu_up(cpu->dev.id);
> +               from_nid = cpu_to_node(num);
> +               ret = cpu_up(num);
> +               to_nid = cpu_to_node(num);
> +               if (from_nid != to_nid)
> +                       change_cpu_under_node(cpu, from_nid, to_nid);

You need to add several comments. this code is not straightforward.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
