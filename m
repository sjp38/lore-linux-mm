Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m548xXlC008978
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 09:59:34 +0100
Received: from an-out-0708.google.com (anac36.prod.google.com [10.100.54.36])
	by zps18.corp.google.com with ESMTP id m548xWP4009167
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 01:59:33 -0700
Received: by an-out-0708.google.com with SMTP id c36so514845ana.22
        for <linux-mm@kvack.org>; Wed, 04 Jun 2008 01:59:32 -0700 (PDT)
Message-ID: <6599ad830806040159i4dfd8350w54e41c5ba4e0c8c4@mail.gmail.com>
Date: Wed, 4 Jun 2008 01:59:31 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
In-Reply-To: <20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080604140153.fec6cc99.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 3, 2008 at 10:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>        int ret;
>        char *buf, *end;
> @@ -133,13 +145,101 @@ ssize_t res_counter_write(struct res_cou
>                if (*end != '\0')
>                        goto out_free;
>        }
> -       spin_lock_irqsave(&counter->lock, flags);
> -       val = res_counter_member(counter, member);
> -       *val = tmp;
> -       spin_unlock_irqrestore(&counter->lock, flags);
> -       ret = nbytes;
> +       if (set_strategy) {
> +               ret = set_strategy(res, tmp, member);
> +               if (!ret)
> +                       ret = nbytes;
> +       } else {
> +               spin_lock_irqsave(&counter->lock, flags);
> +               val = res_counter_member(counter, member);
> +               *val = tmp;
> +               spin_unlock_irqrestore(&counter->lock, flags);
> +               ret = nbytes;
> +       }

I think that the hierarchy/reclaim handling that you currently have in
the memory controller should be here; the memory controller should
just be able to pass a reference to try_to_free_mem_cgroup_pages() and
have everything else handled by res_counter.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
