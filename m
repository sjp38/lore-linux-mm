Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l6KKLL8x019937
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 21:21:22 +0100
Received: from an-out-0708.google.com (anac36.prod.google.com [10.100.54.36])
	by zps77.corp.google.com with ESMTP id l6KKKWb9019888
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 13:20:34 -0700
Received: by an-out-0708.google.com with SMTP id c36so202431ana
        for <linux-mm@kvack.org>; Fri, 20 Jul 2007 13:20:32 -0700 (PDT)
Message-ID: <6599ad830707201320q25c0ded9v937a365a53d9a77@mail.gmail.com>
Date: Fri, 20 Jul 2007 13:20:32 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm PATCH 1/8] Memory controller resource counters (v3)
In-Reply-To: <20070720082403.20752.68425.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	 <20070720082403.20752.68425.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eric W Biederman <ebiederm@xmission.com>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 7/20/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> +
> +ssize_t res_counter_read(struct res_counter *counter, int member,
> +               const char __user *userbuf, size_t nbytes, loff_t *pos)
> +{
> +       unsigned long *val;
> +       char buf[64], *s;
> +
> +       s = buf;
> +       val = res_counter_member(counter, member);
> +       s += sprintf(s, "%lu\n", *val);
> +       return simple_read_from_buffer((void __user *)userbuf, nbytes,
> +                       pos, buf, s - buf);
> +}

I think it should be possible to use the support built-in to task
containers to export a uint64 rather than having to create a separate
function here.

> +
> +ssize_t res_counter_write(struct res_counter *counter, int member,
> +               const char __user *userbuf, size_t nbytes, loff_t *pos)
> +{
> +       int ret;
> +       char *buf, *end;
> +       unsigned long tmp, *val;
> +
> +       buf = kmalloc(nbytes + 1, GFP_KERNEL);
> +       ret = -ENOMEM;
> +       if (buf == NULL)
> +               goto out;
> +
> +       buf[nbytes] = '\0';
> +       ret = -EFAULT;
> +       if (copy_from_user(buf, userbuf, nbytes))
> +               goto out_free;
> +
> +       ret = -EINVAL;
> +       tmp = simple_strtoul(buf, &end, 10);
> +       if (*end != '\0')
> +               goto out_free;
> +
> +       val = res_counter_member(counter, member);
> +       *val = tmp;
> +       ret = nbytes;
> +out_free:
> +       kfree(buf);
> +out:
> +       return ret;
> +}

I should probably add a generic "write uint64" wraper to task
containers as well.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
