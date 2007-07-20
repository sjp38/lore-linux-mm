Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id l6KLlu4B002999
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 22:47:57 +0100
Received: from wr-out-0506.google.com (wra50.prod.google.com [10.54.1.50])
	by zps35.corp.google.com with ESMTP id l6KLlcDc012479
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 14:47:53 -0700
Received: by wr-out-0506.google.com with SMTP id 50so782725wra
        for <linux-mm@kvack.org>; Fri, 20 Jul 2007 14:47:53 -0700 (PDT)
Message-ID: <6599ad830707201441q65c8efc2kecd99d6d8094672@mail.gmail.com>
Date: Fri, 20 Jul 2007 14:41:22 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm PATCH 8/8] Add switch to control what type of pages to limit (v3)
In-Reply-To: <20070720082528.20752.16398.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	 <20070720082528.20752.16398.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dave Hansen <haveblue@us.ibm.com>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

On 7/20/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> -static struct mem_container init_mem_container;
> +static ssize_t mem_control_type_read(struct container *cont,
> +                               struct cftype *cft,
> +                               struct file *file, char __user *userbuf,
> +                               size_t nbytes, loff_t *ppos)
> +{
> +       unsigned long val;
> +       char buf[64], *s;
> +       struct mem_container *mem;
> +
> +       mem = mem_container_from_cont(cont);
> +       s = buf;
> +       val = mem->control_type;
> +       s += sprintf(s, "%lu\n", val);
> +       return simple_read_from_buffer((void __user *)userbuf, nbytes,
> +                       ppos, buf, s - buf);
> +}

This could just use the read_uint64() hook and be something like

static u64 mem_container_control_type_read(struct container *cont,
struct cftype *cft)
{
  return mem_container_from_cont(cont)->control_type;
}

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
